//
//  VSImageMetadator.m
//  VSMetadator
//
//  Created by Vasil_OK on 1/14/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageMetadator.h"
#import <os/log.h>
// for depth data
#import <AVFoundation/AVFoundation.h>

@implementation OKImageMetadator

#pragma mark Getters

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _completionQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (NSString *)captureSoftware
{
    return _captureSoftware ? _captureSoftware : @"OKMetadator";
}

- (CGImageMetadataRef)metaFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(source, 0, NULL);
    CFRelease(source);
    
    return metadata;
}

- (nullable OKMetaParam *)auxMetaParamsFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSMutableDictionary *aux = [NSMutableDictionary new];
    
    NSDictionary *depth = [self auxDictionaryFromSource:source withType:AUX_DEPTH];
    if (depth) {
        [aux setObject:depth forKey:CFS(AUX_DEPTH)];
    }
    
    NSDictionary *disparity = [self auxDictionaryFromSource:source withType:AUX_DISPARITY];
    if (disparity) {
        [aux setObject:disparity forKey:CFS(AUX_DISPARITY)];
    }
    
    if (@available(iOS 12.0, *)) {
        NSDictionary *matte = [self auxDictionaryFromSource:source withType:AUX_MATTE];
        if (matte) {
            [aux setObject:matte forKey:CFS(AUX_MATTE)];
        }
    }
    
    CFRelease(source);
    
    if (aux.allKeys.count == 0) {
        return nil;
    }
    
    return [aux copy];
}

- (NSDictionary *)auxDictionaryFromSource:(CGImageSourceRef)source withType:(CFStringRef)type
{
    NSMutableDictionary *dict = [CFBridgingRelease(CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, type)) mutableCopy];
    CGImageMetadataRef meta = CFBridgingRetain([dict objectForKey:CFS(AUX_META)]);
    
    if (meta)
    {
        dict[CFS(AUX_META)] = [self metaParamsFromMetadata:meta];
        CFRelease(meta);
    }
    
    return [dict copy];
}

- (nullable UIImage *)imageFromImageSource:(CGImageSourceRef)source withAuxType:(CFStringRef)type
{
    NSDictionary *depthDict = [self auxDictionaryFromSource:source withType:type];
    if (depthDict) {
        
        NSError *error;
        AVDepthData *depthData = [AVDepthData depthDataFromDictionaryRepresentation:depthDict
                                                                              error:&error];
        
        if (depthData == nil) {
            // try change format
            NSMutableDictionary *updDict = [depthDict mutableCopy];
            NSMutableDictionary  *descr = [updDict[CFS(AUX_INFO)] mutableCopy];
            descr[AUX_PIXEL_FORMAT] = @(kCVPixelFormatType_DisparityFloat16);
            updDict[CFS(AUX_INFO)] = [descr copy];
            
            depthData = [AVDepthData depthDataFromDictionaryRepresentation:updDict
                                                                     error:&error];
            
            if (depthData == nil) {
                os_log_error(OS_LOG_DEFAULT, "Could not create deapth data from source with error %@", error);
            }
        }
        
        if (depthData.depthDataType != kCVPixelFormatType_DisparityFloat16) {
            depthData = [depthData depthDataByConvertingToDepthDataType:kCVPixelFormatType_DisparityFloat16];
        }
        
        CIImage *ciImage = [CIImage imageWithDepthData:depthData];
        CGImageRef cgImage = [[CIContext context] createCGImage:ciImage fromRect:ciImage.extent];
        return [UIImage imageWithCGImage:cgImage];
    }
    
    return nil;
}

- (nullable NSDictionary *)auxImagesFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    UIImage *disparityImage = [self imageFromImageSource:source withAuxType:AUX_DISPARITY];
    if (disparityImage) {
        result[CFS(AUX_DISPARITY)] = disparityImage;
    }
    
    UIImage *depthImage = [self imageFromImageSource:source withAuxType:AUX_DEPTH];
    if (depthImage) {
        result[CFS(AUX_DEPTH)] = depthImage;
    }
    
    if (@available(iOS 12.0, *)) {
        UIImage *matteImage = [self imageFromImageSource:source withAuxType:AUX_MATTE];
        if (matteImage) {
            matteImage = [self rescaleMatte:matteImage];
            result[CFS(AUX_MATTE)] = matteImage;
        }
    }
    
    return result;
}

