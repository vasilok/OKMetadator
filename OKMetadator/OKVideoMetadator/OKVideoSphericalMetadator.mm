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

typedef void (^OKVideoConverterCompletion)(NSURL *);

@interface OKVideoSphericalMetadator ()
@property(nonatomic, strong) OKVideoMetadator *converter;
@end

@implementation OKVideoSphericalMetadator

- (NSString *)stitchingSoftware
{
    return _stitchingSoftware ? _stitchingSoftware : @"OKMetadator";
}

- (nonnull OKMetaParam *)metaParamsFromVideoAtURL:(nonnull NSURL *)url
{
    OKMetaParam *param = [super metaParamsFromVideoAtURL:url];
    
    NSDictionary *spherical = [self sphericalMetaParamsVideoAtURL:url];
    
    if (spherical.allValues.count > 0)
    {
        NSMutableDictionary *mutParams = [param mutableCopy];
        [mutParams setObject:spherical forKey:SphericalVideo];
        
        param = [mutParams copy];
    }
    
    return param;
}

- (nonnull NSDictionary *)sphericalMetaParamsVideoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self processExtractSpatialMetaAtURL:url];
}

- (void)make360VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl, @"Unexpected NIL!");
    
    __typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       if ([atUrl.pathExtension isEqualToString:@"mp4"] ||
                           [atUrl.pathExtension isEqualToString:@"MP4"])
                       {
                           [blockSelf processInject360:YES existMeta:nil at:atUrl to:toUrl completion:completion];
                       }
                       else
                       {
                           [blockSelf convertToMP4VideoAt:atUrl completion:^(NSURL *convertedURL)
                            {
                                [blockSelf processInject360:YES existMeta:nil at:convertedURL to:toUrl completion:completion];
                                
                                [[NSFileManager defaultManager] removeItemAtURL:convertedURL error:nil];
                            }];
                       }
                   });
}

- (void)make180VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl, @"Unexpected NIL!");
    
    __typeof(self) blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       if ([atUrl.pathExtension isEqualToString:@"mp4"] ||
                           [atUrl.pathExtension isEqualToString:@"MP4"])
                       {
                           [blockSelf processInject360:NO existMeta:nil at:atUrl to:toUrl completion:completion];
                       }
                       else
                       {
                           [blockSelf convertToMP4VideoAt:atUrl completion:^(NSURL *convertedURL)
                            {
                                [blockSelf processInject360:NO existMeta:nil at:convertedURL to:toUrl completion:completion];
                                
                                [[NSFileManager defaultManager] removeItemAtURL:convertedURL error:nil];
                            }];
                       }
                   });
}

- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl && toUrl, @"Unexpected NIL!");
    
    return [self processInject360:YES existMeta:metaParams at:atUrl to:toUrl completion:completion];
}

- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl && toUrl, @"Unexpected NIL!");
    
    return [self processInject360:NO existMeta:metaParams at:atUrl to:toUrl completion:completion];
}

- (nonnull NSDictionary *)spatial360ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[Spherical] = @"true";
    updParams[Stitched] = @"true";
    updParams[StitchingSoftware] = [self stitchingSoftware];
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
    updParams[StitchingSoftware] = [self stitchingSoftware];
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
    Utils utils;
    ParsedMetadata *meta = utils.parse_metadata(inputPath);
    
    if (!meta) {
        return @{};
    }
    
    std::map<std::string, ParsedMetadata::videoEntry> videoXML = meta->m_video;
    std::map<std::string, ParsedMetadata::videoEntry>::iterator it = videoXML.begin();
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    while ( it != videoXML.end ( ) )  {
        ParsedMetadata::videoEntry value = it->second;
        
        std::map<std::string, std::string>::iterator it2 = value.begin();
        while (it2 != value.end()) {
            std::string key = it2->first;
            std::string val = it2->second;
            
            [dict setObject:[NSString stringWithCString:val.c_str() encoding:NSUTF8StringEncoding]
                     forKey:[NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
            it2++;
        }
        
        it++;
    }
    
    return [dict copy];
}

- (BOOL)processInject360:(BOOL)is360 existMeta:(NSDictionary *)metaParams at:(NSURL *)atUrl to:(NSURL *)toUrl completion:(OKSphereMetaInjectorCompletion)completion
{
    NSDictionary *inputSpherical = metaParams[SphericalVideo];
    
    AVAsset *asset = [AVAsset assetWithURL:atUrl];
    CGSize size = [[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] naturalSize];
    NSMutableDictionary *spherical = [(is360 ? [self spatial360ParamsWithSize:size] : [self spatial180ParamsWithSize:size]) mutableCopy];
    [spherical setValuesForKeysWithDictionary:inputSpherical];
    
    NSMutableDictionary *other = [metaParams mutableCopy];
    [other removeObjectForKey:SphericalVideo];
    
    __typeof(self) blockSelf = self;
    if (other.allKeys.count > 0)
    {
        NSString *tempName = [NSString stringWithFormat:@"OKT%ld", (long)CFAbsoluteTimeGetCurrent()];
        NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:atUrl.pathExtension]] filePathURL];
        
        if ([super writeVideoAtURL:atUrl withMetaParams:other toURL:tempURL completion:^(BOOL success)
             {
                 if (success)
                 {
                     dispatch_async(dispatch_get_global_queue(0, 0), ^
                                    {
                                        BOOL result = [blockSelf processInjectSpatialMeta:spherical atURL:atUrl toURL:toUrl];
                                        if (completion)
                                        {
                                            dispatch_async(blockSelf.completionQueue, ^
                                                           {
                                                               completion(result);
                                                           });
                                        }
                                    });
                 }
                 else if (completion)
                 {
                     dispatch_async(blockSelf.completionQueue, ^
                                    {
                                        completion(NO);
                                    });
                 }
             }] == NO)
        {
            return NO;
        }
        
        return YES;
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^
                       {
                           BOOL result = [blockSelf processInjectSpatialMeta:spherical atURL:atUrl toURL:toUrl];
                           if (completion)
                           {
                               dispatch_async(blockSelf.completionQueue, ^
                                              {
                                                  completion(result);
                                              });
                           }
                       });
        return YES;
    }
    
    return NO;
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
        std::string sowfware = metaParam[StitchingSoftware] ? [metaParam[StitchingSoftware] UTF8String] : [@"" UTF8String];
        std::string &strVideoXML = utils.generate_spherical_xml ( parser.getStereoMode ( ), parser.getCrop ( ), sowfware );
        md.setVideoXML ( strVideoXML );
        utils.inject_metadata ( parser.getInFile ( ), parser.getOutFile ( ), &md );
        
        return YES;
    }
    
    return NO;
}

#pragma mark Converter

- (void)convertToMP4VideoAt:(NSURL *)url completion:(OKVideoConverterCompletion)completion
{
    NSString *tempName = [NSString stringWithFormat:@"OKT%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"mp4"]] filePathURL];
    
    __typeof(self) blockSelf = self;
    [super writeVideoAtURL:url withMetaParams:nil toURL:tempURL completion:^(BOOL success)
    {
        if (completion)
        {
            dispatch_async(blockSelf.completionQueue, ^
                           {
                               completion(success ? tempURL : nil);
                           });
        }
    }];
}

@end
