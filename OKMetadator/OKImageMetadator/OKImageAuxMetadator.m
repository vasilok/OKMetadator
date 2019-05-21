//
//  OKImageAuxMetadator.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/20/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageAuxMetadator.h"
#import <os/log.h>
#import "OKImageMetadator+Common.h"

// for depth data
#import <AVFoundation/AVFoundation.h>


@implementation OKImageMetadator (OKImageAuxMetadator)

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

- (nullable OKMetaParam *)fullMetaParamsFromImageAtURL:(nonnull NSURL *)url
{
    NSMutableDictionary *full = [NSMutableDictionary new];
    
    [full addEntriesFromDictionary:[self metaParamsFromImageAtURL:url]];
    [full addEntriesFromDictionary:[self auxMetaParamsFromImageAtURL:url]];
    
    return [full copy];
}

- (nullable NSDictionary *)auxMetadataFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSMutableDictionary *aux = [NSMutableDictionary new];
    
    NSDictionary *depth = [self auxMetadataFromSource:source withType:AUX_DEPTH];
    if (depth) {
        [aux setObject:depth forKey:CFS(AUX_DEPTH)];
    }
    
    NSDictionary *disparity = [self auxMetadataFromSource:source withType:AUX_DISPARITY];
    if (disparity) {
        [aux setObject:disparity forKey:CFS(AUX_DISPARITY)];
    }
    
    if (@available(iOS 12.0, *)) {
        NSDictionary *matte = [self auxMetadataFromSource:source withType:AUX_MATTE];
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

- (nullable NSDictionary *)auxMetadataFromImageAtURL:(nonnull NSURL *)url withType:(CFStringRef)type
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSDictionary *dict = CFBridgingRelease(CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, type));
    CFRelease(source);
    
    return dict;
}

- (nullable NSDictionary *)auxMetadataFromParams:(OKMetaParam *)aux
{
    NSMutableDictionary *dictMeta = [NSMutableDictionary new];
    
    OKMetaParam *depth = (OKMetaParam *)aux[CFS(AUX_DEPTH)];
    if (depth) {
        NSDictionary *depthDict = [self auxMetadataFromParams:depth withType:AUX_DEPTH];
        [dictMeta setObject:depthDict forKey:CFS(AUX_DEPTH)];
    }
    
    OKMetaParam *disparity = (OKMetaParam *)aux[CFS(AUX_DISPARITY)];
    if (disparity) {
        NSDictionary *dispDict = [self auxMetadataFromParams:disparity withType:AUX_DISPARITY];
        [dictMeta setObject:dispDict forKey:CFS(AUX_DISPARITY)];
    }
    
    if (@available(iOS 12.0, *)) {
        OKMetaParam *matte = (OKMetaParam *)aux[CFS(AUX_MATTE)];
        if (matte) {
            NSDictionary *matteDict = [self auxMetadataFromParams:matte withType:AUX_MATTE];
            [dictMeta setObject:matteDict forKey:CFS(AUX_MATTE)];
        }
    }
    
    return dictMeta;
}

- (BOOL)setPortraitToMeta:(_Nonnull CGMutableImageMetadataRef)meta
{
    CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)AdobeExifNamespace, (CFStringRef)exif, NULL);
    CGImageMetadataTagRef tag = CGImageMetadataTagCreate((CFStringRef)AdobeExifNamespace,
                                                         (CFStringRef)exif,
                                                         (CFStringRef)CustomRendered,
                                                         kCGImageMetadataTypeString,
                                                         (__bridge CFTypeRef)@(8));
    if (tag) {
        CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(exif, CustomRendered), tag);
        CFRelease(tag);
        
        return YES;
    }
    
    return NO;
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
            result[CFS(AUX_MATTE)] = matteImage;
        }
    }
    
    return result;
}

- (void)setAuxParams:(nullable NSDictionary *)aux toDestination:(_Nonnull CGImageDestinationRef)destination
{
    NSDictionary *auxMeta = [self auxMetadataFromParams:aux];
    
    [self setAuxMetadata:auxMeta toDestination:destination];
}