- (UIImage *)rescaleMatte:(UIImage *)image
{
    CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    CIVector *cropRect = [CIVector vectorWithX:0 Y:0 Z:image.size.width/2.0 W:image.size.height];
    [cropFilter setValue:ciimage forKey:@"inputImage"];
    [cropFilter setValue:cropRect forKey:@"inputRectangle"];
    
    ciimage = [cropFilter outputImage];
    
    CIFilter *resizeFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [resizeFilter setValue:ciimage forKey:@"inputImage"];
    [resizeFilter setValue:[NSNumber numberWithFloat:2.0f] forKey:@"inputAspectRatio"];
    
    ciimage = [resizeFilter outputImage];
    
    CGImageRef cgImg = [[CIContext context] createCGImage:ciimage fromRect:[ciimage extent]];
    UIImage *returnedImage = [UIImage imageWithCGImage:cgImg scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(cgImg);
    
    return returnedImage;
}

- (BOOL)applyMap:(nonnull UIImage *)map
      forImageAt:(nonnull NSURL *)imageURL
      andWriteAt:(nonnull NSURL *)url
{
    return NO;
}

- (BOOL)applyMap:(nonnull UIImage *)map
        forImage:(nonnull UIImage *)image
      andWriteAt:(nonnull NSURL *)url
{
    NSAssert(map && image && url, @"Unexpected NIL!");
    
    CVPixelBufferRef pb = [self pixelBufferFromCGImage:map.CGImage];
    if (pb == NULL) {
        os_log_error(OS_LOG_DEFAULT, "Could not create Pixel Buffer from map");
        return NO;
    }
    
    NSDictionary *diparityMeta = [self disparityMetadataWithPixelBuffer:pb];
    NSDictionary *disparityProps = [self disparityPropertiesWith:map image:image];
    
    NSError *error;
    AVDepthData *avData = [AVDepthData depthDataFromDictionaryRepresentation:diparityMeta error:&error];
    if (avData == nil) {
        os_log_error(OS_LOG_DEFAULT, "Could not create flat deapth data with error %@", error);
        return NO;
    }
    
    avData = [avData depthDataByConvertingToDepthDataType:kCVPixelFormatType_DisparityFloat32];
    
    NSString *type = CFS(AUX_DISPARITY);
    NSDictionary *avDict = [avData dictionaryRepresentationForAuxiliaryDataType:&type];
    
    AVDepthData *portraitData = [avData depthDataByConvertingToDepthDataType:kCVPixelFormatType_DepthFloat16];
    NSString *typeP = CFS(AUX_MATTE);
    NSDictionary *pDict = [portraitData dictionaryRepresentationForAuxiliaryDataType:&typeP];
    
    
    BOOL result = YES;
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)UIImageJPEGRepresentation(image, 1.0), NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source from image");
        return NO;
    }
    
    NSMutableData *dest_data = [NSMutableData data];
    CFStringRef UTI = CGImageSourceGetType(source);
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
    if(destination == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image destination");
        CFRelease(source);
        return NO;
    }
    
    CGImageDestinationAddImage(destination, image.CGImage, nil/*(CFDictionaryRef)disparityProps*/);
    CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_DISPARITY, (CFDictionaryRef)avDict);
    CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_MATTE, (CFDictionaryRef)pDict);
    
    result = CGImageDestinationFinalize(destination);
    if (result == NO)
    {
        CFRelease(destination);
        CFRelease(source);
        return NO;
    }
    
    result = [dest_data writeToURL:url atomically:YES];
    if (result == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not write image data at URL: %@", url);
    }
    
    CFRelease(destination);
    CFRelease(source);
    
    return result;
}

- (NSDictionary *)disparityDictionaryWithPixelBuffer:(CVPixelBufferRef)pb
{
    size_t width = CVPixelBufferGetWidth(pb);
    size_t height = CVPixelBufferGetHeight(pb);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pb);
    OSType format = CVPixelBufferGetPixelFormatType(pb);
    size_t size = CVPixelBufferGetDataSize(pb);
    
    
    //    kCVPixelFormatType_DisparityFloat16 = 'hdis', /* IEEE754-2008 binary16 (half float), describing the normalized shift when comparing two images. Units are 1/meters: ( pixelShift / (pixelFocalLength * baselineInMeters) ) */
    //    kCVPixelFormatType_DisparityFloat32 = 'fdis', /* IEEE754-2008 binary32 float, describing the normalized shift when comparing two images. Units are 1/meters: ( pixelShift / (pixelFocalLength * baselineInMeters) ) */
    //    kCVPixelFormatType_DepthFloat16 = 'hdep', /* IEEE754-2008 binary16 (half float), describing the depth (distance to an object) in meters */
    //    kCVPixelFormatType_DepthFloat32 = 'fdep', /* IEEE754-2008 binary32 float, describing the depth (distance to an object) in meters */
    
    
    CVPixelBufferLockBaseAddress(pb, 0);
    void *addr = CVPixelBufferGetBaseAddress(pb);
    NSData *pbData = [NSData dataWithBytes:addr length:size];
    CVPixelBufferUnlockBaseAddress(pb, 0);
    
    return @{
             CFS(AUX_DATA) : pbData,
             CFS(AUX_INFO) : @{
                     AUX_WIDTH : @(width),
                     AUX_HEIGHT : @(height),
                     AUX_BYTES_PER_ROW : @(bytesPerRow),
                     AUX_PIXEL_FORMAT : @(1717856627)//@(format)
                     },
             CFS(AUX_META) : @{
                     AppleNamespace : @{ PP(ImageIO, hasXMP) : @YES },
                     AppleDepthNamespace : @{ PP(ADepth, Accuracy) : @"relative",
                                              PP(ADepth, Filtered) : @YES,
                                              PP(ADepth, Quality) : @"high"
                                              }
                     }
             };
}

