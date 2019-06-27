//
//  OKImageMetadator+Common.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/20/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <os/log.h>
#import "OKImageMetadator+Common.h"
#import "OKImageSphericalMetadator.h"
#import "OKImageAuxMetadator.h"

@implementation OKImageMetadator (Common)

- (BOOL)processInjectionForImage:(UIImage *)image
                          output:(NSURL *)outputURL
                   withMetaParam:(OKMetaParam *)param
                         copyOld:(BOOL)copyOld
{
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)UIImageJPEGRepresentation(image, 1.0), NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create source from image");
        return NO;
    }
    
    BOOL result = [self processInjectionForImage:image.CGImage source:source output:outputURL withMetaParam:param copyOld:copyOld];
    
    CFRelease(source);
    
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
    
    NSDictionary *panoParam = param[(NSString *)PanoNamespace];
    if (panoParam != nil && copyOld)
    {
        if ([self setPanoParams:panoParam imageSize:CGSizeMake(width, height) toMeta:destMetadata] == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Setting Pano params fails");
        }
    }
    
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
    [other removeObjectForKey:GoogleNamespace];
    [other removeObjectForKey:AppleNamespace];
    
    NSMutableDictionary *auxDict = [NSMutableDictionary new];
    [auxDict setObject:param[CFS(AUX_DEPTH)] forKey:CFS(AUX_DEPTH)];
    [auxDict setObject:param[CFS(AUX_DISPARITY)] forKey:CFS(AUX_DISPARITY)];
    if (@available(iOS 12.0, *)) {
        [auxDict setObject:param[CFS(AUX_MATTE)] forKey:CFS(AUX_MATTE)];
    }
    
    //Removes Auxiliary meta
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
    
    if (auxDict.allKeys.count > 0) {
        [self setPortraitToMeta:destMetadata];
    }
    
    CGImageDestinationAddImageAndMetadata(destination, image, destMetadata, NULL);
    
    if (auxDict.allKeys.count > 0) {
        [self setAuxParams:auxDict toDestination:destination];
    }
    
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

- (UIImage *)resize:(CGSize)size image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma Setups

- (BOOL)setGoogleParams:(OKMetaParam *)params toMeta:(CGMutableImageMetadataRef)meta
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

- (BOOL)setAppleParams:(OKMetaParam *)params toMeta:(CGMutableImageMetadataRef)meta
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
