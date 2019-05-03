//
//  OKImageGVRMetadator.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/2/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageGVRMetadator.h"
#import <os/log.h>
#import "OKJpegParser.h"

@implementation OKImageMetadator ( OKImageGVRMetadator )

- (BOOL)make180VRLeftImage:(nonnull UIImage *)leftImage
                rightImage:(nonnull UIImage *)rightImage
                  withMeta:(nullable OKMetaParam *)meta
                 outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(leftImage && rightImage && outputURL, @"Unexpected NIL!");
    
    return [self processMake180VRLeft:leftImage right:rightImage withMeta:meta outputURL:outputURL];
}

- (BOOL)make180VRWithSBSImage:(nonnull UIImage *)sbsImage
                     withMeta:(nullable OKMetaParam *)meta
                    outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(sbsImage && outputURL, @"Unexpected NIL!");
    
    UIImage *leftImage = [self extractLeft:YES fromImage:sbsImage];
    UIImage *rightImage = [self extractLeft:NO fromImage:sbsImage];
    
    return [self processMake180VRLeft:leftImage right:rightImage withMeta:meta outputURL:outputURL];
}

- (BOOL)makeDepthMapWithImage:(nonnull UIImage *)image
                   depthImage:(nonnull UIImage *)depthImage
                         near:(CGFloat)near
                          far:(CGFloat)far
                    outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(image && depthImage && outputURL, @"Unexpected NIL!");
    
    NSDictionary *depthParams = [self depthParamsWithDepthImage:depthImage near:near far:far];
    
    if (depthParams == nil) {
        return NO;
    }
    
    NSDictionary *googleParams = @{PP(GImage, Mime) : @"image/jpeg"};
    
    NSDictionary *full = @{ GoogleNamespace : googleParams,
                            GDepthNamespace : depthParams,
                            };
    
    return [self writeImage:image withMetaParams:full properties:nil atURL:outputURL];
}

- (nullable NSDictionary *)depthParamsWithDepthImage:(UIImage *)depthImage near:(CGFloat)near far:(CGFloat)far
{
    NSData *clearImageData = UIImageJPEGRepresentation(depthImage, 1.0);
    NSString *stringData = [clearImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if (stringData == nil)
    {
        return nil;
    }
    
    NSMutableDictionary *dParams = [NSMutableDictionary new];
    
    dParams[DP(Software)] = @"OKMetadator";
    dParams[DP(Format)] = RangeInverse;
    dParams[DP(Near)] = @(near);
    dParams[DP(Far)] = @(far);
    dParams[DP(Mime)] = @"image/jpeg";
    dParams[DP(Data)] = stringData;
    
    return [dParams copy];
}

//- (CGImageMetadataRef)metaFromImageAtURL:(nonnull NSURL *)url
//{
//    CGImageMetadataRef metadata = [super metaFromImageAtURL:url];
//    NSData *xmp = [self xmpFromImageAtURL:url];
//
//    if (xmp) {
//        metadata = CGImageMetadataCreateFromXMPData((CFDataRef)xmp);
//    }
//
//    return metadata;
//}

//- (NSData *)xmpFromImageAtURL:(NSURL *)url
//{
//    NSData *data = [super xmpFromImageAtURL:url];
//    if (data == nil)
//    {
//        data = [[OKJpegParser new] xmpFromURL:url];
//    }
    
//    NSData *data = [[OKJpegParser new] xmpFromURL:url];
//
//    return data;
//}

- (nullable CIImage *)depthCIImageFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    UIImage *image = [self depthImageFromImageAtURL:url];
    
    return [CIImage imageWithCGImage:image.CGImage];
}

- (nullable UIImage *)depthImageFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    OKMetaParam *metaparam = [self metaParamsFromImageAtURL:url];
    
    if (metaparam[GDepthNamespace]) {
        
        return [self gImageFromString:metaparam[GDepthNamespace][DP(Data)]];
    }
    
    return nil;
}

- (nullable CIImage *)dataCIImageFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    UIImage *image = [self depthImageFromImageAtURL:url];
    
    return [CIImage imageWithCGImage:image.CGImage];
}

- (nullable UIImage *)dataImageFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    OKMetaParam *metaparam = [self metaParamsFromImageAtURL:url];
    
    if (metaparam[GoogleNamespace]) {
        
        return [self gImageFromString:metaparam[GoogleNamespace][PP(GImage,Data)]];
    }
    
    return nil;
}

#pragma mark Private

- (UIImage *)gImageFromString:(NSString *)string
{
    if (string) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64Encoding64CharacterLineLength];
        return [UIImage imageWithData:imageData];
    }
    
    return nil;
}