- (NSDictionary *)disparityPropertiesWith:(UIImage *)map image:(UIImage *)image
{
    //    "{ExifAux}" =     {
    //        Regions =         {
    //            HeightAppliedTo = 3088;
    //            RegionList =             (
    //                                      {
    //                                          AngleInfoRoll = 0;
    //                                          AngleInfoYaw = 315;
    //                                          ConfidenceLevel = 998;
    //                                          FaceID = 5;
    //                                          Height = "0.3515025973320007";
    //                                          Timestamp = 2147483647;
    //                                          Type = Face;
    //                                          Width = "0.4688082933425903";
    //                                          X = "0.4659412503242493";
    //                                          Y = "0.6131398677825928";
    //                                      },
    //                                      {
    //                                          Height = "0.3515025973320007";
    //                                          Type = Focus;
    //                                          Width = "0.4688082933425903";
    //                                          X = "0.4659412503242493";
    //                                          Y = "0.6131398677825928";
    //                                      }
    //                                      );
    //            WidthAppliedTo = 2316;
    //        };
    
    return @{ @"ExifAux" : @{
                      @"Regions" : @{
                              @"HeightAppliedTo" : @(image.size.height),
                              @"WidthAppliedTo" : @(image.size.width),
                              }
                      }
              };
    
    //    return @{CFS(kCGImagePropertyFileContentsDictionary) : @{
    //                     CFS(kCGImagePropertyImages) : @{
    //                             CFS(kCGImagePropertyAuxiliaryDataType) : CFS(kCGImageAuxiliaryDataTypeDisparity),
    //                             CFS(kCGImagePropertyWidth) : @(map.size.width),
    //                             CFS(kCGImagePropertyHeight) : @(map.size.height),
    //                           },
    //                     CFS(kCGImagePropertyWidth) : @(image.size.width),
    //                     CFS(kCGImagePropertyHeight) : @(image.size.height),
    //                     }};
}

- (NSDictionary *)disparityMetadataWithPixelBuffer:(CVPixelBufferRef)pb
{
    NSMutableDictionary *flatDict = [[self disparityDictionaryWithPixelBuffer:pb] mutableCopy];
    
    NSDictionary *metaDict = flatDict[CFS(AUX_META)];
    
    CGImageMetadataRef meta = [self metadataFromMetaParams:metaDict];
    
    if (meta)
    {
        flatDict[CFS(AUX_META)] = CFBridgingRelease(meta);
    }
    
    
    // TEST
    //    NSError *error;
    //    AVDepthData *depthData = [AVDepthData depthDataFromDictionaryRepresentation:flatDict
    //                                                                          error:&error];
    //
    //    if (depthData == nil) {
    //        os_log_error(OS_LOG_DEFAULT, "TEST AVDepthData with error %@", error);
    //    }
    
    
    
    return [flatDict copy];
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image), CGImageGetHeight(image),
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image), CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace, kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (nullable OKMetaParam *)metaParamsFromImageAtURL:(nonnull NSURL *)url
{
    CGImageMetadataRef metadata = [self metaFromImageAtURL:url];
    if (metadata == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create metadata");
        return nil;
    }
    
    NSDictionary *dict = [self metaParamsFromMetadata:metadata];
    
    CFRelease(metadata);
    
    return dict;
}

- (nullable OKMetaParam *)fullMetaParamsFromImageAtURL:(nonnull NSURL *)url
{
    NSMutableDictionary *full = [NSMutableDictionary new];
    
    [full addEntriesFromDictionary:[self metaParamsFromImageAtURL:url]];
    [full addEntriesFromDictionary:[self auxMetaParamsFromImageAtURL:url]];
    
    return [full copy];
}

- (nullable NSDictionary *)commonPropertiesFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSDictionary *dict = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    
    CFRelease(source);
    
    return dict;
}

- (nullable NSDictionary *)propertiesFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    NSDictionary *commonDict = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    NSLog(@"Common %@:\n", commonDict);
    
    NSDictionary *dict = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
    
    CFRelease(source);
    
    return dict;
}

- (BOOL)writeImage:(UIImage *)image
          withMeta:(nullable CGImageMetadataRef)meta
           auxDict:(nullable NSDictionary *)aux
        properties:(nullable NSDictionary *)props
             atURL:(nonnull NSURL *)imageURL
{
    return [self processImage:image properties:props meta:meta aux:aux atURL:imageURL];
}

- (BOOL)writeImage:(UIImage *)image withMetaParams:(nullable OKMetaParam *)metaParams properties:(nullable NSDictionary *)props atURL:(nonnull NSURL *)imageURL
{
    CGImageMetadataRef metadata = [self metadataFromMetaParams:metaParams];
    NSDictionary *aux = [self auxDictionaryFromMetaParams:metaParams];
    
    BOOL result = [self processImage:image properties:props meta:metadata aux:aux atURL:imageURL];
    
    CFRelease(metadata);
    
    return result;
}

#pragma mark XMP

- (nullable NSData *)xmpFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(source, 0, NULL);
    if (metadata == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create metadata");
        CFRelease(source);
        return nil;
    }
    
    NSData *xmp = CFBridgingRelease(CGImageMetadataCreateXMPData(metadata, NULL));
    
    CFRelease(source);
    CFRelease(metadata);
    
    return xmp;
}

