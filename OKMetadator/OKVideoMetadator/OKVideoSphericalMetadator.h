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
 * @brief Setup value for StitchingSoftware key.
 * Can be used for -make..  interface.
 * "OKMetadator" by default.
 */
@property(nonatomic, copy) NSString *stitchingSoftware;

/*!
 * @brief Getter spherical meta params of video
 * @param url indicates NSURL of original video
 * @return set of params. NSDictionary
 */
- (nonnull NSDictionary *)sphericalMetaParamsVideoAtURL:(nonnull NSURL *)url;

/*!
 * @brief Remove spherical tags from metadata
 * @param url indicates original url of video
 * @param outputURL indicates processed url of video
 * @param completion indicates success of operation.
 */
- (void)removeSphericalFromVideoAt:(NSURL *)url outputURL:(nonnull NSURL *)outputURL completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @abstract FABRICS METHODS FOR MAKING 360/180 VIDEO.
 */

/*!
* @brief export video with appended 360 spatial metadata
* @param atUrl indicates NSURL of original video
* @param toUrl indicates NSURL of desctination video
* @param completion indicates success of operation.
*/
- (void)make360VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief export video with appended 180 spatial metadata
 * @param atUrl indicates NSURL of original video
 * @param toUrl indicates NSURL of desctination video
 * @param completion indicates success of operation.
 */
- (void)make180VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief export video with appended 360 spatial and metadata
 * @param atUrl indicates NSURL of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @param completion indicates success of operation.
 * @return result
 */
- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief export video with appended 180 spatial and metadata
 * @param atUrl indicates NSURL of original video
 * @param metaParams indicates NSDictionary of metadata with @OKMetaParam format
 * @param toUrl indicates NSURL of desctination video
 * @param completion indicates success of operation.
 * @return result
 */
- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl completion:(nullable OKSphereMetaInjectorCompletion)completion;

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