- (void)setAuxMetadata:(nullable NSDictionary *)aux toDestination:(_Nonnull CGImageDestinationRef)destination
{
    if (aux[CFS(AUX_DEPTH)]) {
        CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_DEPTH, (CFDictionaryRef)aux[CFS(AUX_DEPTH)]);
    }
    
    if (aux[CFS(AUX_DISPARITY)]) {
        CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_DISPARITY, (CFDictionaryRef)aux[CFS(AUX_DISPARITY)]);
    }
    
    if (@available(iOS 12.0, *)) {
        if (aux[CFS(AUX_MATTE)]) {
            CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_MATTE, (CFDictionaryRef)aux[CFS(AUX_MATTE)]);
        }
    }
}

- (BOOL)applyMap:(nonnull UIImage *)map
      forImageAt:(nonnull NSURL *)imageURL
      andWriteAt:(nonnull NSURL *)url
{
    // try resave
    // map the same image (from imageURL)
    
    CIImage *ciImage = [CIImage imageWithCGImage:map.CGImage];
    CIImage *filtered = [ciImage imageByApplyingFilter:@"CISepiaTone" withInputParameters:@{kCIInputIntensityKey : @(0.5)}];
    CGImageRef processed = [[CIContext context] createCGImage:filtered fromRect:filtered.extent];
    UIImage *result = [UIImage imageWithCGImage:processed];
    
    // не важно
    NSDictionary *props = nil;//[self propertiesFromImageAtURL:imageURL];
    
    // важно! для портрета нужен только 1 флаг - exif:CustomRendered = 8
    CGImageMetadataRef meta = [self metaFromImageAtURL:imageURL]; // !!!!!!!!!
    
    // не работает
    //    NSDictionary *okMetaDict = [self metaParamsFromMetadata:meta];
    //    CGImageMetadataRef okMeta = [self metadataFromMetaParams:okMetaDict];
    
    CGImageMetadataRef newMeta =[self metaFromMeta:meta];
    
    NSDictionary *aux = [self auxMetadataFromImageAtURL:imageURL];
    
    return [self writeImage:result withMeta:newMeta auxDict:aux properties:props atURL:url];
}

- (BOOL)applyMap:(nonnull UIImage *)map
        forImage:(nonnull UIImage *)image
      andWriteAt:(nonnull NSURL *)url
{
    NSAssert(map && image && url, @"Unexpected NIL!");
    
    CGFloat resizeKoef = 5.25;
    CGSize resize = CGSizeMake(image.size.width/resizeKoef, image.size.height/resizeKoef);
    UIImage *resizedMap = [self resize:resize image:map];
    
    NSDictionary *matteRepresentation = nil;//[self matteRepresentationWithImage:map];
    NSDictionary *disparityRepresentation = [self disparityRepresentationWithImage:resizedMap];
    NSDictionary *depthRepresentation = nil;//[self depthRepresentationWithImage:resizedMap];
    
    if (!disparityRepresentation && !matteRepresentation && !depthRepresentation) {
        return NO;
    }
    
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
    
    CGImageMetadataRef portraitMeta = [self portraitMetadata];
    if (portraitMeta) {
        CGImageDestinationAddImageAndMetadata(destination, image.CGImage, portraitMeta, NULL);
    }
    else {
        CGImageDestinationAddImage(destination, image.CGImage, NULL);
    }
    
    if (disparityRepresentation) {
        CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_DISPARITY, (CFDictionaryRef)disparityRepresentation);
    }
    if (depthRepresentation) {
        CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_DEPTH, (CFDictionaryRef)depthRepresentation);
    }
    if (matteRepresentation) {
        if (@available(iOS 12.0, *)) {
            CGImageDestinationAddAuxiliaryDataInfo(destination, AUX_MATTE, (CFDictionaryRef)matteRepresentation);
        }
    }
    
    result = CGImageDestinationFinalize(destination);
    if (result == NO)
    {
        CFRelease(destination);
        CFRelease(source);
        if (portraitMeta) {
            CFRelease(portraitMeta);
        }
        return NO;
    }
    
    result = [dest_data writeToURL:url atomically:YES];
    if (result == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not write image data at URL: %@", url);
    }
    
    CFRelease(destination);
    CFRelease(source);
    if (portraitMeta) {
        CFRelease(portraitMeta);
    }
    
    return result;
}