- (BOOL)writeImage:(nonnull UIImage *)image
           withXMP:(nonnull NSData *)xmpData
        properties:(nullable NSDictionary *)props
             atURL:(nonnull NSURL *)url
{
    NSAssert(image && url && xmpData, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)UIImageJPEGRepresentation(image, 1.0), NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source from image");
        return NO;
    }
    
    CGImageMetadataRef metadata = CGImageMetadataCreateFromXMPData((CFDataRef)xmpData);
    if (metadata == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create metadata");
        CFRelease(source);
        return NO;
    }
    
    CGMutableImageMetadataRef destMetadata = CGImageMetadataCreateMutableCopy(metadata);
    
    NSMutableData *dest_data = [NSMutableData data];
    CFStringRef UTI = CGImageSourceGetType(source);
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(destination == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image destination");
        CFRelease(source);
        CFRelease(metadata);
        CFRelease(destMetadata);
        return NO;
    }
    
    if (destMetadata != NULL)
    {
        CGImageDestinationAddImageAndMetadata(destination, image.CGImage, destMetadata, (CFDictionaryRef)@{(NSString *)kCGImageDestinationMergeMetadata : @YES});
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)props);
    }
    else
    {
        CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)props);
    }
    
    if(CGImageDestinationFinalize(destination) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not make image finalizing");
        CFRelease(source);
        CFRelease(metadata);
        CFRelease(destMetadata);
        CFRelease(destination);
        return NO;
    }
    
    if([dest_data writeToURL:url atomically:YES] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not write image data at URL: %@", url);
        CFRelease(source);
        CFRelease(metadata);
        CFRelease(destMetadata);
        CFRelease(destination);
        
        return NO;
    }
    
    CFRelease(source);
    CFRelease(metadata);
    CFRelease(destMetadata);
    CFRelease(destination);
    
    return YES;
}

#pragma mark Converters

- (nonnull CGImageMetadataRef)metadataFromMetaParams:(nonnull OKMetaParam *)params
{
    NSAssert(params, @"Unexpected NIL!");
    
    CGMutableImageMetadataRef meta = CGImageMetadataCreateMutable();
    
    for (NSString *namespace in params.allKeys)
    {
        if ([namespace isEqualToString:CFS(AUX_DEPTH)] ||
            [namespace isEqualToString:CFS(AUX_DISPARITY)]) {
            continue;
        }
        if (@available(iOS 12.0, *)) {
            if ([namespace isEqualToString:CFS(AUX_MATTE)]) {
                continue;
            }
        }
        
        NSDictionary *param = params[namespace];
        
        CFErrorRef error;
        
        NSString *prefix = [[param.allKeys.firstObject componentsSeparatedByString:@":"] firstObject];
        
        if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)namespace, (CFStringRef)prefix, &error) == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", namespace, error);
        }
        
        // all tags dictionaries in namespace
        for (NSString *path in param.allKeys)
        {
            NSArray *comps = [path componentsSeparatedByString:@":"];
            if (comps.count != 2)
            {
                continue;
            }
            
            NSString *prefix = [comps firstObject];
            NSString *name = [comps lastObject];
            
            CGImageMetadataTagRef tag = [self tagFrom:param[path] withName:name prefix:prefix namespace:namespace];
            
            if (tag)
            {
                if (CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)path, tag) == NO)
                {
                    os_log_error(OS_LOG_DEFAULT, "Meta set tag: %@ with error: %@", tag, error);
                }
                CFRelease(tag);
            }
            else
            {
                os_log_error(OS_LOG_DEFAULT, "Meta create tag failed with prefix:%@ name:%@ value:%@", prefix, name, param[path]);
            }
        }
    }
    
    return meta;
}

- (CGImageMetadataTagRef)tagFrom:(NSObject<NSCopying> *)value withName:(NSString *)name prefix:(NSString *)prefix namespace:(NSString *)namespace
{
    if (([value isKindOfClass:[NSString class]]) || ([value isKindOfClass:[NSNumber class]]))
    {
        return [self stringTagFrom:value withName:name prefix:prefix namespace:namespace];
    }
    else if ([value isKindOfClass:[NSArray class]])
    {
        return [self arrayTagFrom:value withName:name prefix:prefix namespace:namespace];
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        return [self dictionaryTagFrom:value withName:name prefix:prefix namespace:namespace];
    }
    
    return NULL;
}

- (CGImageMetadataTagRef)stringTagFrom:(NSObject<NSCopying> *)value withName:(NSString *)name prefix:(NSString *)prefix namespace:(NSString *)namespace
{
    return
    CGImageMetadataTagCreate((CFStringRef)namespace,
                             (CFStringRef)prefix,
                             (CFStringRef)name,
                             kCGImageMetadataTypeString,
                             (__bridge CFTypeRef)value);
}

