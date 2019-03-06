//
//  VSVideoSphericalMetadator.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 3/6/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKVideoSphericalMetadator.h"
#import "metadata_utils.h"
#import <AVFoundation/AVFoundation.h>

@implementation OKVideoSphericalMetadator

- (nonnull NSDictionary *)sphericalMetaParamsVideoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self processExtractSpatialMetaAtURL:url];
}

- (void)make360VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl, @"Unexpected NIL!");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       AVAsset *asset = [AVAsset assetWithURL:atUrl];
                       CGSize size = [[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize];
                       
                       BOOL result = [self processInjectSpatialMeta:[self spatial360ParamsWithSize:size]
                                                              atURL:atUrl
                                                              toURL:toUrl];
                       
                       if (completion) {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              completion(result);
                                          });
                       }
                   });
}

- (void)make180VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl, @"Unexpected NIL!");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       AVAsset *asset = [AVAsset assetWithURL:atUrl];
                       CGSize size = [[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize];
                       
                       BOOL result = [self processInjectSpatialMeta:[self spatial180ParamsWithSize:size]
                                                              atURL:atUrl
                                                              toURL:toUrl];
                       
                       if (completion) {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              completion(result);
                                          });
                       }
                   });
}

- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make360VideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams writetoURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make180VideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams writetoURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (nonnull NSDictionary *)spatial360ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[Spherical] = @"true";
    updParams[Stitched] = @"true";
    updParams[StitchingSoftware] = @"OKMetadator";
    updParams[ProjectionType] = equirectangular;
    updParams[InitialViewHeadingDegrees] = @(0);
    updParams[InitialViewPitchDegrees] = @(0);
    updParams[InitialViewRollDegrees] = @(0);
    updParams[InitialHorizontalFOVDegrees] = @(75.0);
    updParams[PoseHeadingDegrees] = @(360);
    updParams[FullPanoWidthPixels] = @(size.width);
    updParams[FullPanoHeightPixels] = @(size.height);
    updParams[CroppedAreaImageWidthPixels] = @(size.width);
    updParams[CroppedAreaImageHeightPixels] = @(size.height);
    updParams[CroppedAreaLeftPixels] = @(0);
    updParams[CroppedAreaTopPixels] = @(0);
    
    return [updParams copy];
}

- (nonnull NSDictionary *)spatial180ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[Spherical] = @"true";
    updParams[Stitched] = @"true";
    updParams[StitchingSoftware] = @"OKMetadator";
    updParams[ProjectionType] = equirectangular;
    updParams[StereoMode] = left_right;
    updParams[SourceCount] = @(2);
    updParams[InitialViewHeadingDegrees] = @(0);
    updParams[InitialViewPitchDegrees] = @(0);
    updParams[InitialViewRollDegrees] = @(0);
    updParams[InitialHorizontalFOVDegrees] = @(75.0);
    updParams[PoseHeadingDegrees] = @(360);
    updParams[FullPanoWidthPixels] = @(size.width * 2);
    updParams[FullPanoHeightPixels] = @(size.height);
    updParams[CroppedAreaImageWidthPixels] = @(size.width);
    updParams[CroppedAreaImageHeightPixels] = @(size.height);
    updParams[CroppedAreaLeftPixels] = @(size.width/2);
    updParams[CroppedAreaTopPixels] = @(0);
    
    return [updParams copy];
}

#pragma mark Private

- (NSDictionary *)processExtractSpatialMetaAtURL:(NSURL *)url
{
    std::string inputPath = std::string([[url path] UTF8String]);
    SpatialMedia::Parser parser;
    parser.getInFile() = inputPath;
    
    SpatialMedia::Parser::enMode enMode =  parser.getStereoMode( );
    int *crop =  parser.getCrop();
    
    Utils utils;
    
    
    return @{};
}

- (BOOL)processInjectSpatialMeta:(NSDictionary *)metaParam atURL:(NSURL *)url toURL:(NSURL *)toURL
{
    std::string inputPath = std::string([[url path] UTF8String]);
    
    [[NSFileManager defaultManager] removeItemAtPath:[toURL path] error:nil];
    std::string outputPath = std::string([[toURL path] UTF8String]);
    
    SpatialMedia::Parser::enMode enMode = SpatialMedia::Parser::SM_NONE;
    
    if ([metaParam[StereoMode] isEqual:left_right])
    {
        enMode = SpatialMedia::Parser::SM_LEFT_RIGHT;
    }
    else if ([metaParam[StereoMode] isEqual:top_bottom])
    {
        enMode = SpatialMedia::Parser::SM_TOP_BOTTOM;
    }
    
    SpatialMedia::Parser parser;
    parser.getInFile() = inputPath;
    parser.getOutFile() = outputPath;
    parser.m_StereoMode = enMode;
    
    // crop
    parser.m_crop[0] = [metaParam[CroppedAreaImageWidthPixels] intValue];
    parser.m_crop[1] = [metaParam[CroppedAreaImageHeightPixels] intValue];
    parser.m_crop[2] = [metaParam[FullPanoWidthPixels] intValue];
    parser.m_crop[3] = [metaParam[FullPanoHeightPixels] intValue];
    parser.m_crop[4] = [metaParam[CroppedAreaLeftPixels] intValue];
    parser.m_crop[5] = [metaParam[CroppedAreaTopPixels] intValue];
    
    Utils utils;
    if ( parser.getInject ( ) )  {
        Metadata md;
        std::string &strVideoXML = utils.generate_spherical_xml ( parser.getStereoMode ( ), parser.getCrop ( ) );
        md.setVideoXML ( strVideoXML );
        utils.inject_metadata ( parser.getInFile ( ), parser.getOutFile ( ), &md );
        
        return YES;
    }
    
    return NO;
}

@end
