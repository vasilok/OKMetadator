//
//  VSVideoSphericalMetadator.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 3/6/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKVideoMetadator.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @brief Injector and extractor spherical metadata from/to video
 * @see detail: https://github.com/google/spatial-media/blob/master/docs/spherical-video-rfc.md
 */

@interface OKVideoSphericalMetadator : OKVideoMetadator

/*!
 * @abstract FABRICS METHODS FOR MAKING 360/180 VIDEO.
 */


/*!
* @brief export video with appended 360 spatial metadata
* @param atUrl indicates NSURL of original video
* @param toUrl indicates NSURL of desctination video
* @return result
*/
- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 360 spatial metadata
 * @param asset indicates AVAsset of original video
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make360VideoAsset:(nonnull AVAsset *)asset andWritetoURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 180 spatial metadata
 * @param atUrl indicates NSURL of original video
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 1860 spatial metadata
 * @param asset indicates AVAsset of original video
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make180VideoAsset:(nonnull AVAsset *)asset andWritetoURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 360 spatial and metadata
 * @param atUrl indicates NSURL of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 360 spatial and metadata
 * @param asset indicates AVAsset of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make360VideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams writetoURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 180 spatial and metadata
 * @param atUrl indicates NSURL of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl;

/*!
 * @brief export video with appended 180 spatial and metadata
 * @param asset indicates AVAsset of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @return result
 */
- (BOOL)make180VideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams writetoURL:(nonnull NSURL *)toUrl;

/*!
 * @brief Getting required pano metadata for 360 video with size.
 * @param size indicates image size
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)spatial360ParamsWithSize:(CGSize)size;

/*!
 * @brief Getting required pano metadata for 180 video with size.
 * @param size indicates image size
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)spatial180ParamsWithSize:(CGSize)size;


@end

NS_ASSUME_NONNULL_END