- (CGImageMetadataTagRef)arrayTagFrom:(NSObject<NSCopying> *)value withName:(NSString *)name prefix:(NSString *)prefix namespace:(NSString *)namespace
{
    NSArray *valueArray = (NSArray *)value;
    __block CGImageMetadataType arType = kCGImageMetadataTypeInvalid;
    
    NSMutableArray *resArray = [NSMutableArray new];
    
    for (int i = 0; i < valueArray.count; i++)
    {
        NSDictionary *objDict = valueArray[i];
        if (arType == kCGImageMetadataTypeInvalid) {
            [[objDict allKeys] enumerateObjectsUsingBlock:^(NSString *  _Nonnull objString, NSUInteger idx, BOOL * _Nonnull stopString) {
                if ([objString isEqualToString:@"type"])
                {
                    arType = (CGImageMetadataType)[objDict[objString] integerValue];
                    *stopString = YES;
                }
            }];
            
            if (arType != kCGImageMetadataTypeInvalid) {
                continue;
            }
        }
        
        NSObject<NSCopying> *arValue = [[objDict allValues] firstObject];
        
        if (([arValue isKindOfClass:[NSString class]]) || ([arValue isKindOfClass:[NSNumber class]]))
        {
            [resArray addObject:arValue];
        }
        else
        {
            CGImageMetadataTagRef tag = [self tagFrom:arValue withName:name prefix:prefix namespace:namespace];
            [resArray addObject:(__bridge id _Nonnull)(tag)];
        }
    }
    
    CGImageMetadataTagRef arTag =
    CGImageMetadataTagCreate((CFStringRef)namespace,
                             (CFStringRef)prefix,
                             (CFStringRef)name,
                             arType,
                             (__bridge CFTypeRef _Nonnull)(resArray));
    
    return arTag;
}

- (CGImageMetadataTagRef)dictionaryTagFrom:(NSObject<NSCopying> *)value withName:(NSString *)name prefix:(NSString *)prefix namespace:(NSString *)namespace
{
    NSMutableDictionary *resValue = [NSMutableDictionary new];
    
    NSDictionary *dicValue = (NSDictionary*)value;
    for (int i = 0; i < dicValue.allKeys.count; i++)
    {
        NSString *key = dicValue.allKeys[i];
        NSObject<NSCopying> *keyValue = dicValue[key];
        
        if (([keyValue isKindOfClass:[NSString class]]) || ([keyValue isKindOfClass:[NSNumber class]]))
        {
            [resValue setValue:keyValue forKey:key];
        }
        else
        {
            NSDictionary *tagDic = (NSDictionary *)keyValue;
            
            NSString *tagPrefix = prefix, *tagName = name, *tagNamespace = namespace;
            NSArray *keyComp = [key componentsSeparatedByString:@":"];
            
            if (keyComp.count == 2)
            {
                tagPrefix = keyComp.firstObject;
                tagName = keyComp.lastObject;
            }
            else if (keyComp.count == 3)
            {
                tagNamespace = keyComp[0];
                tagPrefix = keyComp[1];
                tagName = keyComp[2];
            }
            
            CGImageMetadataTagRef tag = [self tagFrom:tagDic withName:tagName prefix:tagPrefix namespace:tagNamespace];
            
            [resValue setValue:(__bridge id _Nullable)(tag) forKey:key];
        }
    }
    
    CGImageMetadataTagRef dicTag =
    CGImageMetadataTagCreate((CFStringRef)namespace,
                             (CFStringRef)prefix,
                             (CFStringRef)name,
                             kCGImageMetadataTypeStructure,
                             (__bridge CFTypeRef _Nonnull)(resValue));
    
    return dicTag;
}

- (nullable NSDictionary *)auxDictionaryFromMetaParams:(OKMetaParam *)params
{
    NSMutableDictionary *auxDict = [NSMutableDictionary new];
    
    NSDictionary *depth = [self auxDictionaryFromMetaParams:params withType:AUX_DEPTH];
    if (depth) {
        [auxDict setObject:depth forKey:CFS(AUX_DEPTH)];
    }
    
    NSDictionary *disparity = [self auxDictionaryFromMetaParams:params withType:AUX_DISPARITY];
    if (disparity) {
        [auxDict setObject:disparity forKey:CFS(AUX_DISPARITY)];
    }
    
    if (@available(iOS 12.0, *)) {
        NSDictionary *matte = [self auxDictionaryFromMetaParams:params withType:AUX_MATTE];
        if (matte) {
            [auxDict setObject:matte forKey:CFS(AUX_MATTE)];
        }
    }
    
    if (auxDict.allKeys.count == 0) {
        return nil;
    }
    
    return [auxDict copy];
}

- (nullable NSDictionary *)auxDictionaryFromMetaParams:(OKMetaParam *)params withType:(CFStringRef)type
{
    NSDictionary *typeDict = params[CFBridgingRelease(type)];
    if (typeDict == nil) {
        return nil;
    }
    
    NSData *data = nil;
    NSDictionary *info = nil;
    NSDictionary *meta = nil;
    
    for (NSString *key in typeDict.allKeys)
    {
        if ([key isEqualToString:CFS(AUX_DATA)])
        {
            data = (NSData *)typeDict[key];
        }
        if ([key isEqualToString:CFS(AUX_INFO)])
        {
            info = typeDict[key];
        }
        if ([key isEqualToString:CFS(AUX_META)])
        {
            meta = typeDict[key];
        }
    }
    
    if ((data == nil) || (info == nil) || (meta == nil)) {
        return nil;
    }
    
    CGImageMetadataRef metadata = [self metadataFromMetaParams:meta];
    if (metadata == NULL) {
        return nil;
    }
    
    NSDictionary *result = @{ CFS(AUX_DATA) : data, CFS(AUX_INFO) : info, CFS(AUX_META) : (__bridge id _Nullable)(metadata) };
    
    CFRelease(metadata);
    
    return result;
}

