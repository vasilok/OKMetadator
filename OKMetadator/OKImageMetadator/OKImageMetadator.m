//
//  VSImageMetadator.m
//  VSMetadator
//
//  Created by Vasil_OK on 1/14/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageMetadator.h"
#import <os/log.h>

@implementation OKImageMetadator

#pragma mark Getters

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

- (CGImageMetadataRef)auxMetaFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSDictionary *dict = CFBridgingRelease(CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity));
    
    CGImageMetadataRef meta = CFBridgingRetain([dict objectForKey:AUX_META]);
    
    return meta;
}

- (NSDictionary *)auxDictionaryFromImageAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (source == NULL)
    {
        os_log_error(OS_LOG_DEFAULT, "Could not create image source at URL: %@", url);
        return nil;
    }
    
    NSMutableDictionary *dict = [CFBridgingRelease(CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity)) mutableCopy];
    CGImageMetadataRef meta = CFBridgingRetain([dict objectForKey:AUX_META]);
    dict[AUX_META] = [self metaParamsFromMetadata:meta];
    CFRelease(meta);
    
    return [dict copy];
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

- (nullable OKMetaParam *)auxMetaParamsFromImageAtURL:(nonnull NSURL *)url
{
    CGImageMetadataRef metadata = [self auxMetaFromImageAtURL:url];
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
    [full addEntriesFromDictionary:[self auxDictionaryFromImageAtURL:url]];
    
    return [full copy];
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
    
    NSDictionary *dict = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
    
    CFRelease(source);
    
    return dict;
}

- (BOOL)writeImage:(UIImage *)image
          withMeta:(nullable CGImageMetadataRef)meta
        properties:(nullable NSDictionary *)props
             atURL:(nonnull NSURL *)imageURL
{
    return [self processImage:image properties:props meta:meta atURL:imageURL];
}

- (BOOL)writeImage:(UIImage *)image withMetaParams:(nullable OKMetaParam *)metaParams properties:(nullable NSDictionary *)props atURL:(nonnull NSURL *)imageURL
{
    CGImageMetadataRef metadata = [self metadataFromMetaParams:metaParams];
    
    BOOL result = [self processImage:image properties:props meta:metadata atURL:imageURL];
    
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
        }
    }
    
    return meta;
}

- (CGImageMetadataTagRef)tagFrom:(NSObject<NSCopying> *)value withName:(NSString *)name prefix:(NSString *)prefix namespace:(NSString *)namespace
{
    if ([value isKindOfClass:[NSString class]])
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
        
        if ([arValue isKindOfClass:[NSString class]])
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
        
        if ([keyValue isKindOfClass:[NSString class]])
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
                
                if ([arValue isKindOfClass:[NSString class]]) {
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
                
                if ([keyValue isKindOfClass:[NSString class]])
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
    
    return [self processImage:image properties:mutProps meta:nil atURL:url];
}

- (BOOL)processImage:(nonnull UIImage *)image properties:(nullable NSDictionary *)properties meta:(CGImageMetadataRef)meta atURL:(nonnull NSURL *)url
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
        CGImageDestinationAddImageAndMetadata(destination, image.CGImage, meta, NULL);
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)properties);
    }
    else
    {
        CGImageDestinationAddImage(destination, image.CGImage, (CFDictionaryRef)properties);
    }
    
    
    
    /* Depth data support for JPEG, HEIF, and DNG images.
     * The auxiliaryDataInfoDictionary should contain:
     *   - the depth data (CFDataRef) - (kCGImageAuxiliaryDataInfoData),
     *   - the depth data description (CFDictionary) - (kCGImageAuxiliaryDataInfoDataDescription)
     *   - metadata (CGImageMetadataRef) - (kCGImageAuxiliaryDataInfoMetadata)
     * To add depth data to an image, call CGImageDestinationAddAuxiliaryDataInfo() after adding the CGImage to the CGImageDestinationRef.
     */
   // IMAGEIO_EXTERN void CGImageDestinationAddAuxiliaryDataInfo(CGImageDestinationRef _iio_Nonnull idst, CFStringRef _iio_Nonnull auxiliaryImageDataType, CFDictionaryRef _iio_Nonnull auxiliaryDataInfoDictionary ) IMAGEIO_AVAILABLE_STARTING(10.13, 11.0);
    
    
    
    
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

- (UIImage *)resizeAspect:(CGFloat)newAspect image:(UIImage *)image
{
    CGFloat aspect = image.size.width/image.size.height;
    
    if (aspect != newAspect)
    {
        CGFloat delta = newAspect/aspect;
        CGSize renderSize = CGSizeMake(image.size.width * delta, image.size.height);
        
        return [self resize:renderSize image:image];
    }
    
    return image;
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
