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
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)UIImagePNGRepresentation(image), NULL);
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
                            copyOld:(BOOL)copyOld DEPRECATED_ATTRIBUTE
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
    if ([self setGoogleParams:googleParam toMeta:destMetadata] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Setting Google params fails");
    }
    
    NSDictionary *panoParam = param[(NSString *)PanoNamespace];
    if (panoParam != nil)
    {
        if ([self setPanoParams:panoParam imageSize:CGSizeMake(width, height) toMeta:destMetadata] == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Setting Pano params fails");
        }

        if ([self setCustomRendered:CustomRenderedPanorama toMeta:destMetadata] == NO)
        {
            os_log_error(OS_LOG_DEFAULT, "Setting Pano Custom Rendered params fails");
        }
    }
    
    NSDictionary *appleParam = param[(NSString *)AppleNamespace];
    if ([self setAppleParams:appleParam toMeta:destMetadata] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Setting Apple params fails");
    }
    
    NSMutableDictionary *auxDict = [NSMutableDictionary new];
    if (param[CFS(AUX_DEPTH)]) {
        [auxDict setObject:param[CFS(AUX_DEPTH)] forKey:CFS(AUX_DEPTH)];
    }
    if (param[CFS(AUX_DISPARITY)]) {
        [auxDict setObject:param[CFS(AUX_DISPARITY)] forKey:CFS(AUX_DISPARITY)];
    }
    if (@available(iOS 12.0, *)) {
        if (param[CFS(AUX_MATTE)]) {
            [auxDict setObject:param[CFS(AUX_MATTE)] forKey:CFS(AUX_MATTE)];
        }
    }

    //Remove processed
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
    
    if ([self setXMPSectionToMeta:destMetadata] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Setting xmp params fails");
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
                             (CFTypeRef)MimeType);
    
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
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AppleNamespace,
                             (CFStringRef)ImageIO,
                             (CFStringRef)hasIIM,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"true");
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(ImageIO, hasIIM), tag);
    CFRelease(tag);
    
    return result;
}

- (BOOL)setCustomRendered:(NSInteger)flag toMeta:(_Nonnull CGMutableImageMetadataRef)meta
{
    CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)AdobeExifNamespace, (CFStringRef)exif, NULL);
    CGImageMetadataTagRef tag = CGImageMetadataTagCreate((CFStringRef)AdobeExifNamespace,
                                                         (CFStringRef)exif,
                                                         (CFStringRef)CustomRendered,
                                                         kCGImageMetadataTypeString,
                                                         (__bridge CFTypeRef)@(flag));
    if (tag) {
        CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(exif, CustomRendered), tag);
        CFRelease(tag);
        
        return YES;
    }
    
    return NO;
}

- (BOOL)setXMPSectionToMeta:(_Nonnull CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)AdobeXMPNamespace, (CFStringRef)xmp, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", AdobeXMPNamespace, error);
        return NO;
    }
    
    // ?????
//    CGImageMetadataTagRef tag =
//    CGImageMetadataTagCreate((CFStringRef)AdobeXMPNamespace,
//                             (CFStringRef)xmp,
//                             (CFStringRef)CreateDate,
//                             kCGImageMetadataTypeString,
//                             (CFTypeRef)@"2019-10-03T18:29:33.644");
//
//    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(xmp, CreateDate), tag);
//    CFRelease(tag);
    
    CGImageMetadataTagRef tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeXMPNamespace,
                             (CFStringRef)xmp,
                             (CFStringRef)ModifyDate,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)[self timestamp]);
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(xmp, ModifyDate), tag);
    CFRelease(tag);
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeXMPNamespace,
                             (CFStringRef)xmp,
                             (CFStringRef)CreatorTool,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)OKSign);
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(xmp, CreatorTool), tag);
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

- (NSString *)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return [dateFormatter stringFromDate:[NSDate date]];
}

// ???????
- (BOOL)setPhotoshopToMeta:(_Nonnull CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)AdobePhotoshopNamespace, (CFStringRef)photoshop, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", AdobePhotoshopNamespace, error);
        return NO;
    }
    
    CGImageMetadataTagRef tag =
    CGImageMetadataTagCreate((CFStringRef)AdobePhotoshopNamespace,
                             (CFStringRef)photoshop,
                             (CFStringRef)DateCreated,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"2019-10-03T18:29:33.644");
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(photoshop, DateCreated), tag);
    CFRelease(tag);
    
    return result;
}

// ???????
- (BOOL)setTiffSectionToMeta:(_Nonnull CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)AdobeTIFFNamespace, (CFStringRef)tiff, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", AdobeTIFFNamespace, error);
        return NO;
    }
    
    CGImageMetadataTagRef tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeTIFFNamespace,
                             (CFStringRef)tiff,
                             (CFStringRef)Make,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"Apple");
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(tiff, Make), tag);
    CFRelease(tag);
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeTIFFNamespace,
                             (CFStringRef)tiff,
                             (CFStringRef)Orientation,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"1");
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(tiff, Orientation), tag);
    CFRelease(tag);
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeTIFFNamespace,
                             (CFStringRef)tiff,
                             (CFStringRef)TileWidth,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"512");
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(tiff, TileWidth), tag);
    CFRelease(tag);
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeTIFFNamespace,
                             (CFStringRef)tiff,
                             (CFStringRef)TileLength,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"512");
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(tiff, TileLength), tag);
    CFRelease(tag);
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeTIFFNamespace,
                             (CFStringRef)tiff,
                             (CFStringRef)XResolution,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"72/1");
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(tiff, XResolution), tag);
    CFRelease(tag);
    
    tag =
    CGImageMetadataTagCreate((CFStringRef)AdobeTIFFNamespace,
                             (CFStringRef)tiff,
                             (CFStringRef)YResolution,
                             kCGImageMetadataTypeString,
                             (CFTypeRef)@"72/1");
    
    result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(tiff, YResolution), tag);
    CFRelease(tag);
    
    return result;
}

@end
