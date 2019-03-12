//
//  VSVideoMetadator.h
//  VSMetadator
//
//  Created by Vasil_OK on 1/22/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "OKMetadator.h"

NS_ASSUME_NONNULL_BEGIN


@interface OKVideoMetadator : NSObject

/*!
 * @brief Callback queue. Main by default
 */
@property(nonatomic) dispatch_queue_t completionQueue;

/*!
 * @abstract iTunes Metadata ????
 */


/*!
 * @abstract All Metadata
 */

/*!
 * @brief extract metadata of video
 * @param url indicates video file URL
 * @return NSDictionary with format: @OKMetaParam
 */
- (nonnull OKMetaParam *)metaParamsFromVideoAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract metadata of video
 * @param asset indicates video AVAsset
 * @return NSDictionary with format: NSDictionary[namespace][identifier] = value
 */
- (nonnull OKMetaParam *)metaParamsFromVideoAsset:(nonnull AVAsset *)asset;

/*!
 * @brief extract specific metaitem of video
 * @param key indicates meta key
 * @param url indicates video file URL
 * @return NSData/NSString object
 */
- (nullable id)metaValueForKey:(nonnull NSString *)key videoAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract specific metaitem of video
 * @param key indicates meta key
 * @param asset indicates video AVAsset
 * @return NSData/NSString object
 */
- (nullable id)metaValueForKey:(nonnull NSString *)key videoAsset:(nonnull AVAsset *)asset;



/*!
 * @abstract Properies
 */

/*!
 * @brief extract basic audio properties
 * @param url indicates video file URL
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)audioPropertiesFromVideoAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract basic audio properties
 * @param asset indicates video AVAsset
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)audioPropertiesFromVideoAsset:(nonnull AVAsset *)asset;

/*!
 * @brief extract basic video properties
 * @param url indicates video file URL
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)videoPropertiesFromVideoAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract basic video properties
 * @param asset indicates video AVAsset
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)videoPropertiesFromVideoAsset:(nonnull AVAsset *)asset;


/*!
 * @abstract Writers
 */

/*!
 * @brief export video with appended metadata
 * @param atUrl indicates NSURL of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @param completion indicates the compeltion block
 * @return result
 */
- (BOOL)writeVideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams toURL:(nonnull NSURL *)toUrl completion:(OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief export video with appended metadata
 * @param asset indicates AVAsset of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @param completion indicates the compeltion block
 * @return result
 */
- (BOOL)writeVideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams toURL:(nonnull NSURL *)toUrl completion:(OKSphereMetaInjectorCompletion)completion;

@end

NS_ASSUME_NONNULL_END
