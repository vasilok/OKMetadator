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
        if (depthDict) {
            [dictMeta setObject:depthDict forKey:CFS(AUX_DEPTH)];
        }
    }
    
    OKMetaParam *disparity = (OKMetaParam *)aux[CFS(AUX_DISPARITY)];
    if (disparity) {
        NSDictionary *dispDict = [self auxMetadataFromParams:disparity withType:AUX_DISPARITY];
        if (dispDict) {
            [dictMeta setObject:dispDict forKey:CFS(AUX_DISPARITY)];
        }
    }
    
    if (@available(iOS 12.0, *)) {
        OKMetaParam *matte = (OKMetaParam *)aux[CFS(AUX_MATTE)];
        if (matte) {
            NSDictionary *matteDict = [self auxMetadataFromParams:matte withType:AUX_MATTE];
            if (matteDict) {
                [dictMeta setObject:matteDict forKey:CFS(AUX_MATTE)];
            }
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
                                                         (__bridge CFTypeRef)@(CustomRenderedPortrait));
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
    // not implemented yet
    return NO;
}

- (BOOL)applyMap:(nonnull UIImage *)map
        forImage:(nonnull UIImage *)image
      andWriteAt:(nonnull NSURL *)url
{
    NSAssert(map && image && url, @"Unexpected NIL!");
    
    CGFloat resizeKoef = 2;
    CGSize resize = CGSizeMake(image.size.width/resizeKoef, image.size.height/resizeKoef);
    UIImage *resizedMap = [self resize:resize image:map];
    
    NSDictionary *disparityRepresentation = [self disparityRepresentationWithImage:resizedMap];
    NSDictionary *depthRepresentation = nil;//[self depthRepresentationWithImage:resizedMap];
    NSDictionary *matteRepresentation = nil;//[self matteRepresentationWithImage:map];
    
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

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

- (CVPixelBufferRef)disparity32PixelBufferFromImage:(UIImage *)image
{
    // 1) orig PB
    CVPixelBufferRef pxbuffer = NULL;
    CGImageRef cgImage = image.CGImage;
    size_t width =  CGImageGetWidth(cgImage);
    size_t height =  CGImageGetHeight(cgImage);
    
    NSDictionary *options = @{ CFS(kCVPixelBufferCGImageCompatibilityKey) : @YES, CFS(kCVPixelBufferCGBitmapContextCompatibilityKey) : @YES};
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    width = CVPixelBufferGetWidth(pxbuffer);
    height = CVPixelBufferGetHeight(pxbuffer);
    
    // 1a fill buffer
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, width, height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    CFRelease(rgbColorSpace);
    
    // 2) disp PB
    CVPixelBufferRef dispartyPixelBuffer = NULL;
    status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                 kCVPixelFormatType_DisparityFloat32, (__bridge CFDictionaryRef)options, &dispartyPixelBuffer);
    NSParameterAssert(status == kCVReturnSuccess && dispartyPixelBuffer != NULL);
    
   // 3) copy
    CVPixelBufferLockBaseAddress(dispartyPixelBuffer, 0);
    CVPixelBufferLockBaseAddress(pxbuffer, 1);
    
    float *outPB = CVPixelBufferGetBaseAddress(dispartyPixelBuffer);
    UInt32 *inPB = CVPixelBufferGetBaseAddress(pxbuffer);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            long index = y * width + x;
            UInt32 color = inPB[index];
            // Average of RGB = greyscale
            UInt32 averageColor = (R(color) + G(color) + B(color)) / 3.0;
            outPB[index] = averageColor / 255.0;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 1);
    CVPixelBufferUnlockBaseAddress(dispartyPixelBuffer, 0);
    
    // 4) normilize
    CVPixelBufferLockBaseAddress(dispartyPixelBuffer, 0);
    float *addr = CVPixelBufferGetBaseAddress(dispartyPixelBuffer);
    
    float minPixel = 1.0;
    float maxPixel = 0.0;
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            long index = y * width + x;
            float pixel = addr[index];
            minPixel = fminf(pixel, minPixel);
            maxPixel = fmaxf(pixel, maxPixel);
        }
    }
    
    float range = maxPixel - minPixel;
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            long index = y * width + x;
            float pixel = addr[index];
            addr[index] = (pixel - minPixel) / range;
        }
    }
    
    CVPixelBufferUnlockBaseAddress(dispartyPixelBuffer, 0);

    return dispartyPixelBuffer;
}

- (NSDictionary *)disparityMetadataWithImage:(UIImage *)image
{
    CVPixelBufferRef pxbuffer = [self disparity32PixelBufferFromImage:image];

    size_t width = CVPixelBufferGetWidth(pxbuffer);
    size_t height = CVPixelBufferGetHeight(pxbuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pxbuffer);
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

@end
