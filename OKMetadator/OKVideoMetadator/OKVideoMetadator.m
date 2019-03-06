//
//  VSVideoMetadator.m
//  VSMetadator
//
//  Created by Vasil_OK on 1/22/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKVideoMetadator.h"
#import <UIKit/UIKit.h>
#import <os/log.h>

@interface OKVideoMetadator ()
@property(nonatomic, strong) AVAssetExportSession *exportSession;
@end

@implementation OKVideoMetadator

#pragma mark Metadata getters

- (nonnull OKMetaParam *)metaParamsFromVideoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self metaParamsFromVideoAsset:[AVAsset assetWithURL:url]];
}

- (nonnull OKMetaParam *)metaParamsFromVideoAsset:(nonnull AVAsset *)asset
{
    NSAssert(asset, @"Unexpected NIL!");
    
    NSArray<AVMetadataItem *> *items = asset.metadata;
    
    OKMetaParam *params = [self metaParamsFromItems:items];
    
    return params;
}

- (nullable id)metaValueForKey:(nonnull NSString *)key videoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self metaValueForKey:key videoAtURL:url];
}

- (nullable id)metaValueForKey:(nonnull NSString *)key videoAsset:(nonnull AVAsset *)asset
{
    AVMetadataItem *item = [[[asset metadata] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier=%@", key]] firstObject];
    
    return [self valueFromItem:item];
}

#pragma mark Metadata setters

#pragma mark Properties

- (nonnull NSDictionary *)audioPropertiesFromVideoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self audioPropertiesFromVideoAsset:[AVAsset assetWithURL:url]];
}

- (nonnull NSDictionary *)audioPropertiesFromVideoAsset:(nonnull AVAsset *)asset
{
    NSAssert(asset, @"Unexpected NIL!");
    
    return @{};
}

- (nonnull NSDictionary *)videoPropertiesFromVideoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self videoPropertiesFromVideoAsset:[AVAsset assetWithURL:url]];
}

- (nonnull NSDictionary *)videoPropertiesFromVideoAsset:(nonnull AVAsset *)asset
{
    NSAssert(asset, @"Unexpected NIL!");
    
    return @{};
}

- (BOOL)writeVideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams toURL:(nonnull NSURL *)toUrl
{
    NSAssert(atUrl && toUrl, @"Unexpected NIL!");
    
    return [self writeVideoAsset:[AVAsset assetWithURL:atUrl] withMetaParams:metaParams toURL:toUrl];
}

- (BOOL)writeVideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams toURL:(nonnull NSURL *)toUrl
{
    NSAssert(asset && toUrl, @"Unexpected NIL!");
    
    NSArray <AVMetadataItem *> *oldItems = [asset metadata];
    
    if ([self checkMetaParams:metaParams] == NO)
    {
        os_log_error(OS_LOG_DEFAULT, "Error meta params: %@", metaParams);
    }
    NSArray <AVMetadataItem *> *newMeta = [self metaItemsFromParams:metaParams];
    
    NSMutableArray *metaItems = [NSMutableArray new];
    [oldItems enumerateObjectsUsingBlock:^(AVMetadataItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if ([[newMeta filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier=%@", obj.identifier]] count] == 0)
        {
            [metaItems addObject:obj];
        }
    }];
    [metaItems addObjectsFromArray:newMeta];
    
    //NSLog(@"Meta to inject: \n%@", metaItems);
    //NSLog(@"Meta to inject: \n%@", [self metaParamsFromItems:metaItems]);
    
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    _exportSession.outputURL = toUrl;
    _exportSession.outputFileType = AVFileTypeMPEG4;
    _exportSession.metadata = [metaItems copy];
    
    __weak typeof (self) blockSelf = self;
    @autoreleasepool
    {
        [_exportSession exportAsynchronouslyWithCompletionHandler:^
         {
             if (blockSelf.handler)
             {
                 blockSelf.handler(blockSelf.exportSession.status == AVAssetExportSessionStatusCompleted);
             }
             [blockSelf setExportSession:nil];
         }];
    }
    
    return YES;
}

#pragma mark Private

- (BOOL)checkMetaParams:(OKMetaParam *)params
{
    __block BOOL result = YES;
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary<NSString *,NSString *> * _Nonnull obj, BOOL * _Nonnull stop)
    {
        if (key.length != 4)
        {
            result = NO;
            *stop = YES;
        }
        
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop)
        {
            if (key.length != 4)
            {
                result = NO;
                *stop = YES;
            }
        }];
    }];
    
    return result;
}

- (OKMetaParam *)metaParamsFromItems:(NSArray <AVMetadataItem *> *)items
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [items enumerateObjectsUsingBlock:^(AVMetadataItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *identifier = obj.identifier;
        
        NSString *key;
        if ([obj.key isKindOfClass:[NSString class]])
        {
            key = (NSString *)obj.key;
        }
        else
        {
            key = [[identifier componentsSeparatedByString:@"/"] lastObject];
        }

        NSString *namespace = obj.keySpace;
        
        if (dict[namespace] == nil) {
            dict[namespace] = @{};
        }
        
        NSMutableDictionary *namespaceDict = [dict[namespace] mutableCopy];
        id value = [self valueFromItem:obj];
        [namespaceDict setObject:value forKey:key];
        dict[namespace] = namespaceDict;
    }];
    
    return [dict copy];
}

- (nonnull id)valueFromItem:(AVMetadataItem *)item
{
    id value = item.stringValue;
    if (value == nil)
    {
        value = item.dataValue;
        
        NSString *strValue = [[NSString alloc] initWithData:(NSData *)value encoding:NSUTF8StringEncoding];
        if (strValue)
        {
            value = strValue;
            value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
    }
        
    return value;
}

- (NSArray <AVMetadataItem *> *)metaItemsFromParams:(OKMetaParam *)params
{
    NSMutableArray *metaArray = [NSMutableArray new];
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull namespace, NSDictionary<NSString *,NSString *> * _Nonnull obj, BOOL * _Nonnull stop)
    {
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull keyParam, NSString * _Nonnull valueParam, BOOL * _Nonnull stop) {
            
            AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];

            AVMetadataIdentifier ident = [AVMetadataItem identifierForKey:keyParam
                                                                 keySpace:namespace];
            if (ident != nil)
            {
                item.identifier = ident;
            }
            else
            {
                item.keySpace = namespace;
                item.key = keyParam;
            }
            
            item.value = [valueParam dataUsingEncoding:NSUTF8StringEncoding];
            item.dataType = @"com.apple.metadata.datatype.raw-data";
            
            [metaArray addObject:item];
        }];
    }];
    
    return [metaArray copy];
}

@end

@implementation NSData (SafePrint)

- (NSString *)description
{
    return [NSString stringWithFormat:@"<...> length=%ld", self.length];
}

@end
