//
//  VSImageSphericalMetadator.m
//  VSMetadator
//
//  Created by Vasil_OK on 1/10/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageSphericalMetadator.h"
#import <os/log.h>

@implementation OKImageSphericalMetadator

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

- (nonnull NSDictionary *)pano360ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[CaptureSoftware] = [self captureSoftware];
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

- (nonnull NSDictionary *)pano180ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[CaptureSoftware] = [self captureSoftware];
    updParams[ProjectionType] = equirectangular;
    updParams[InitialViewHeadingDegrees] = @(0);
    updParams[InitialViewPitchDegrees] = @(0);
    updParams[InitialViewRollDegrees] = @(0);
    updParams[InitialHorizontalFOVDegrees] = @(75.0);
    updParams[PoseHeadingDegrees] = @(180);
    updParams[FullPanoWidthPixels] = @(size.width * 2);
    updParams[FullPanoHeightPixels] = @(size.height);
    updParams[CroppedAreaImageWidthPixels] = @(size.width);
    updParams[CroppedAreaImageHeightPixels] = @(size.height);
    updParams[CroppedAreaLeftPixels] = @(size.width/2);
    updParams[CroppedAreaTopPixels] = @(0);
    
    return [updParams copy];
}

- (nonnull NSDictionary *)panoParams:(CGFloat)hFov vFov:(CGFloat)vFov withSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    CGFloat fullWidth = size.width * 360.0/hFov;
    CGFloat fullHeight = size.height * 180.0/vFov;
    updParams[CaptureSoftware] = [self captureSoftware];
    updParams[ProjectionType] = equirectangular;
    updParams[InitialViewHeadingDegrees] = @(0);
    updParams[InitialViewPitchDegrees] = @(0);
    updParams[InitialViewRollDegrees] = @(0);
    updParams[InitialHorizontalFOVDegrees] = @(75.0);
    updParams[PoseHeadingDegrees] = @(hFov);
    updParams[FullPanoWidthPixels] = @(fullWidth);
    updParams[FullPanoHeightPixels] = @(fullHeight);
    updParams[CroppedAreaImageWidthPixels] = @(size.width);
    updParams[CroppedAreaImageHeightPixels] = @(size.height);
    updParams[CroppedAreaLeftPixels] = @(fullWidth/2 - size.width/2);
    updParams[CroppedAreaTopPixels] = @(fullHeight/2 - size.height/2);
    
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

- (NSString *)vrExtension
{
    return @"vr.jpg";
}

- (BOOL)verifyParam:(id)param forKey:(NSString *)key
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