- (nonnull OKMetaParam *)metaParamsFromMetadata:(nonnull CGImageMetadataRef)meta
{
    NSAssert(meta, @"Unexpected NIL!");
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    CGImageMetadataEnumerateTagsUsingBlock(meta, NULL, NULL, ^bool(CFStringRef  _Nonnull path, CGImageMetadataTagRef  _Nonnull tag) {
        
        NSString *prefix = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyPrefix(tag));
        NSString *name = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyName(tag));
        NSObject<NSCopying> *value = [self valueFromTag:tag];
        
        if (value == nil) return true; // continue
        
        NSString *namespace = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyNamespace(tag));
        if (dict[namespace] == nil) {
            dict[namespace] = @{};
        }
        NSMutableDictionary *namespaceDict = [dict[namespace] mutableCopy];
        [namespaceDict setObject:value forKey:[NSString stringWithFormat:@"%@:%@", prefix, name]];
        dict[namespace] = namespaceDict;
        
        return true;
    });
    
    return [dict copy];
}

- (NSObject<NSCopying> *)valueFromTag:(CGImageMetadataTagRef)tag
{
    CGImageMetadataType type = CGImageMetadataTagGetType(tag);
    
    switch (type) {
        case kCGImageMetadataTypeString:
            return CFBridgingRelease(CGImageMetadataTagCopyValue(tag));
            
        case kCGImageMetadataTypeArrayUnordered:
        case kCGImageMetadataTypeArrayOrdered:
        case kCGImageMetadataTypeAlternateArray:
        case kCGImageMetadataTypeAlternateText:
        {
            NSArray *valueArray = CFBridgingRelease(CGImageMetadataTagCopyValue(tag));
            NSMutableArray *resultArray = [NSMutableArray arrayWithObject:@{ @"type" : @(type)}];
            for (int i = 0; i < valueArray.count; i++)
            {
                NSObject<NSCopying> *arValue = valueArray[i];
                
                if (([arValue isKindOfClass:[NSString class]]) || ([arValue isKindOfClass:[NSNumber class]]))
                {
                    [resultArray addObject:arValue];
                }
                else
                {
                    CGImageMetadataTagRef arTag = (__bridge CGImageMetadataTagRef)valueArray[i];
                    NSString *name = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyName(arTag));
                    NSObject<NSCopying> *value = [self valueFromTag:arTag];
                    
                    [resultArray addObject:@{ name : value }];
                }
            }
            
            return [resultArray copy];
        }
            
        case kCGImageMetadataTypeStructure:
        {
            NSDictionary *valueDict = CFBridgingRelease(CGImageMetadataTagCopyValue(tag));
            NSMutableDictionary *resultDict = [NSMutableDictionary new];
            for (int i = 0; i < valueDict.allKeys.count; i++)
            {
                NSString *key = valueDict.allKeys[i];
                NSObject<NSCopying> *keyValue = valueDict[key];
                
                if (([keyValue isKindOfClass:[NSString class]]) || ([keyValue isKindOfClass:[NSNumber class]]))
                {
                    [resultDict setObject:keyValue forKey:key];
                }
                else
                {
                    CGImageMetadataTagRef dTag = (__bridge CGImageMetadataTagRef)valueDict[key];
                    
                    NSString *prefix = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyPrefix(dTag));
                    NSString *name = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyName(dTag));
                    NSString *namespace = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyNamespace(dTag));
                    NSObject<NSCopying> *value = [self valueFromTag:dTag];
                    
                    NSString *dKey = name;
                    NSString *parentPrefix = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyPrefix(tag));
                    NSString *parentNamespace = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyNamespace(tag));
                    BOOL samePrefix = [prefix isEqualToString:parentPrefix];
                    BOOL sameNamespace = [namespace isEqualToString:parentNamespace];
                    if ( !sameNamespace ) {
                        dKey = [NSString stringWithFormat:@"%@:%@:%@", namespace, prefix, name];
                    }
                    else if (!samePrefix) {
                        dKey = [NSString stringWithFormat:@"%@:%@", prefix, name];
                    }
                    
                    if ([dKey isEqualToString:key])
                    {
                        [resultDict setObject:value forKey:key];
                    }
                    else
                    {
                        [resultDict setObject:@{dKey : value} forKey:key];
                    }
                }
            }
            return resultDict;
        }
            
        default:
            break;
    }
    
    NSLog(@"UNSUPPORTED TAG - %@", tag);
    return nil;
}

#pragma mark RESIZING

#pragma mark Image

