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
//@property(nonatomic, copy) OKSphereMetaInjectorCompletion completion;
@property(nonatomic, strong) AVAssetExportSession *exportSession;
@end

@implementation OKVideoMetadator

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _completionQueue = dispatch_get_main_queue();
    }
    
    return self;
}

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
    
    NSMutableDictionary *metaDict = [NSMutableDictionary new];
    
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *audioTrack = audioTracks.firstObject;
    
    [metaDict setObject:@([audioTrack estimatedDataRate] / 1024) forKey:DateRate];
    
    CMAudioFormatDescriptionRef formatDescription = NULL;
    NSArray *formatDescriptions = [audioTrack formatDescriptions];
    if ([formatDescriptions count] > 0)
        formatDescription = (CMAudioFormatDescriptionRef)CFBridgingRetain([formatDescriptions firstObject]);
    
    const AudioStreamBasicDescription *audioDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    
    if (audioDescription)
    {
        [metaDict setObject:@(audioDescription->mSampleRate / 1024) forKey:SampleRate];
        
        [metaDict setObject:@(audioDescription->mChannelsPerFrame) forKey:Channels];
        
        [metaDict setObject:@(audioDescription->mBitsPerChannel) forKey:BitsPerChannel];
        
        [metaDict setObject:@(audioDescription->mFramesPerPacket) forKey:FramesPerPacket];
        
        [metaDict setObject:@(audioDescription->mBytesPerFrame) forKey:BytesPerFrame];
    }
    
    return [metaDict copy];
}

- (nonnull NSDictionary *)videoPropertiesFromVideoAtURL:(nonnull NSURL *)url
{
    NSAssert(url, @"Unexpected NIL!");
    
    return [self videoPropertiesFromVideoAsset:[AVAsset assetWithURL:url]];
}

- (nonnull NSDictionary *)videoPropertiesFromVideoAsset:(nonnull AVAsset *)asset
{
    NSAssert(asset, @"Unexpected NIL!");
    
    NSMutableDictionary *metaDict = [NSMutableDictionary new];
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = videoTracks.firstObject;
    
    CMFormatDescriptionRef formatDescription = NULL;
    NSArray *formatDescriptions = [videoTrack formatDescriptions];
    if ([formatDescriptions count] > 0)
        formatDescription = (CMFormatDescriptionRef)CFBridgingRetain([formatDescriptions firstObject]);
    
    [metaDict setObject:@([videoTrack naturalSize]) forKey:Size];
    
    [metaDict setObject:@([videoTrack nominalFrameRate]) forKey:FrameRate];
    
    CGFloat bps = [videoTrack estimatedDataRate] / 1024;
    [metaDict setObject:@(bps) forKey:DateRate];
    
    float time = CMTimeGetSeconds(videoTrack.timeRange.duration);
    [metaDict setObject:@(time) forKey:Duration];
    
    return [metaDict copy];
}

- (BOOL)writeVideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams toURL:(nonnull NSURL *)toUrl completion:(OKSphereMetaInjectorCompletion)completion
{
    NSAssert(atUrl && toUrl, @"Unexpected NIL!");
    
    return [self writeVideoAsset:[AVAsset assetWithURL:atUrl] withMetaParams:metaParams toURL:toUrl completion:completion];
}

- (BOOL)writeVideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams toURL:(nonnull NSURL *)toUrl completion:(OKSphereMetaInjectorCompletion)completion
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
             if (completion)
             {
                 dispatch_async(blockSelf.completionQueue, ^
                 {
                     completion(blockSelf.exportSession.status == AVAssetExportSessionStatusCompleted);
                     [blockSelf setExportSession:nil];
                 });
             }
             else
             {
                 [blockSelf setExportSession:nil];
             }
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
