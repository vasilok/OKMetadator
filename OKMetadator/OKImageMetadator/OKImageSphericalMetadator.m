//
//  VSImageSphericalMetadator.m
//  VSMetadator
//
//  Created by Vasil_OK on 1/10/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageSphericalMetadator.h"
#import <os/log.h>
#import "OKImageMetadator+Common.h"

@implementation OKImageMetadator (OKImageSphericalMetadator)

- (void)removePanoFromImageAt:(NSURL *)url outputURL:(nonnull NSURL *)outputURL completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [self removePanoFromImageAt:url outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (BOOL)removePanoFromImageAt:(NSURL *)url outputURL:(nonnull NSURL *)outputURL
{
    NSMutableDictionary *params = [[self metaParamsFromImageAtURL:url] mutableCopy];
    [params removeObjectForKey:PanoNamespace];
    
    return [self processInjectionForImageURL:url output:outputURL withMetaParam:params copyOld:NO];
}

#pragma mark 360/180 Fabrics

- (void)make360ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL
               completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [self processMake360:YES imageAtURL:url outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (void)make180ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL
               completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [self processMake360:NO imageAtURL:url outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (void)makePanoWithHorizontalFOV:(CGFloat)horizntalFOV
                      verticalFOV:(CGFloat)verticalFOV
                            atURL:(nonnull NSURL *)url
                        outputURL:(nonnull NSURL *)outputURL
                       completion:(nullable OKSphereMetaInjectorCompletion)completion;
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    NSAssert((horizntalFOV > 0) || (verticalFOV > 0), @"Unexpected params!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [self processMake:horizntalFOV verticalFOV:verticalFOV imageAtURL:url outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (void)makePanoImage:(nonnull UIImage *)image
    withHorizontalFOV:(CGFloat)horizntalFOV
          verticalFOV:(CGFloat)verticalFOV
                 meta:(nullable OKMetaParam *)meta
            outputURL:(nonnull NSURL *)outputURL
           completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    NSAssert((horizntalFOV > 0) || (verticalFOV > 0), @"Unexpected params!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [self processMake:horizntalFOV verticalFOV:verticalFOV meta:meta image:image outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (void)make360Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL
          completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [blockSelf processMake360:YES image:image withMeta:meta outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (void)make180Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)params
           outputURL:(nonnull NSURL *)outputURL
          completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [blockSelf processMake360:NO image:image withMeta:params outputURL:outputURL];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (BOOL)make360ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    return [self processMake360:YES imageAtURL:url outputURL:outputURL];
}

- (BOOL)make180ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    return [self processMake360:NO imageAtURL:url outputURL:outputURL];
}

- (BOOL)make360Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    
    return [self processMake360:YES image:image withMeta:meta outputURL:outputURL];
}

- (BOOL)make180Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    
    return [self processMake360:NO image:image withMeta:meta outputURL:outputURL];
}

- (nonnull NSDictionary *)pano360ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[PP(GPano,CaptureSoftware)] = [self captureSoftware];
    updParams[PP(GPano,ProjectionType)] = equirectangular;
    updParams[PP(GPano,FullPanoWidthPixels)] = @(size.width);
    updParams[PP(GPano,FullPanoHeightPixels)] = @(size.height);
    updParams[PP(GPano,CroppedAreaImageWidthPixels)] = @(size.width);
    updParams[PP(GPano,CroppedAreaImageHeightPixels)] = @(size.height);
    updParams[PP(GPano,CroppedAreaLeftPixels)] = @(0);
    updParams[PP(GPano,CroppedAreaTopPixels)] = @(0);
    
    return [updParams copy];
}