#pragma mark Private

- (NSDictionary *)auxMetadataFromSource:(CGImageSourceRef)source withType:(CFStringRef)type
{
    return CFBridgingRelease(CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, type));
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

- (nullable NSDictionary *)auxMetadataFromParams:(nonnull OKMetaParam *)aux withType:(CFStringRef)type
{
    NSMutableDictionary *dict = [aux mutableCopy];
    
    if (aux)
    {
        CGImageMetadataRef metadata = [self metadataFromMetaParams:aux];
        if (metadata) {
            dict[CFS(AUX_META)] = (__bridge id _Nullable)(metadata);
        }
        CFRelease(metadata);
    }
    
    return [dict copy];
}

- (nullable UIImage *)imageFromImageSource:(CGImageSourceRef)source withAuxType:(CFStringRef)type
{
    NSDictionary *depthDict = CFBridgingRelease(CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, type));
    if (depthDict)
    {
        NSError *error;
        CIImage *ciImage;
        
        if ((type == AUX_DISPARITY) || (type == AUX_DEPTH))
        {
            AVDepthData *depthData = [AVDepthData depthDataFromDictionaryRepresentation:depthDict
                                                                                  error:&error];
            
            if (depthData == nil) {
                os_log_error(OS_LOG_DEFAULT, "Could not create deapth data from source with error %@", error);
            }
            
            if (depthData.depthDataType != kCVPixelFormatType_DisparityFloat16) {
                depthData = [depthData depthDataByConvertingToDepthDataType:kCVPixelFormatType_DisparityFloat16];
            }
            
            ciImage = [CIImage imageWithDepthData:depthData];
        }
        else if (@available(iOS 12.0, *)) {
            
            AVPortraitEffectsMatte *matteData = [AVPortraitEffectsMatte portraitEffectsMatteFromDictionaryRepresentation:depthDict
                                                                                                                   error:&error];
            if (matteData == nil) {
                os_log_error(OS_LOG_DEFAULT, "Could not create matte data from source with error %@", error);
            }
            
            if (matteData.pixelFormatType != kCVPixelFormatType_OneComponent8) {
                os_log_error(OS_LOG_DEFAULT, "Matte data has invalid pixel format !");
            }
            
            ciImage = [CIImage imageWithPortaitEffectsMatte:matteData];
        }
        
        CGImageRef cgImage = [[CIContext context] createCGImage:ciImage fromRect:ciImage.extent];
        return [UIImage imageWithCGImage:cgImage];
    }
    
    return nil;
}

#pragma mark Portrait key

- (CGImageMetadataRef)portraitMetadata
{
    CGMutableImageMetadataRef result = CGImageMetadataCreateMutable();
    
    [self setPortraitToMeta:result];
    
    return result;
}

#pragma mark Representations

- (NSDictionary *)matteRepresentationWithImage:(UIImage *)image
{
    NSError *error;
    NSDictionary *matteMeta = [self matteMetadataWithImage:image];
    
    if (!matteMeta) {
        return nil;
    }
    
    NSDictionary *result = nil;
    
    if (@available(iOS 12.0, *)) {
        AVPortraitEffectsMatte *matteData = [AVPortraitEffectsMatte portraitEffectsMatteFromDictionaryRepresentation:matteMeta
                                                                                                               error:&error];
        
        if (matteData == nil) {
            os_log_error(OS_LOG_DEFAULT, "Could not create matte data with error %@", error);
            return nil;
        }
        
        NSString *typeP = CFS(AUX_MATTE);
        result = [matteData dictionaryRepresentationForAuxiliaryDataType:&typeP];
    }
    
    return result;
}

