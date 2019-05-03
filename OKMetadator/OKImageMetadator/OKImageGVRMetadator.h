//
//  OKImageGVRMetadator.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/2/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageMetadator.h"

NS_ASSUME_NONNULL_BEGIN

@interface OKImageGVRMetadator : OKImageMetadator

/*!
 * @abstract FABRICS METHODS FOR MAKING 180 VR SBS SPHERE IMAGES.
 * https://developers.google.com/vr/reference/cardboard-camera-vr-photo-format
 */

/*!
 * @brief Make VR 180 image with side by side layout. Sync
 * @param leftImage indicates the left eye image
 * @param rightImage indicates the right eye image
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)make180VRLeftImage:(nonnull UIImage *)leftImage
                rightImage:(nonnull UIImage *)rightImage
                  withMeta:(nullable OKMetaParam *)meta
                 outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief Make VR 180 image with side by side layout. Sync
 * @param sbsImage indicates the 180 sbs image
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)make180VRWithSBSImage:(nonnull UIImage *)sbsImage
                     withMeta:(nullable OKMetaParam *)meta
                    outputURL:(nonnull NSURL *)outputURL;


/*!
 * @abstract FABRICS METHODS FOR MAKING GOOGLE DEPTH MAPIMAGES
 * https://developers.google.com/depthmap-metadata/reference
 */
- (BOOL)makeDepthMapWithImage:(nonnull UIImage *)image
                   depthImage:(nonnull UIImage *)depthImage
                         near:(CGFloat)near
                          far:(CGFloat)far
                    outputURL:(nonnull NSURL *)outputURL;

- (nullable NSDictionary *)depthParamsWithDepthImage:(UIImage *)depthImage
                                                near:(CGFloat)near
                                                 far:(CGFloat)far;


@end

NS_ASSUME_NONNULL_END
