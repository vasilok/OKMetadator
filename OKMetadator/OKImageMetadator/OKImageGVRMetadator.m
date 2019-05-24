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
#import "OKImageMetadator+Common.h"

@implementation OKImageMetadator ( OKImageGVRMetadator )

#pragma mark VR

- (BOOL)makeVRLeftImage:(nonnull UIImage *)leftImage
             rightImage:(nonnull UIImage *)rightImage
               withMeta:(nullable OKMetaParam *)meta
              outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(leftImage && rightImage && outputURL, @"Unexpected NIL!");
    
    return [self processMakeVRLeft:leftImage right:rightImage withMeta:meta outputURL:outputURL];
}

- (BOOL)makeVRWithSBSImage:(nonnull UIImage *)sbsImage
                  withMeta:(nullable OKMetaParam *)meta
                 outputURL:(nonnull NSURL *)outputURL
{
    NSAssert(sbsImage && outputURL, @"Unexpected NIL!");
    
    UIImage *leftImage = [self extractLeft:YES fromSBS:sbsImage];
    UIImage *rightImage = [self extractLeft:NO fromSBS:sbsImage];
    
    return [self processMakeVRLeft:leftImage right:rightImage withMeta:meta outputURL:outputURL];
}

- (NSString *)vrExtension
{
    return @"vr.jpg";
}

#pragma mark Depth

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

- (nullable NSDictionary *)dataImagesFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    OKMetaParam *metaparam = [self metaParamsFromImageAtURL:url];
    
    if (metaparam[GoogleNamespace]) {
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        
        UIImage *gImage = [self gImageFromString:metaparam[GoogleNamespace][PP(GImage,Data)]];
        if (gImage) {
            result[PP(GImage,Data)] = gImage;
        }
        UIImage *dImage = [self gImageFromString:metaparam[GDepthNamespace][DP(Data)]];
        if (dImage) {
            result[DP(Data)] = dImage;
        }
        
        return result;
    }
    
    return nil;
}

- (BOOL)convertDepthImageAt:(nonnull NSURL *)depthImageURL
         toDisparityImageAt:(nonnull NSURL *)disparityURL
{
    return NO;
}

#pragma mark Private

- (UIImage *)gImageFromString:(NSString *)string
{
    if (string) {
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [UIImage imageWithData:imageData];
    }
    
    return nil;
}

- (BOOL)processMakeVRLeft:(UIImage *)leftImage
                    right:(UIImage *)rightImage
                 withMeta:(nullable OKMetaParam *)meta
                outputURL:(NSURL *)outputURL
{
    NSMutableDictionary *allParams = meta ? [meta mutableCopy] : [NSMutableDictionary new];
    
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
        os_log_error(OS_LOG_DEFAULT, "Could not create right image");
    }
    
    return [self writeImage:leftImage withMetaParams:allParams properties:nil atURL:outputURL];
}

- (UIImage *)extractLeft:(BOOL)left fromSBS:(UIImage *)sbsImage
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

@end
