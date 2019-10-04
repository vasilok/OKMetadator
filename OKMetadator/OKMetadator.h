//
//  OKMetadator.h
//  OKMetadator
//
//  Created by Vasil_OK on 1/23/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#ifndef OKMetadator_h
#define OKMetadator_h

#import <Foundation/Foundation.h>


// APPLE FRAMEWORK DEFINES
// Public, common namespaces.
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceExif IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceExifAux IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceExifEX IMAGEIO_AVAILABLE_STARTING(10.9, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceDublinCore IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceIPTCCore IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceIPTCExtension IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespacePhotoshop IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceTIFF IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceXMPBasic IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataNamespaceXMPRights IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//
//// Public, common prefixes.
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixExif IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixExifAux IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixExifEX IMAGEIO_AVAILABLE_STARTING(10.9, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixDublinCore IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixIPTCCore IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixIPTCExtension IMAGEIO_AVAILABLE_STARTING(10.13.4, 11.3);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixPhotoshop IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixTIFF IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixXMPBasic IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);
//IMAGEIO_EXTERN const CFStringRef  kCGImageMetadataPrefixXMPRights IMAGEIO_AVAILABLE_STARTING(10.8, 7.0);



/*!
 @abstract @MetaFormat = NSDictionary {"namespace" : {"prefix:name" : value}}
 */
typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> OKMetaParam;

/*!
 @abstract completion block. Returns result of injection.
 */
typedef void (^OKSphereMetaInjectorCompletion)(BOOL);


/*!
 @abstract XML descriptions
 https://developers.google.com/streetview/spherical-metadata
 https://github.com/google/spatial-media/blob/master/docs/spherical-video-rfc.md
 */

// Available Image namespace

#define AppleNamespace  @"http://ns.apple.com/ImageIO/1.0/"
#define AppleDepthNamespace  @"http://ns.apple.com/depthData/1.0/"
#define AppleMatteNamespace  @"http://ns.apple.com/portraitEffectsMatte/1.0/"

#define PanoNamespace   @"http://ns.google.com/photos/1.0/panorama/"
#define GoogleNamespace @"http://ns.google.com/photos/1.0/image/"
#define GDepthNamespace  @"http://ns.google.com/photos/1.0/depthmap/"

#define AdobeExifNamespace @"http://ns.adobe.com/exif/1.0/"
#define AdobeXMPNamespace @"http://ns.adobe.com/xap/1.0/"
#define AdobePhotoshopNamespace @"http://ns.adobe.com/photoshop/1.0/"
#define AdobeTIFFNamespace @"http://ns.adobe.com/tiff/1.0/"




// Available Image prefixes
#define GPano   @"GPano"
#define GImage  @"GImage"
#define ImageIO @"iio"
#define Data    @"Data"
#define GDepth  @"GDepth"

#define Mime   @"Mime"
#define hasXMP @"hasXMP"
#define hasIIM @"hasIIM"

#define exif @"exif"
#define xmp @"xmp"
#define photoshop @"photoshop"
#define tiff @"tiff"

#define CustomRendered @"CustomRendered"
#define CustomRenderedPortrait 8
#define CustomRenderedPanorama 6
#define CustomRenderedHDR      3

#define Qualifiers @"Qualifiers"

// Auxiliarity
#define AUX_DEPTH     kCGImageAuxiliaryDataTypeDepth
#define AUX_DISPARITY kCGImageAuxiliaryDataTypeDisparity
#define AUX_MATTE     kCGImageAuxiliaryDataTypePortraitEffectsMatte

#define AUX_DATA kCGImageAuxiliaryDataInfoData
#define AUX_INFO kCGImageAuxiliaryDataInfoDataDescription
#define AUX_META kCGImageAuxiliaryDataInfoMetadata

#define AUX_BYTES_PER_ROW @"BytesPerRow"
#define AUX_HEIGHT        @"Height"
#define AUX_WIDTH         @"Width"
#define AUX_PIXEL_FORMAT  @"PixelFormat"

#define ADepth @"depthData"
#define Accuracy @"Accuracy"
#define Filtered @"Filtered"
#define Quality @"Quality"

#define AMatte @"portraitEffectsMatte"

// xmp keys
#define CreateDate @"CreateDate"
#define CreatorTool @"CreatorTool"
#define ModifyDate @"ModifyDate"

// ps key
#define DateCreated @"DateCreated"

// tiff
#define Make @"Make"
#define Model @"Model"
#define Orientation @"Orientation"
#define ResolutionUnit @"ResolutionUnit"
#define TileWidth @"TileWidth"
#define TileLength @"TileLength"
#define XResolution @"XResolution"
#define YResolution @"YResolution"

// Image spherical specific Keys
#define FirstPhotoDate               @"FirstPhotoDate"
#define LastPhotoDate                @"LastPhotoDate"
#define SourcePhotosCount            @"SourcePhotosCount"
#define ExposureLockUsed             @"ExposureLockUsed"
#define CaptureSoftware              @"CaptureSoftware"
#define InitialCameraDolly           @"InitialCameraDolly"

// Google Image Depth
#define Format         @"Format"
#define Near           @"Near"
#define Far            @"Far"
#define Units          @"Units"
#define MeasureType    @"MeasureType"
#define ConfidenceMime @"ConfidenceMime"
#define Confidence     @"Confidence"
#define Manufacturer   @"Manufacturer"
#define Model          @"Model"
#define Software       @"Software"
#define ImageWidth     @"ImageWidth"
#define ImageHeight    @"ImageHeight"


// Common Spherical Keys
#define FullPanoWidthPixels          @"FullPanoWidthPixels"
#define FullPanoHeightPixels         @"FullPanoHeightPixels"
#define UsePanoramaViewer            @"UsePanoramaViewer"
#define ProjectionType               @"ProjectionType"
#define PoseHeadingDegrees           @"PoseHeadingDegrees"
#define PosePitchDegrees             @"PosePitchDegrees"
#define PoseRollDegrees              @"PoseRollDegrees"
#define InitialViewHeadingDegrees    @"InitialViewHeadingDegrees"
#define InitialViewPitchDegrees      @"InitialViewPitchDegrees"
#define InitialViewRollDegrees       @"InitialViewRollDegrees"
#define InitialHorizontalFOVDegrees  @"InitialHorizontalFOVDegrees"
#define InitialVerticalFOVDegrees    @"InitialVerticalFOVDegrees"
#define CroppedAreaLeftPixels        @"CroppedAreaLeftPixels"
#define CroppedAreaImageHeightPixels @"CroppedAreaImageHeightPixels"
#define CroppedAreaTopPixels         @"CroppedAreaTopPixels"
#define CroppedAreaImageWidthPixels  @"CroppedAreaImageWidthPixels"

// Video namespace(head rdf)
#define SphericalVideo @"SphericalVideo"

// Video prefix
#define GSpherical @"GSpherical"

// Video spherical specific Keys
#define Spherical         @"Spherical"
#define Stitched          @"Stitched"
#define StitchingSoftware @"StitchingSoftware"
#define StereoMode        @"StereoMode"
#define SourceCount       @"SourceCount"
#define Timestamp         @"Timestamp"

// value for ProjectionType only supported
#define equirectangular @"equirectangular"
#define half_equirectangular @"half_equirectangular"

// values for StereoMode key:
#define mono       @"mono"
#define left_right @"left-right"
#define top_bottom @"top-bottom"

#define PP(prefix, param) [NSString stringWithFormat:@"%@:%@", prefix, param]
#define GP(param) [NSString stringWithFormat:@"%@:%@", @"GPano", param]
#define DP(param) [NSString stringWithFormat:@"%@:%@", @"GDepth", param]

#define CFS(stringref) CFBridgingRelease(stringref)

#define MimeType @"image/jpeg"

// value for GDepth
#define RangeInverse @"RangeInverse"
#define RangeLinear  @"RangeLinear"
#define mUnit        @"m" // meters
#define mmUnit       @"mm" // millimeters

// File Properties
#define FileSize NSURLFileSizeKey  // Mb

// Video Properties
#define Duration  @"Duration"   // sec
#define DateRate  @"DateRate"   // kbps
#define FrameRate @"FrameRate"  // frames/sec
#define VideoSize @"Size"       // CGSize in pixels

// Audio Properties
#define SampleRate      @"SampleRate" // kHz
#define Channels        @"Channels"
#define BytesPerFrame   @"BytesPerFrame"
#define FramesPerPacket @"FramesPerPacket"
#define BitsPerChannel  @"BitsPerChannel"
#define DateRate        @"DateRate"   // kbps

#define OKAuxType  @"OKAuxType"

#define OKSign @"OKMetadator"


@interface OKMetadator : NSObject

/*!
 * @brief extract basic file system properties
 * @param url indicates target file URL
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)filePropertiesFromURL:(nonnull NSURL *)url;

@end

#endif /* OKMetadator_h */
