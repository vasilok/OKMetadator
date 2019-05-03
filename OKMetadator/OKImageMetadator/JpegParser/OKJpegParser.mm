//
//  OKJpegParser.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/3/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKJpegParser.h"
#include <fstream>
#include <istream>
#include <string>
#include <cstdint>
#include <cstring>

// JPEG uses big-endian for markers a.k.a. network byte order.
// This header provides ntohs() for network->host byte order conversion.
#include <arpa/inet.h>

@implementation OKJpegParser

- (NSData *)xmpFromURL:(NSURL *)imageURL
{
    const std::string filename = [imageURL fileSystemRepresentation];
    std::ifstream stream( filename, std::ifstream::in | std::ifstream::binary );
    
    std::string xmp;
    if( stream.is_open() )
    {
        xmp = extractXmpFromJpeg( stream );
        
        stream.close();
    }
    
    if (xmp.length() == 0) return nil;
    
    NSData *data = [NSData dataWithBytes:&xmp length:xmp.length()];
    return data;
}

#pragma mark C code

enum JpegMarker
: uint16_t
{
    JPEG_MARKER_INDENTIFIER = 0xFF00,
    JPEG_APP_XMP_APP_MARKER = 0xFFE1,
    JPEG_MARKER_SOI = 0xFFD8,      // Start of compressed data
    JPEG_MARKER_EOI = 0xFFD9       // End of compressed data
};

static constexpr const char *XMP_APP_HEADER = "http://ns.adobe.com/xap/1.0/";
static constexpr size_t
XMP_APP_HEADER_SIZE = sizeof( "http://ns.adobe.com/xap/1.0/" ); // null is included
static constexpr size_t JPEG_MARKER_SIZE = 2;

bool readBigEndian16( std::istream &stream, uint16_t &val )
{
    stream.read( reinterpret_cast<char *>(&val), sizeof( uint16_t ) );
    val = ntohs( val );
    return stream.good();
}

std::string extractXmpFromJpeg( std::istream &stream )
{
    std::string xmp;
    std::streampos jpgOffset = stream.tellg();
    bool search = stream.good();
    size_t curCount = 0;
    
    while( search )
    {
        ++curCount;
        uint16_t jpegMarker = 0;
        search = readBigEndian16( stream, jpegMarker );
        jpgOffset += sizeof( uint16_t );
        
        // Skip non JPEG markers
        if( !search || ( jpegMarker & JPEG_MARKER_INDENTIFIER ) != JPEG_MARKER_INDENTIFIER )
        {
            continue;
        }
        
        switch( jpegMarker )
        {
            case JPEG_MARKER_SOI:
            {
                // No length marker, just skip
                break;
            }
            case JPEG_MARKER_EOI:
            {
                search = false;
                break;
            }
            case JPEG_APP_XMP_APP_MARKER:
            {
                uint16_t markerLength = 0;
                std::streampos appStart = jpgOffset;
                search = readBigEndian16( stream, markerLength );
                jpgOffset += markerLength;
                if( search && ( markerLength > XMP_APP_HEADER_SIZE ) )
                {
                    char header[XMP_APP_HEADER_SIZE];
                    search = stream.read( header, XMP_APP_HEADER_SIZE ).good();
                    
                    if( search && strncmp( XMP_APP_HEADER, header, XMP_APP_HEADER_SIZE - 1 ) ==
                       0 ) // don't compare null symbol
                    {
                        size_t xmpOffset =
                        static_cast<size_t>(appStart) + XMP_APP_HEADER_SIZE + JPEG_MARKER_SIZE;
                        size_t xmpSize = static_cast<size_t>(jpgOffset) - xmpOffset;
                        xmp.resize( xmpSize + 1, '\0' ); // extra null symbol
                        stream.read( &xmp[0], xmpSize );
                        search = false;
                    }
                }
                
                search &= stream.seekg( jpgOffset, stream.beg ).good();
                break;
            }
            default:
            {
                uint16_t markerLength = 0;
                search = readBigEndian16( stream, markerLength );
                jpgOffset += markerLength;
                
                search &= stream.seekg( jpgOffset, stream.beg ).good();
                break;
            }
        }
    }
    
    return xmp;
}

@end