- (nonnull UIImage *)resizeAspect:(CGFloat)newAspect
                            image:(nonnull UIImage *)image
{
    NSAssert(image, @"Unexpected NIL!");
    
    CGFloat aspect = image.size.width/image.size.height;
    
    if (aspect != newAspect)
    {
        CGFloat delta = newAspect/aspect;
        CGSize renderSize = CGSizeMake(image.size.width * delta, image.size.height);
        
        return [self resize:renderSize image:image];
    }
    
    return image;
}

- (BOOL)resizeAspect:(CGFloat)aspect
               image:(nonnull UIImage *)image
      withProperties:(nullable NSDictionary *)props
         andWriteURL:(nonnull NSURL *)url
{
    NSAssert(image && url, @"Unexpected NIL!");
    
    UIImage *resized = [self resizeAspect:aspect image:image];
    
    return [self processResizedImage:resized location:nil creationDate:nil otherProperties:props andWriteURL:url];
}

- (BOOL)resize:(CGSize)size
         image:(nonnull UIImage *)image
withProperties:(nullable NSDictionary *)props
   andWriteURL:(nonnull NSURL *)url
{
    NSAssert(image && url, @"Unexpected NIL!");
    
    UIImage *resized = [self resize:size image:image];
    
    return [self processResizedImage:resized location:nil creationDate:nil otherProperties:props andWriteURL:url];
}

- (BOOL)addLocation:(nullable CLLocation *)location
       creationDate:(nullable NSDate *)date
            toImage:(nonnull UIImage *)image
     withProperties:(nullable NSDictionary *)props
        andWriteURL:(nonnull NSURL *)url
{
    NSAssert(image && url, @"Unexpected NIL!");
    
    return [self processResizedImage:image location:location creationDate:date otherProperties:props andWriteURL:url];
}

- (BOOL)resizeAspect:(CGFloat)aspect
         addLocation:(nullable CLLocation *)location
        creationDate:(nullable NSDate *)date
               image:(nonnull UIImage *)image
      withProperties:(nullable NSDictionary *)props
         andWriteURL:(nonnull NSURL *)url
{
    NSAssert(image && url, @"Unexpected NIL!");
    
    UIImage *resized = [self resizeAspect:aspect image:image];
    
    return [self processResizedImage:resized location:location creationDate:date otherProperties:props andWriteURL:url];
}

- (BOOL)resize:(CGSize)size
   addLocation:(nullable CLLocation *)location
  creationDate:(nullable NSDate *)date
       toImage:(nonnull UIImage *)image
withProperties:(nullable NSDictionary *)props
   andWriteURL:(nonnull NSURL *)url
{
    NSAssert(image && url, @"Unexpected NIL!");
    
    UIImage *resized = [self resize:size image:image];
    
    return [self processResizedImage:resized location:location creationDate:date otherProperties:props andWriteURL:url];
}

#pragma mark Image at URL