- (NSDictionary *)disparityRepresentationWithImage:(UIImage *)image
{
    NSError *error;
    NSDictionary *disparityMeta = [self disparityMetadataWithImage:image];
    
    if (!disparityMeta) {
        return nil;
    }
    
    AVDepthData *disparityData = [AVDepthData depthDataFromDictionaryRepresentation:disparityMeta error:&error];
    if (disparityData == nil) {
        os_log_error(OS_LOG_DEFAULT, "Could not create disparity data with error %@", error);
        return nil;
    }
    
    NSString *type = CFS(AUX_DISPARITY);
    return [disparityData dictionaryRepresentationForAuxiliaryDataType:&type];
}

- (NSDictionary *)disparityMetadataWithImage:(UIImage *)image
{
 //   CGImageRef cgImage = image.CGImage;
    
    //    CGColorSpaceRef coloSpace = CGImageGetColorSpace(cgImage);
    //    CGImagePixelFormatInfo pixelInfo = CGImageGetPixelFormatInfo(cgImage);
    //    CGImageByteOrderInfo order = CGImageGetByteOrderInfo(cgImage);
    //    CGBitmapInfo bitmap = CGImageGetBitmapInfo(cgImage);
    //    size_t bytesPer = CGImageGetBytesPerRow(cgImage);
    
//    CIImage *ciImage = [CIImage imageWithCGImage:cgImage];
//    CIFilter *invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
//    [invertFilter setDefaults];
//    [invertFilter setValue:ciImage forKey: kCIInputImageKey];
//    CIImage *filtered = [invertFilter outputImage];
//
//    CIFilter *dispFilter = [CIFilter filterWithName:@"CIDepthToDisparity"];
//    [dispFilter setDefaults];
//    [dispFilter setValue:filtered forKey: kCIInputImageKey];
//
//    filtered = [dispFilter outputImage];
//    CGImageRef filteredCGImage = [[CIContext context] createCGImage:filtered fromRect:filtered.extent];
    
    
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage),
                                          kCVPixelFormatType_DisparityFloat16, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage), 16, CVPixelBufferGetBytesPerRow(pxbuffer), grayColorSpace, kCGImageAlphaNone);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage)), image.CGImage);
    CGColorSpaceRelease(grayColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(pxbuffer);
    size_t height = CVPixelBufferGetHeight(pxbuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    OSType format = kCVPixelFormatType_DisparityFloat16;
    size_t size = CVPixelBufferGetDataSize(pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *addr = CVPixelBufferGetBaseAddress(pxbuffer);
    NSData *pbData = [NSData dataWithBytes:addr length:size];
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CFRelease(pxbuffer);
    
    CGImageMetadataRef meta = [self metadataFromMetaParams:@{
                                                             AppleNamespace : @{ PP(ImageIO, hasXMP) : @YES },
                                                             AppleDepthNamespace : @{ PP(ADepth, Accuracy) : @"relative",
                                                                                      PP(ADepth, Filtered) : @"true",
                                                                                      PP(ADepth, Quality) : @"high"
                                                                                      }
                                                             }];
    
    if (!meta) {
        return nil;
    }
    
    return @{
             CFS(AUX_DATA) : pbData,
             CFS(AUX_INFO) : @{
                     AUX_WIDTH : @(width),
                     AUX_HEIGHT : @(height),
                     AUX_BYTES_PER_ROW : @(bytesPerRow),
                     AUX_PIXEL_FORMAT : @(format)
                     },
             CFS(AUX_META) : CFBridgingRelease(meta)
             };
}

- (NSDictionary *)matteMetadataWithImage:(UIImage *)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage),
                                          kCVPixelFormatType_OneComponent8, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage), 8, CVPixelBufferGetBytesPerRow(pxbuffer), grayColorSpace, kCGImageAlphaNone);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage)), image.CGImage);
    CGColorSpaceRelease(grayColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(pxbuffer);
    size_t height = CVPixelBufferGetHeight(pxbuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    OSType format = kCVPixelFormatType_OneComponent8;
    size_t size = CVPixelBufferGetDataSize(pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *addr = CVPixelBufferGetBaseAddress(pxbuffer);
    NSData *pbData = [NSData dataWithBytes:addr length:size];
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CFRelease(pxbuffer);
    
    CGImageMetadataRef meta = [self metadataFromMetaParams:@{
                                                             AppleNamespace : @{ PP(ImageIO, hasXMP) : @"true" },
                                                             AppleMatteNamespace : @{ PP(AMatte, @"PortraitEffectsMatteVersion") : @(65536) }
                                                             }];
    
    if (!meta) {
        return nil;
    }
    
    return @{
             CFS(AUX_DATA) : pbData,
             CFS(AUX_INFO) : @{
                     AUX_WIDTH : @(width),
                     AUX_HEIGHT : @(height),
                     AUX_BYTES_PER_ROW : @(bytesPerRow),
                     AUX_PIXEL_FORMAT : @(format)
                     },
             CFS(AUX_META) : CFBridgingRelease(meta)
             };
}

- (NSDictionary *)depthRepresentationWithImage:(UIImage *)image
{
    NSError *error;
    NSDictionary *depthMeta = [self depthMetadataWithImage:image];
    
    if (!depthMeta) {
        return nil;
    }
    
    AVDepthData *depthData = [AVDepthData depthDataFromDictionaryRepresentation:depthMeta error:&error];
    if (depthData == nil) {
        os_log_error(OS_LOG_DEFAULT, "Could not create disparity data with error %@", error);
        return nil;
    }
    
    NSString *type = CFS(AUX_DEPTH);
    return [depthData dictionaryRepresentationForAuxiliaryDataType:&type];
}

- (NSDictionary *)depthMetadataWithImage:(UIImage *)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage),
                                          kCVPixelFormatType_DepthFloat16, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage), 16, CVPixelBufferGetBytesPerRow(pxbuffer), grayColorSpace, kCGImageAlphaNone);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage)), image.CGImage);
    CGColorSpaceRelease(grayColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(pxbuffer);
    size_t height = CVPixelBufferGetHeight(pxbuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    OSType format = kCVPixelFormatType_DepthFloat16;
    size_t size = CVPixelBufferGetDataSize(pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *addr = CVPixelBufferGetBaseAddress(pxbuffer);
    NSData *pbData = [NSData dataWithBytes:addr length:size];
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CFRelease(pxbuffer);
    
    CGImageMetadataRef meta = [self metadataFromMetaParams:@{
                                                             AppleNamespace : @{ PP(ImageIO, hasXMP) : @"true" },
                                                             AppleDepthNamespace : @{ PP(ADepth, Accuracy) : @"relative",
                                                                                      PP(ADepth, Filtered) : @"true",
                                                                                      PP(ADepth, Quality) : @"high"
                                                                                      }
                                                             }];
    
    if (!meta) {
        return nil;
    }
    
    return @{
             CFS(AUX_DATA) : pbData,
             CFS(AUX_INFO) : @{
                     AUX_WIDTH : @(width),
                     AUX_HEIGHT : @(height),
                     AUX_BYTES_PER_ROW : @(bytesPerRow),
                     AUX_PIXEL_FORMAT : @(format)
                     },
             CFS(AUX_META) : CFBridgingRelease(meta)
             };
}


#pragma mark Stabs

- (CGImageMetadataRef)metaFromMeta:(CGImageMetadataRef)meta
{
    CGMutableImageMetadataRef result = CGImageMetadataCreateMutable();
    
    /*
     CGImageMetadataEnumerateTagsUsingBlock(meta, NULL, NULL, ^bool(CFStringRef  _Nonnull path, CGImageMetadataTagRef  _Nonnull tag) {
     NSString *prefix = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyPrefix(tag));
     NSString *name = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyName(tag));
     NSString *namespace = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyNamespace(tag));
     
     // не нужно для определения портрета !!!!!! но без нее нет DepthData  и похоже не сохраняется aux meta!
     if ([namespace isEqualToString:@"http://www.metadataworkinggroup.com/schemas/regions/"]) {
     NSLog(@"REMOVE metadataworkinggroup");
     return true;
     }
     
     // не нужно для определения портрета !!!!!!
     if ([namespace isEqualToString:@"http://cipa.jp/exif/1.0/"]) {
     NSLog(@"REMOVE cipa");
     return true;
     }
     
     // не нужно для определения портрета !!!!!!
     if ([namespace isEqualToString:@"http://purl.org/dc/elements/1.1/"]) {
     NSLog(@"REMOVE purl");
     return true;
     }
     
     // не нужно для определения портрета !!!!!!
     if ([namespace isEqualToString:@"http://ns.adobe.com/xap/1.0/"] || [namespace isEqualToString:@"http://ns.adobe.com/photoshop/1.0/"]) {
     NSLog(@"REMOVE xap/photoshop");
     return true;
     }
     
     // не нужно для определения портрета !!!!!!
     if ([namespace isEqualToString:@"http://ns.adobe.com/tiff/1.0/"]) {
     NSLog(@"REMOVE tiff");
     return true;
     }
     
     // не нужно для определения портрета !!!!!!
     if ([namespace isEqualToString:@"http://ns.apple.com/ImageIO/1.0/"]) {
     NSLog(@"REMOVE ImageIO");
     return true;
     }
     
     // ВЛИЯЕТ!
     if ([namespace isEqualToString:@"http://ns.adobe.com/exif/1.0/"]) {
     //NSLog(@"REMOVE exif");
     return true;
     // check TAG
     
     //                "exif:CustomRendered" = 8;
     //                "exif:ExifVersion" = 0221;
     //                "exif:ExposureBiasValue" = "0/1";
     //                "exif:ExposureMode" = 0;
     //                "exif:ExposureProgram" = 2;
     //                "exif:ExposureTime" = "1/50";
     //                "exif:FNumber" = "12/5";
     //                "exif:Flash" =
     //                "exif:FlashPixVersion" = 0100;
     //                "exif:FocalLenIn35mmFilm" = 52;
     //                "exif:FocalLength" = "6/1";
     //                "exif:ISOSpeedRatings" =
     //                "exif:MeteringMode" = 5;
     //                "exif:PixelXDimension" = 3024;
     //                "exif:PixelYDimension" = 4032;
     //                "exif:SceneCaptureType" = 0;
     //                "exif:SceneType" = 1;
     //                "exif:SensingMethod" = 2;
     //                "exif:ShutterSpeedValue" = "16689/2956";
     //                "exif:SubsecTimeDigitized" = 564;
     //                "exif:SubsecTimeOriginal" = 564;
     //                "exif:UserComment" = "Created with DepthCam";
     //                "exif:WhiteBalance" = 0;
     
     //               if ([name isEqualToString:@"SubjectArea"] ||
     //                    [name isEqualToString:@"ApertureValue"] ||
     //                    [name isEqualToString:@"BrightnessValue"] ||
     //                    [name isEqualToString:@"ColorSpace"] ||
     //                    [name isEqualToString:@"ComponentsConfiguration"] ||
     
     
     // !!!!!!!!!
     //                    [name isEqualToString:@"CustomRendered"])
     //                {
     //                    NSLog(@"REMOVE exif tag: %@", name);
     //                    return true;
     //                }
     }
     
     CGImageMetadataRegisterNamespaceForPrefix(result, (CFStringRef)namespace, (CFStringRef)prefix, NULL);
     CGImageMetadataSetTagWithPath(result, NULL, (CFStringRef)path, tag);
     
     return true;
     });
     */
    CGImageMetadataRegisterNamespaceForPrefix(result, (CFStringRef)@"http://ns.adobe.com/exif/1.0/", (CFStringRef)@"exif", NULL);
    CGImageMetadataTagRef tag = CGImageMetadataTagCreate((CFStringRef)@"http://ns.adobe.com/exif/1.0/",
                                                         (CFStringRef)@"exif",
                                                         (CFStringRef)@"CustomRendered",
                                                         kCGImageMetadataTypeString,
                                                         (__bridge CFTypeRef)@(8));
    CGImageMetadataSetTagWithPath(result, NULL, (CFStringRef)@"exif:CustomRendered", tag);
    
    return result;
}

- (NSDictionary *)stabMetaParamsForAppleDepthWithImage:(UIImage *)image
{
    return @{
             @"http://cipa.jp/exif/1.0/" : @{
                     @"exifEX:LensMake" : @"Apple",
                     @"exifEX:LensModel" : @"iPhone XS Max back dual camera 6mm f/2.4",
                     @"exifEX:LensSpecification" : @[
                             @{@"[0]" : @"17/4"},
                             @{@"[1]" : @"6/1"},
                             @{@"[2]" : @"9/5"},
                             @{@"[3]" : @"12/5"},
                             ],
                     @"exifEX:PhotographicSensitivity" : @(100)
                     },
             @"http://ns.apple.com/ImageIO/1.0/" : @{
                     @"iio:hasXMP" : @"true"
                     },
             @"http://purl.org/dc/elements/1.1/" : @{
                     @"dc:description" :  @[
                             @{@"[x-default]" : @"Created with DepthCam"},
                             @{@"Qualifiers" : @[ @{@"xml:lang" : @"x-default"} ] },
                             ]
                     },
             @"http://ns.adobe.com/xap/1.0/" :  @{
                     @"xmp:CreateDate" : @"2019-05-08T10:07:17.564",
                     @"xmp:CreatorTool" : @"12.2",
                     @"xmp:ModifyDate" : @"2019-05-08T10:07:17"
                     },
             @"http://ns.adobe.com/tiff/1.0/" : @{
                     @"tiff:Make" : @"Apple",
                     @"tiff:Model" : @"iPhone XS Max",
                     @"tiff:Orientation" : @(0),
                     @"tiff:ResolutionUnit" : @(2),
                     @"tiff:XResolution" : @"72/1",
                     @"tiff:YResolution" : @"72/1",
                     @"tiff:_YCbCrPositioning" : @(1)
                     },
             //             @"http://www.metadataworkinggroup.com/schemas/regions/" : @{
             //                     @"mwg-rs:Regions" : @{
             //                             @"AppliedToDimensions" : @{
             //                                     @"h" : @{ @"http://ns.adobe.com/xap/1.0/sType/Dimensions#:stDim:h" : @(image.size.height) },
             //                                     @"w" : @{ @"http://ns.adobe.com/xap/1.0/sType/Dimensions#:stDim:w" : @(image.size.width) },
             //                                     @"unit" : @{ @"http://ns.adobe.com/xap/1.0/sType/Dimensions#:stDim:unit" : @"pixel" }
             //                                     },
             //                             @"RegionList" : @[
             //                                     ]
             //                             }
             //                     }
             };
}

// не нужно !
//- (NSDictionary *)stabPropertiesForAppleDepthWithImage:(UIImage *)image
//{
//    return @{
//             (NSString *)kCGImagePropertyExifAuxDictionary : @{
//                     @"Regions" : @{
//                             @"HeightAppliedTo" : @((int)image.size.height),
//                             @"RegionList" : @[
//                                               @{
//                                                   @"Height": @(0.182),
//                                                   @"Type" : @"Focus",
//                                                   @"Width" : @(0.08299999999999999),
//                                                   @"X" : @(0.2555),
//                                                   @"Y" : @(0.414)
//                                               }
//                                               ],
//                             @"WidthAppliedTo" : @((int)image.size.width)
//                     }
//                 },
//             (NSString *)kCGImagePropertyIPTCDictionary :  @{
//                     @"Caption/Abstract" : @"Created with DepthCam"
//                 },
//             (NSString *)kCGImagePropertyMakerAppleDictionary : @{
//                 }
//             };
//}

@end