- (nonnull NSDictionary *)pano180ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[PP(GPano,CaptureSoftware)] = [self captureSoftware];
    updParams[PP(GPano,ProjectionType)] = equirectangular;
    updParams[PP(GPano,FullPanoWidthPixels)] = @(size.width * 2);
    updParams[PP(GPano,FullPanoHeightPixels)] = @(size.height);
    updParams[PP(GPano,CroppedAreaImageWidthPixels)] = @(size.width);
    updParams[PP(GPano,CroppedAreaImageHeightPixels)] = @(size.height);
    updParams[PP(GPano,CroppedAreaLeftPixels)] = @(size.width/2);
    updParams[PP(GPano,CroppedAreaTopPixels)] = @(0);
    
    return [updParams copy];
}

- (nonnull NSDictionary *)panoParams:(CGFloat)hFov vFov:(CGFloat)vFov withSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    CGFloat fullWidth = size.width * 360.0/hFov;
    CGFloat fullHeight = size.height * 180.0/vFov;
    updParams[PP(GPano,CaptureSoftware)] = [self captureSoftware];
    updParams[PP(GPano,ProjectionType)] = equirectangular;
    updParams[PP(GPano,InitialViewHeadingDegrees)] = @(0);
    updParams[PP(GPano,InitialViewPitchDegrees)] = @(0);
    updParams[PP(GPano,InitialViewRollDegrees)] = @(0);
    updParams[PP(GPano,InitialHorizontalFOVDegrees)] = @(75.0);
    updParams[PP(GPano,PoseHeadingDegrees)] = @(hFov);
    updParams[PP(GPano,FullPanoWidthPixels)] = @(fullWidth);
    updParams[PP(GPano,FullPanoHeightPixels)] = @(fullHeight);
    updParams[PP(GPano,CroppedAreaImageWidthPixels)] = @(size.width);
    updParams[PP(GPano,CroppedAreaImageHeightPixels)] = @(size.height);
    updParams[PP(GPano,CroppedAreaLeftPixels)] = @(fullWidth/2 - size.width/2);
    updParams[PP(GPano,CroppedAreaTopPixels)] = @(fullHeight/2 - size.height/2);
    
    return [updParams copy];
}

- (CGFloat)pano360Aspect
{
    return 2;
}

- (CGFloat)pano180Aspect
{
    return 1;
}

- (BOOL)verifyParam:(id)param forPanoKey:(NSString *)key
{
    if ([key isEqualToString:CaptureSoftware]) {
        return [param isKindOfClass:[NSString class]];
    }
    else if ([key isEqualToString:ProjectionType]) {
        NSString *value = (NSString *)param;
        return [value isKindOfClass:[NSString class]] && [value isEqualToString:equirectangular];
    }
    else if ([key isEqualToString:UsePanoramaViewer]) {
        if ([param isKindOfClass:[NSNumber class]]) {
            return YES;
        }
        else if ([param isKindOfClass:[NSString class]]) {
            NSString *value = (NSString *)param;
            return [value isEqualToString:@"true"] || [value isEqualToString:@"false"];
        }
    }
    else if ([key isEqualToString:FullPanoWidthPixels]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:FullPanoHeightPixels]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:InitialViewHeadingDegrees]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:InitialViewPitchDegrees]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:InitialViewRollDegrees]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:InitialHorizontalFOVDegrees]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:InitialVerticalFOVDegrees]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:PoseHeadingDegrees]) {
        NSNumber *value = (NSNumber *)param;
        return [value isKindOfClass:[NSNumber class]] && (value.floatValue >= 0.) && (value.floatValue <= 360.);
    }
    else if ([key isEqualToString:PosePitchDegrees]) {
        NSNumber *value = (NSNumber *)param;
        return [value isKindOfClass:[NSNumber class]] && (value.floatValue >= -90.) && (value.floatValue <= 90.);
    }
    else if ([key isEqualToString:PoseRollDegrees]) {
        NSNumber *value = (NSNumber *)param;
        return [value isKindOfClass:[NSNumber class]] && (value.floatValue >= -180.) && (value.floatValue <= 180.);
    }
    else if ([key isEqualToString:CroppedAreaLeftPixels]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:CroppedAreaImageHeightPixels]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:CroppedAreaTopPixels]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:CroppedAreaImageWidthPixels]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:InitialCameraDolly]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    
    else if ([key isEqualToString:InitialCameraDolly]) {
        if ([param isKindOfClass:[NSNumber class]]) {
            return YES;
        }
        else if ([param isKindOfClass:[NSString class]]) {
            NSString *value = (NSString *)param;
            return [value isEqualToString:@"true"] || [value isEqualToString:@"false"];
        }
    }
    else if ([key isEqualToString:SourcePhotosCount]) {
        return [param isKindOfClass:[NSNumber class]];
    }
    else if ([key isEqualToString:FirstPhotoDate]) {
        return [param isKindOfClass:[NSString class]];
    }
    else if ([key isEqualToString:LastPhotoDate]) {
        return [param isKindOfClass:[NSString class]];
    }
    
    os_log_error(OS_LOG_DEFAULT, "Unknown Pano key: %@", key);
    return NO;
}