- (BOOL)resizeAspect:(CGFloat)aspect
          imageAtURL:(nonnull NSURL *)imageURL
         andWriteURL:(nonnull NSURL *)url
{
    NSAssert(imageURL && url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", imageURL);
        return NO;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    if (image == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image from source");
        CFRelease(source);
        return NO;
    }
    
    NSDictionary *props = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    
    BOOL result = [self resizeAspect:aspect image:[UIImage imageWithCGImage:image] withProperties:props andWriteURL:url];
    
    CFRelease(source);
    CGImageRelease(image);
    
    return result;
}

- (BOOL)resize:(CGSize)size
    imageAtURL:(nonnull NSURL *)imageURL
   andWriteURL:(nonnull NSURL *)url
{
    NSAssert(imageURL && url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", imageURL);
        return NO;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    if (image == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image from source");
        CFRelease(source);
        return NO;
    }
    
    NSDictionary *props = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    
    BOOL result = [self resize:size image:[UIImage imageWithCGImage:image] withProperties:props andWriteURL:url];
    
    CFRelease(source);
    CGImageRelease(image);
    
    return result;
}

- (BOOL)addLocation:(nullable CLLocation *)location
       creationDate:(nullable NSDate *)date
       toImageAtURL:(nonnull NSURL *)imageURL
        andWriteURL:(nonnull NSURL *)url
{
    NSAssert(imageURL && url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", imageURL);
        return NO;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    if (image == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image from source");
        CFRelease(source);
        return NO;
    }
    
    NSDictionary *props = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    
    BOOL result = [self addLocation:location creationDate:date toImage:[UIImage imageWithCGImage:image] withProperties:props andWriteURL:url];
    
    CFRelease(source);
    CGImageRelease(image);
    
    return result;
}

- (BOOL)resizeAspect:(CGFloat)aspect
         addLocation:(nullable CLLocation *)location
        creationDate:(nullable NSDate *)date
          imageAtURL:(nonnull NSURL *)imageURL
         andWriteURL:(nonnull NSURL *)url
{
    NSAssert(imageURL && url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", imageURL);
        return NO;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    if (image == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image from source");
        CFRelease(source);
        return NO;
    }
    
    NSDictionary *props = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    
    BOOL result = [self resizeAspect:aspect addLocation:location creationDate:date image:[UIImage imageWithCGImage:image] withProperties:props andWriteURL:url];
    
    CFRelease(source);
    CGImageRelease(image);
    
    return result;
}

- (BOOL)resize:(CGSize)size
   addLocation:(nullable CLLocation *)location
  creationDate:(nullable NSDate *)date
  toImageAtURL:(nonnull NSURL *)imageURL
   andWriteURL:(nonnull NSURL *)url
{
    NSAssert(imageURL && url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", imageURL);
        return NO;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    if (image == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image from source");
        CFRelease(source);
        return NO;
    }
    
    NSDictionary *props = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    
    BOOL result = [self resize:size addLocation:location creationDate:date toImage:[UIImage imageWithCGImage:image] withProperties:props andWriteURL:url];
    
    CFRelease(source);
    CGImageRelease(image);
    
    return result;
}

#pragma mark Private

- (BOOL)processResizedImage:(nonnull UIImage *)image
                   location:(nullable CLLocation *)location
               creationDate:(nullable NSDate *)date
            otherProperties:(nullable NSDictionary *)props
                andWriteURL:(nonnull NSURL *)url
{
    NSMutableDictionary *mutProps = [props mutableCopy];
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    NSMutableDictionary *EXIFDictionary = [props[(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    if(EXIFDictionary == nil)
    {
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    [EXIFDictionary setValue:@(width) forKey:(NSString*)kCGImagePropertyExifPixelXDimension];
    [EXIFDictionary setValue:@(height) forKey:(NSString*)kCGImagePropertyExifPixelYDimension];
    
    if (date)
    {
        NSString *dateString = [self getUTCFormattedDate:date];
        [EXIFDictionary setValue:dateString forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    }
    
    [mutProps setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    
    if (location)
    {
        NSMutableDictionary *GPSDictionary = [props[(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
        if(GPSDictionary == nil)
        {
            GPSDictionary = [NSMutableDictionary dictionary];
        }
        
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        
        NSString *latitudeRef = nil;
        NSString *longitudeRef = nil;
        
        if (latitude < 0.0) {
            latitude *= -1;
            latitudeRef = @"S";
        } else {
            latitudeRef = @"N";
        }
        
        if (longitude < 0.0) {
            longitude *= -1;
            longitudeRef = @"W";
        } else {
            longitudeRef = @"E";
        }
        
        GPSDictionary[(NSString*)kCGImagePropertyGPSTimeStamp] = [self getUTCFormattedDate:location.timestamp];
        GPSDictionary[(NSString*)kCGImagePropertyGPSLatitudeRef] = latitudeRef;
        GPSDictionary[(NSString*)kCGImagePropertyGPSLatitude] = @(latitude);
        GPSDictionary[(NSString*)kCGImagePropertyGPSLongitudeRef] = longitudeRef;
        GPSDictionary[(NSString*)kCGImagePropertyGPSLongitude] = @(longitude);
        GPSDictionary[(NSString*)kCGImagePropertyGPSDOP] = @(location.horizontalAccuracy);
        GPSDictionary[(NSString*)kCGImagePropertyGPSAltitude] = @(location.altitude);
        
        [mutProps setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    
    [mutProps setObject:@(0) forKey:@"Orientation"];
    [mutProps setObject:@(width) forKey:(NSString*)kCGImagePropertyPixelWidth];
    [mutProps setObject:@(height) forKey:(NSString*)kCGImagePropertyPixelHeight];
    
    return [self processImage:image properties:mutProps meta:nil aux:nil atURL:url];
}

- (BOOL)processImage:(nonnull UIImage *)image
          properties:(nullable NSDictionary *)properties
                meta:(CGImageMetadataRef)meta
                 aux:(NSDictionary *)aux
               atURL:(nonnull NSURL *)url
{
    BOOL result = YES;
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)UIImageJPEGRepresentation(image, 1.0), NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source from image");
        return NO;
    }
    
    NSMutableData *dest_data = [NSMutableData data];
    CFStringRef UTI = CGImageSourceGetType(source);
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
    if(destination == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image destination");
        CFRelease(source);
        return NO;
    }
    
    if (meta != NULL)
    {
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)properties);
        CGImageDestinationAddImageAndMetadata(destination, image.CGImage, meta, NULL);
    }
    else
    {
        CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)properties);
    }
    
    for (NSString *type in aux.allKeys)
    {
        CGImageDestinationAddAuxiliaryDataInfo(destination, (CFStringRef)type, (CFDictionaryRef)(aux[type]));
    }
    
    result = CGImageDestinationFinalize(destination);
    if (result == NO)
    {
        CFRelease(destination);
        CFRelease(source);
        return NO;
    }
    
    result = [dest_data writeToURL:url atomically:YES];
    if (result == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not write image data at URL: %@", url);
    }
    
    CFRelease(destination);
    CFRelease(source);
    
    return result;
}

- (NSString *)getUTCFormattedDate:(NSDate *)localDate
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      dateFormatter = [[NSDateFormatter alloc] init];
                      [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
                  });
    
    return [dateFormatter stringFromDate:localDate];
}

- (UIImage *)resize:(CGSize)size image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