#warning TEMP IMPL : WAS COPIED FROM SPHERICAL METADATOR. DOESN'T WORK RIGHT CURRENTLY

- (BOOL)processMake180VRLeft:(UIImage *)leftImage
                       right:(UIImage *)rightImage
                    withMeta:(nullable OKMetaParam *)meta
                   outputURL:(NSURL *)outputURL
{
    NSString *tempLeftName = [NSString stringWithFormat:@"TPML%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempLeftURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempLeftName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    NSString *tempRightName = [NSString stringWithFormat:@"TPMR%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempRightURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempRightName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    //CGSize size = CGSizeMake(leftImage.size.width, leftImage.size.height);
    
    CGFloat aspect = 1;
    //CGFloat delta = aspect/(size.width/size.height);
    //CGSize renderSize = CGSizeMake(size.width * delta, size.height);
    
    //NSDictionary *panoParams = [self pano180ParamsWithSize:renderSize];
    NSMutableDictionary *allParams = meta ? [meta mutableCopy] : [NSMutableDictionary new];
    //[allParams setValue:panoParams forKey:(NSString *)PanoNamespace];
    [allParams removeObjectForKey:(NSString *)PanoNamespace];
    
    BOOL result = NO;
    if ([self resizeAspect:aspect image:leftImage withProperties:nil andWriteURL:tempLeftURL] &&
        [self resizeAspect:aspect image:rightImage withProperties:nil andWriteURL:tempRightURL])
    {
        NSError *error;
        NSData *rightImageData = [NSData dataWithContentsOfURL:tempRightURL options:0 error:&error];
        UIImage *rightImage = [UIImage imageWithData:rightImageData];
        
        CIImage *ciimage = [CIImage imageWithCGImage:rightImage.CGImage];
        CGImageRef cgImage = [[CIContext context] createCGImage:ciimage fromRect:ciimage.extent];
        UIImage *clearImage =  [UIImage imageWithCGImage:cgImage];
        
        NSData *clearImageData = UIImageJPEGRepresentation(clearImage, 1.0);
        NSString *stringData = [clearImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        if (stringData)
        {
            if (allParams[GoogleNamespace] == nil)
            {
                allParams[GoogleNamespace] = @{};
            }
            NSMutableDictionary *mutGoogleDict = [allParams[GoogleNamespace] mutableCopy];
            [mutGoogleDict setValue:stringData forKey:PP(GImage, Data)];
            
            [allParams setValue:mutGoogleDict forKey:GoogleNamespace];
        }
        else
        {
            os_log_error(OS_LOG_DEFAULT, "Could not create right image data from URL: %@", tempRightURL);
        }
        
        result = [self processInjectionForImageURL:tempLeftURL output:outputURL withMetaParam:allParams copyOld:YES];
        
        [[NSFileManager defaultManager] removeItemAtURL:tempLeftURL error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:tempRightURL error:nil];
    }
    
    return result;
}

- (BOOL)processInjectionForImageURL:(NSURL *)url
                             output:(NSURL *)outputURL
                      withMetaParam:(OKMetaParam *)param
                            copyOld:(BOOL)copyOld
{
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return NO;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    if (image == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image from source");
        CFRelease(source);
        return NO;
    }
    
    BOOL result = [self processInjectionForImage:image source:source output:outputURL withMetaParam:param copyOld:copyOld];
    
    CGImageRelease(image);
    CFRelease(source);
    
    return result;
}

- (BOOL)processInjectionForImage:(CGImageRef)image
                          source:(CGImageSourceRef)source
                          output:(NSURL *)outputURL
                   withMetaParam:(nullable OKMetaParam *)param
                         copyOld:(BOOL)copyOld
{
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    os_log_debug(OS_LOG_DEFAULT, "Image width: %f, height: %f", width, height);
    
    CGImageMetadataRef metadata = CGImageSourceCopyMetadataAtIndex(source, 0, NULL);
    if (metadata == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create metadata");
        return NO;
    }
    os_log_info(OS_LOG_DEFAULT, "Input meta:\n%@", metadata);
    
    CGMutableImageMetadataRef destMetadata = copyOld ? CGImageMetadataCreateMutableCopy(metadata) : CGImageMetadataCreateMutable();
    
    NSDictionary *googleParam = param[(NSString *)GoogleNamespace];
    if (googleParam != nil && copyOld)
    {
        if ([self setGoogleParams:googleParam toMeta:destMetadata] == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Setting Google params fails");
        }
    }
    
    NSDictionary *appleParam = param[(NSString *)AppleNamespace];
    if (appleParam != nil && copyOld)
    {
        if ([self setAppleParams:appleParam toMeta:destMetadata] == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Setting Apple params fails");
        }
    }
    
    NSMutableDictionary *other = [param mutableCopy];
    [other removeObjectForKey:PanoNamespace];
    [other removeObjectForKey:GoogleNamespace];
    [other removeObjectForKey:AppleNamespace];
    
    [other removeObjectForKey:CFS(AUX_DEPTH)];
    [other removeObjectForKey:CFS(AUX_DISPARITY)];
    if (@available(iOS 12.0, *)) {
        [other removeObjectForKey:CFS(AUX_MATTE)];
    }
    
    if ([self setOtherParams:[other copy] toMeta:destMetadata] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Setting other params fails");
    }
    
    NSMutableData *destData = [NSMutableData data];
    CFStringRef UTI = CGImageSourceGetType(source);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)destData,UTI,1,NULL);
    
    if(destination == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image destination");
        CFRelease(metadata);
        CFRelease(destMetadata);
        return NO;
    }
    
    CGImageDestinationAddImageAndMetadata(destination, image, destMetadata, NULL);
    
    //Auxiliary removes GPano meta, so wont be added
    
    if(CGImageDestinationFinalize(destination) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not make image finalizing");
        CFRelease(metadata);
        CFRelease(destMetadata);
        CFRelease(destination);
        return NO;
    }
    
    if([destData writeToURL:outputURL atomically:YES] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not write image data at URL: %@", outputURL);
        CFRelease(metadata);
        CFRelease(destMetadata);
        CFRelease(destination);
        
        return NO;
    }
    os_log_info(OS_LOG_DEFAULT, "Injected image meta:\n%@", destMetadata);
    
    CFRelease(metadata);
    CFRelease(destMetadata);
    CFRelease(destination);
    
    return YES;
}