#pragma mark Make Private

- (BOOL)processMake360:(BOOL)is360
            imageAtURL:(NSURL *)url
             outputURL:(NSURL *)outputURL
{
    NSString *tempName = [NSString stringWithFormat:@"TPM%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    NSDictionary *props = [self propertiesFromImageAtURL:url];
    
    CGSize size = CGSizeMake([props[(NSString *)kCGImagePropertyPixelWidth] intValue], [props[(NSString *)kCGImagePropertyPixelHeight] intValue]);
    
    CGFloat aspect = is360 ? [self pano360Aspect] : [self pano180Aspect];
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(size.width * delta, size.height);
    
    NSDictionary *panoParams = is360 ? [self pano360ParamsWithSize:renderSize] : [self pano180ParamsWithSize:renderSize];
    NSDictionary *allParams = [props mutableCopy];
    [allParams setValuesForKeysWithDictionary:panoParams];
    
    BOOL result = NO;
    if (size.width / size.height != aspect)
    {
        if ([self resizeAspect:aspect imageAtURL:url andWriteURL:tempURL])
        {
            result = [self processInjectionForImageURL:tempURL output:outputURL withMetaParam:allParams copyOld:YES];
            
            [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
        }
    }
    else
    {
        result = [self processInjectionForImageURL:url output:outputURL withMetaParam:allParams copyOld:YES];
    }
    
    return result;
}

- (BOOL)processMake360:(BOOL)is360
                 image:(UIImage *)image
              withMeta:(nullable OKMetaParam *)meta
             outputURL:(NSURL *)outputURL
{
    NSString *tempName = [NSString stringWithFormat:@"TPM%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    
    CGFloat aspect = is360 ? [self pano360Aspect] : [self pano180Aspect];
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(size.width * delta, size.height);
    
    NSDictionary *panoParams = is360 ? [self pano360ParamsWithSize:renderSize] : [self pano180ParamsWithSize:renderSize];
    NSMutableDictionary *allParams = meta ? [meta mutableCopy] : [NSMutableDictionary new];
    [allParams setValue:panoParams forKey:(NSString *)PanoNamespace];
    
    BOOL result = NO;
    if ([self resizeAspect:aspect image:image withProperties:nil andWriteURL:tempURL])
    {
        result = [self processInjectionForImageURL:tempURL output:outputURL withMetaParam:allParams copyOld:YES];
        
        [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
    }
    
    return result;
}

- (BOOL)processMake:(CGFloat)horizontalFOV verticalFOV:(CGFloat)verticalFOV meta:(OKMetaParam *)meta image:(UIImage *)image outputURL:(NSURL *)outputURL
{
    NSString *tempName = [NSString stringWithFormat:@"TPM%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    
    if ((horizontalFOV > 0) && (verticalFOV <= 0))
    {
        CGFloat widthAspect = size.width/size.height;
        verticalFOV = horizontalFOV / widthAspect;
    }
    else if ((verticalFOV > 0) && (horizontalFOV <= 0))
    {
        CGFloat widthAspect = size.width/size.height;
        horizontalFOV = verticalFOV * widthAspect;
    }
    
    CGFloat aspect = horizontalFOV / verticalFOV;
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(roundf((size.width * delta)), roundf(size.height));
    
    NSDictionary *panoParams = [self panoParams:horizontalFOV vFov:verticalFOV withSize:renderSize];
    NSMutableDictionary *allParams = meta ? [meta mutableCopy] : [NSMutableDictionary new];;
    [allParams setValue:panoParams forKey:(NSString *)PanoNamespace];
    
    BOOL result = NO;
    if ([self resizeAspect:aspect image:image withProperties:nil andWriteURL:tempURL])
    {
        result = [self processInjectionForImageURL:tempURL output:outputURL withMetaParam:allParams copyOld:YES];
        
        [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
    }
    
    return result;
}

- (BOOL)processMake:(CGFloat)horizontalFOV verticalFOV:(CGFloat)verticalFOV imageAtURL:(NSURL *)url outputURL:(NSURL *)outputURL
{
    NSString *tempName = [NSString stringWithFormat:@"TPM%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    NSDictionary *props = [self propertiesFromImageAtURL:url];
    
    CGSize size = CGSizeMake([props[(NSString *)kCGImagePropertyPixelWidth] intValue], [props[(NSString *)kCGImagePropertyPixelHeight] intValue]);
    
    if ((horizontalFOV > 0) && (verticalFOV <= 0))
    {
        CGFloat widthAspect = size.width/size.height;
        verticalFOV = horizontalFOV / widthAspect;
    }
    else if ((verticalFOV > 0) && (horizontalFOV <= 0))
    {
        CGFloat widthAspect = size.width/size.height;
        horizontalFOV = verticalFOV * widthAspect;
    }
    
    CGFloat aspect = horizontalFOV / verticalFOV;
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(size.width * delta, size.height);
    
    NSDictionary *panoParams = [self panoParams:horizontalFOV vFov:verticalFOV withSize:renderSize];
    NSDictionary *allParams = [props mutableCopy];
    [allParams setValuesForKeysWithDictionary:panoParams];
    
    BOOL result = NO;
    if (size.width / size.height != aspect)
    {
        if ([self resizeAspect:aspect imageAtURL:url andWriteURL:tempURL])
        {
            result = [self processInjectionForImageURL:tempURL output:outputURL withMetaParam:allParams copyOld:YES];
            
            [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
        }
    }
    else
    {
        result = [self processInjectionForImageURL:url output:outputURL withMetaParam:allParams copyOld:YES];
    }
    
    return result;
}

#pragma mark Custom Injection

- (void)injectPanoToImageAtURL:(nonnull NSURL*)url
                     outputURL:(nonnull NSURL *)outputURL
                      withMeta:(nullable OKMetaParam *)meta
                    completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [blockSelf processInjectionForImageURL:url output:outputURL withMetaParam:meta copyOld:YES];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (BOOL)injectPanoToImageAtURL:(nonnull NSURL *)url
                     outputURL:(nonnull NSURL *)outputURL
                      withMeta:(nullable OKMetaParam *)meta
{
    NSAssert(url && outputURL, @"Unexpected NIL!");
    
    return [self processInjectionForImageURL:url output:outputURL withMetaParam:meta copyOld:YES];
}

- (void)injectPanoToImage:(nonnull UIImage *)image
                outputURL:(nonnull NSURL *)outputURL
                 withMeta:(nullable OKMetaParam *)meta
               completion:(nullable OKSphereMetaInjectorCompletion)completion
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    
    __weak typeof(self) blockSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^
                   {
                       BOOL result = [blockSelf processInjectionForImage:image output:outputURL withMetaParam:meta copyOld:YES];
                       
                       if (completion)
                       {
                           dispatch_async(blockSelf.completionQueue, ^{
                               completion(result);
                           });
                       }
                   });
}

- (BOOL)injectPanoToImage:(nonnull UIImage *)image
                outputURL:(nonnull NSURL *)outputURL
                 withMeta:(nullable OKMetaParam *)meta
{
    NSAssert(image && outputURL, @"Unexpected NIL!");
    
    return [self processInjectionForImage:image output:outputURL withMetaParam:meta copyOld:YES];
}

- (nullable NSDictionary *)extractPanoFromImageAtURL:(nonnull NSURL *)url
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
        os_log_error(OS_LOG_DEFAULT, "Could not getting metadata from source");
        CFRelease(source);
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    CGImageMetadataEnumerateTagsUsingBlock(metadata, NULL, NULL, ^bool(CFStringRef  _Nonnull path, CGImageMetadataTagRef  _Nonnull tag) {
        
        NSString *prefix = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyPrefix(tag));
        NSString *name = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyName(tag));
        NSString *namespace = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyNamespace(tag));
        NSString *value = (NSString *)CFBridgingRelease(CGImageMetadataTagCopyValue(tag));
        
        if ([namespace isEqualToString:(NSString *)PanoNamespace])
        {
            [dict setObject:value forKey:[NSString stringWithFormat:@"%@:%@", prefix, name]];
        }
        return true;
    });
    
    CFRelease(source);
    CFRelease(metadata);
    
    return [dict copy];
}

#pragma mark Private

- (BOOL)setPanoParams:(nullable NSDictionary *)params
            imageSize:(CGSize)size
               toMeta:(_Nonnull CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)PanoNamespace, (CFStringRef)GPano, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", PanoNamespace, error);
        return NO;
    }
    
    NSNumber *width = params[GP(FullPanoWidthPixels)];
    if (width == nil) width = @(size.width);
    [self setTagForPanoKey:FullPanoWidthPixels value:(__bridge CFTypeRef)(width) toMeta:meta];
    
    NSNumber *height = params[GP(FullPanoHeightPixels)];
    if (height == nil) height = @(size.height);
    [self setTagForPanoKey:FullPanoHeightPixels value:(__bridge CFTypeRef)(height) toMeta:meta];
    
    NSNumber *cropWidth = params[GP(CroppedAreaImageWidthPixels)];
    if (cropWidth == nil) cropWidth = @(size.width);
    [self setTagForPanoKey:CroppedAreaImageWidthPixels value:(__bridge CFTypeRef)(cropWidth) toMeta:meta];
    
    NSNumber *cropHeight = params[GP(CroppedAreaImageHeightPixels)];
    if (cropHeight == nil) cropHeight = @(size.height);
    [self setTagForPanoKey:CroppedAreaImageHeightPixels value:(__bridge CFTypeRef)(cropHeight) toMeta:meta];
    
    [self setTagForPanoKey:ProjectionType value:(__bridge CFTypeRef)(equirectangular) toMeta:meta];
    
    [self setTagForPanoKey:UsePanoramaViewer value:@"True" toMeta:meta];
    
    NSNumber *heading = params[GP(PoseHeadingDegrees)];
    if ((heading != nil) && [self verifyParam:heading forPanoKey:PoseHeadingDegrees]) {
        [self setTagForPanoKey:PoseHeadingDegrees value:(__bridge CFTypeRef)(heading) toMeta:meta];
    }
    else { // for Google maps!
        [self setTagForPanoKey:PoseHeadingDegrees value:(__bridge CFTypeRef)@"360" toMeta:meta];
    }
    
    NSNumber *pitch = params[GP(PosePitchDegrees)];
    if ((pitch != nil) && [self verifyParam:heading forPanoKey:PosePitchDegrees]) {
        [self setTagForPanoKey:PosePitchDegrees value:(__bridge CFTypeRef)(pitch) toMeta:meta];
    }
    
    NSNumber *roll = params[GP(PoseRollDegrees)];
    if ((roll != nil) && [self verifyParam:heading forPanoKey:PoseRollDegrees]){
        [self setTagForPanoKey:PoseRollDegrees value:(__bridge CFTypeRef)(roll) toMeta:meta];
    }
    
    NSNumber *initHeading = params[GP(InitialViewHeadingDegrees)];
    if (initHeading != nil) {
        [self setTagForPanoKey:InitialViewHeadingDegrees value:(__bridge CFTypeRef)(initHeading) toMeta:meta];
    }
    
    NSNumber *initPitch = params[GP(InitialViewPitchDegrees)];
    if (initPitch != nil) {
        [self setTagForPanoKey:InitialViewPitchDegrees value:(__bridge CFTypeRef)(initPitch) toMeta:meta];
    }
    
    NSNumber *initRoll = params[GP(InitialViewRollDegrees)];
    if (initRoll != nil) {
        [self setTagForPanoKey:InitialViewRollDegrees value:(__bridge CFTypeRef)(initRoll) toMeta:meta];
    }
    
    NSNumber *hfov = params[GP(InitialHorizontalFOVDegrees)];
    if (hfov != nil) {
        [self setTagForPanoKey:InitialHorizontalFOVDegrees value:(__bridge CFTypeRef)(hfov) toMeta:meta];
    }
    
    NSNumber *vfov = params[GP(InitialVerticalFOVDegrees)];
    if (vfov != nil) {
        [self setTagForPanoKey:InitialVerticalFOVDegrees value:(__bridge CFTypeRef)(vfov) toMeta:meta];
    }
    
    NSNumber *cropLeft = params[GP(CroppedAreaLeftPixels)];
    if (cropLeft != nil) {
        [self setTagForPanoKey:CroppedAreaLeftPixels value:(__bridge CFTypeRef)(cropLeft) toMeta:meta];
    }
    
    NSNumber *cropTop = params[GP(CroppedAreaTopPixels)];
    if (cropTop != nil) {
        [self setTagForPanoKey:CroppedAreaTopPixels value:(__bridge CFTypeRef)(cropTop) toMeta:meta];
    }
    
    NSString *firstPhotoDate = params[GP(FirstPhotoDate)];
    if (firstPhotoDate != nil) {
        [self setTagForPanoKey:FirstPhotoDate value:(__bridge CFTypeRef)(firstPhotoDate) toMeta:meta];
    }
    
    NSString *lastPhotoDate = params[GP(LastPhotoDate)];
    if (lastPhotoDate != nil) {
        [self setTagForPanoKey:LastPhotoDate value:(__bridge CFTypeRef)(lastPhotoDate) toMeta:meta];
    }
    
    NSNumber *photosCount = params[GP(SourcePhotosCount)];
    if (photosCount != nil) {
        [self setTagForPanoKey:SourcePhotosCount value:(__bridge CFTypeRef)(photosCount) toMeta:meta];
    }
    
    NSNumber *lock = params[GP(ExposureLockUsed)];
    if (lock != nil) {
        [self setTagForPanoKey:ExposureLockUsed value:(__bridge CFTypeRef)(lock) toMeta:meta];
    }
    
    return YES;
}

- (BOOL)setTagForPanoKey:(const NSString *)key
                   value:(CFTypeRef)value
                  toMeta:(CGMutableImageMetadataRef)meta
{
    CGImageMetadataTagRef tag =
    CGImageMetadataTagCreate((CFStringRef)PanoNamespace,
                             (CFStringRef)GPano,
                             (CFStringRef)key,
                             kCGImageMetadataTypeString,
                             value);
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)GP(key), tag);
    
    if (result == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Error set Pano %@ with %@", key, value);
    }
    CFRelease(tag);
    
    return result;
}

@end