- (BOOL)processMake:(CGFloat)horizntalFOV verticalFOV:(CGFloat)verticalFOV meta:(OKMetaParam *)meta image:(UIImage *)image outputURL:(NSURL *)outputURL
{
    NSString *tempName = [NSString stringWithFormat:@"TPM%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    
    CGFloat aspect = horizntalFOV / verticalFOV;
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(roundf((size.width * delta)), roundf(size.height));
    
    NSDictionary *panoParams = [self panoParams:horizntalFOV vFov:verticalFOV withSize:renderSize];
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

- (BOOL)processMake:(CGFloat)horizntalFOV verticalFOV:(CGFloat)verticalFOV imageAtURL:(NSURL *)url outputURL:(NSURL *)outputURL
{
    NSString *tempName = [NSString stringWithFormat:@"TPM%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    NSDictionary *props = [self propertiesFromImageAtURL:url];
    
    CGSize size = CGSizeMake([props[(NSString *)kCGImagePropertyPixelWidth] intValue], [props[(NSString *)kCGImagePropertyPixelHeight] intValue]);
    
    CGFloat aspect = horizntalFOV / verticalFOV;
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(size.width * delta, size.height);
    
    NSDictionary *panoParams = [self panoParams:horizntalFOV vFov:verticalFOV withSize:renderSize];
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

- (BOOL)processMake180VRLeft:(UIImage *)leftImage
                       right:(UIImage *)rightImage
                    withMeta:(nullable OKMetaParam *)meta
                   outputURL:(NSURL *)outputURL
{
    NSString *tempLeftName = [NSString stringWithFormat:@"TPML%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempLeftURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempLeftName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    NSString *tempRightName = [NSString stringWithFormat:@"TPMR%ld", (long)CFAbsoluteTimeGetCurrent()];
    NSURL *tempRightURL = [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempRightName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
    
    CGSize size = CGSizeMake(leftImage.size.width, leftImage.size.height);
    
    CGFloat aspect = [self pano180Aspect];
    CGFloat delta = aspect/(size.width/size.height);
    CGSize renderSize = CGSizeMake(size.width * delta, size.height);
    
    NSDictionary *panoParams = [self pano180ParamsWithSize:renderSize];
    NSMutableDictionary *allParams = meta ? [meta mutableCopy] : [NSMutableDictionary new];
    [allParams setValue:panoParams forKey:(NSString *)PanoNamespace];
    
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
            [mutGoogleDict setValue:stringData forKey:Data];
            
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
    [other removeObjectForKey:PanoNamespace];
    [other removeObjectForKey:GoogleNamespace];
    [other removeObjectForKey:AppleNamespace];
    
    [other removeObjectForKey:AUX_DATA];
    [other removeObjectForKey:AUX_INFO];
    [other removeObjectForKey:AUX_META];
    
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
    
    NSDictionary *aux = [self auxDictionaryFromMetaParams:param];
    if (aux)
    {
        CGImageDestinationAddAuxiliaryDataInfo(destination, kCGImageAuxiliaryDataTypeDisparity, (CFDictionaryRef)aux);
    }
    
    //CGImageDestinationSetProperties(destination, props);
    
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

- (BOOL)setPanoParams:(NSDictionary *)params
            imageSize:(CGSize)size
               toMeta:(CGMutableImageMetadataRef)meta
{
    CFErrorRef error;
    
    if(CGImageMetadataRegisterNamespaceForPrefix(meta, (CFStringRef)PanoNamespace, (CFStringRef)GPano, &error) == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Register namespace: %@ with error: %@", PanoNamespace, error);
        return NO;
    }
    
    NSNumber *width = params[FullPanoWidthPixels];
    if (width == nil) width = @(size.width);
    [self setTagForPanoKey:FullPanoWidthPixels value:(__bridge CFTypeRef)(width) toMeta:meta];
    
    NSNumber *height = params[FullPanoHeightPixels];
    if (height == nil) height = @(size.height);
    [self setTagForPanoKey:FullPanoHeightPixels value:(__bridge CFTypeRef)(height) toMeta:meta];
    
    [self setTagForPanoKey:ProjectionType value:(__bridge CFTypeRef)(@"equirectangular") toMeta:meta];
    
    [self setTagForPanoKey:UsePanoramaViewer value:@"True" toMeta:meta];
    
    NSNumber *heading = params[PoseHeadingDegrees];
    if ((heading != nil) && [self verifyParam:heading forKey:PoseHeadingDegrees]) {
        [self setTagForPanoKey:PoseHeadingDegrees value:(__bridge CFTypeRef)(heading) toMeta:meta];
    }
    else { // for Google maps!
        [self setTagForPanoKey:PoseHeadingDegrees value:(__bridge CFTypeRef)@"360" toMeta:meta];
    }
    
    NSNumber *pitch = params[PosePitchDegrees];
    if ((pitch != nil) && [self verifyParam:heading forKey:PosePitchDegrees]) {
        [self setTagForPanoKey:PosePitchDegrees value:(__bridge CFTypeRef)(pitch) toMeta:meta];
    }
    
    NSNumber *roll = params[PoseRollDegrees];
    if ((roll != nil) && [self verifyParam:heading forKey:PoseRollDegrees]){
        [self setTagForPanoKey:PoseRollDegrees value:(__bridge CFTypeRef)(roll) toMeta:meta];
    }
    
    NSNumber *initHeading = params[InitialViewHeadingDegrees];
    if (initHeading != nil) {
        [self setTagForPanoKey:InitialViewHeadingDegrees value:(__bridge CFTypeRef)(initHeading) toMeta:meta];
    }
    
    NSNumber *initPitch = params[InitialViewPitchDegrees];
    if (initPitch != nil) {
        [self setTagForPanoKey:InitialViewPitchDegrees value:(__bridge CFTypeRef)(initPitch) toMeta:meta];
    }
    
    NSNumber *initRoll = params[InitialViewRollDegrees];
    if (initRoll != nil) {
        [self setTagForPanoKey:InitialViewRollDegrees value:(__bridge CFTypeRef)(initRoll) toMeta:meta];
    }
    
    NSNumber *hfov = params[InitialHorizontalFOVDegrees];
    if (hfov != nil) {
        [self setTagForPanoKey:InitialHorizontalFOVDegrees value:(__bridge CFTypeRef)(hfov) toMeta:meta];
    }
    
    NSNumber *vfov = params[InitialVerticalFOVDegrees];
    if (vfov != nil) {
        [self setTagForPanoKey:InitialVerticalFOVDegrees value:(__bridge CFTypeRef)(vfov) toMeta:meta];
    }
    
    NSNumber *cropLeft = params[CroppedAreaLeftPixels];
    if (cropLeft != nil) {
        [self setTagForPanoKey:CroppedAreaLeftPixels value:(__bridge CFTypeRef)(cropLeft) toMeta:meta];
    }
    
    NSNumber *cropHeight = params[CroppedAreaImageHeightPixels];
    if (cropHeight != nil) {
        [self setTagForPanoKey:CroppedAreaImageHeightPixels value:(__bridge CFTypeRef)(cropHeight) toMeta:meta];
    }
    
    NSNumber *cropTop = params[CroppedAreaTopPixels];
    if (cropTop != nil) {
        [self setTagForPanoKey:CroppedAreaTopPixels value:(__bridge CFTypeRef)(cropTop) toMeta:meta];
    }
    
    NSNumber *cropWidth = params[CroppedAreaImageWidthPixels];
    if (cropWidth != nil) {
        [self setTagForPanoKey:CroppedAreaImageWidthPixels value:(__bridge CFTypeRef)(cropWidth) toMeta:meta];
    }
    
    NSString *firstPhotoDate = params[FirstPhotoDate];
    if (firstPhotoDate != nil) {
        [self setTagForPanoKey:FirstPhotoDate value:(__bridge CFTypeRef)(firstPhotoDate) toMeta:meta];
    }
    
    NSString *lastPhotoDate = params[LastPhotoDate];
    if (lastPhotoDate != nil) {
        [self setTagForPanoKey:LastPhotoDate value:(__bridge CFTypeRef)(lastPhotoDate) toMeta:meta];
    }
    
    NSNumber *photosCount = params[SourcePhotosCount];
    if (photosCount != nil) {
        [self setTagForPanoKey:SourcePhotosCount value:(__bridge CFTypeRef)(photosCount) toMeta:meta];
    }
    
    NSNumber *lock = params[ExposureLockUsed];
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
    
    BOOL result = CGImageMetadataSetTagWithPath(meta, NULL, (CFStringRef)PP(GPano, key), tag);
    
    if (result == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Error set Pano %@ with %@", key, value);
    }
    CFRelease(tag);
    
    return result;
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
    
    if (params[Data])
    {
        CFStringRef str = (__bridge CFStringRef)params[Data];
                                                 
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
    return [UIImage imageWithCGImage:cgImage];
}

@end