- (UIImage *)extractLeft:(BOOL)left fromImage:(UIImage *)sbsImage
{
    CIImage *ciimage = [CIImage imageWithCGImage:sbsImage.CGImage];
    CGRect rect;
    if (left) {
        rect = CGRectMake(0, 0, ciimage.extent.size.width/2, ciimage.extent.size.height);
    }
    else {
        rect = CGRectMake(ciimage.extent.size.width/2, 0, ciimage.extent.size.width/2, ciimage.extent.size.height);
    }
    
    CGImageRef cgImage = [[CIContext context] createCGImage:ciimage fromRect:rect];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

- (BOOL)setGoogleParams:(NSDictionary *)params toMeta:(CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)GoogleNamespace, (CFStringRef)GImage, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", GoogleNamespace, error);
        return NO;
    }
    
    CGImageMetadataTagRef mimeTag =
    CGImageMetadataTagCreate((CFStringRef)GoogleNamespace,
                             (CFStringRef)GImage,
                             (CFStringRef)Mime,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"image/jpeg");
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(GImage, Mime), mimeTag);
    CFRelease(mimeTag);
    
    if (params[PP(GImage, Data)])
    {
        CFStringRef str = (__bridge CFStringRef)params[PP(GImage, Data)];
        
        CGImageMetadataTagRef dataTag =
        CGImageMetadataTagCreate((CFStringRef)GoogleNamespace,
                                 (CFStringRef)GImage,
                                 (CFStringRef)Data,
                                 kCGImageMetadataTypeString,
                                 (CFTypeRef)str);
        
        result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(GImage, Data), dataTag);
        
        CFRelease(dataTag);
    }
    
    return result;
}

- (BOOL)setAppleParams:(NSDictionary *)params toMeta:(CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)AppleNamespace, (CFStringRef)ImageIO, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", AppleNamespace, error);
        return NO;
    }
    
    CGImageMetadataTagRef tag =
    CGImageMetadataTagCreate((CFStringRef)AppleNamespace,
                             (CFStringRef)ImageIO,
                             (CFStringRef)hasXMP,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"true");
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(ImageIO, hasXMP), tag);
    CFRelease(tag);
    
    return result;
}

- (BOOL)setOtherParams:(OKMetaParam *)params toMeta:(CGMutableImageMetadataRef)meta
{
    __block BOOL result = YES;
    CGImageMetadataRef otherMeta = [self metadataFromMetaParams:params];
    CGImageMetadataEnumerateTagsUsingBlock(otherMeta, NULL, NULL, ^bool(CFStringRef  _Nonnull path, CGImageMetadataTagRef  _Nonnull tag) {
        NSString *namespace = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyNamespace(tag));
        NSString *prefix = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyPrefix(tag));
        CFErrorRef error;
        if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)namespace, (CFStringRef)prefix, &error) == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", namespace, error);
            return NO;
        }
        if(CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)path, tag) == NO)
        {
            result = NO;
        }
        return true;
    });
    
    return result;
}

@end
