//
//  OKImageGVRMetadator.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/2/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageMetadator.h"

NS_ASSUME_NONNULL_BEGIN

@interface OKImageMetadator ( OKImageGVRMetadator )

/*!
 * @abstract FABRICS METHODS FOR MAKING 180 VR SBS SPHERE IMAGES.
 * https://developers.google.com/vr/reference/cardboard-camera-vr-photo-format
 */

/*!
 * @brief Make VR image with side by side layout. Sync.
 * Additional image will placed to GImage:Data key
 * @param leftImage indicates the left eye image
 * @param rightImage indicates the right eye image
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)makeVRLeftImage:(nonnull UIImage *)leftImage
             rightImage:(nonnull UIImage *)rightImage
               withMeta:(nullable OKMetaParam *)meta
              outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief Make VR image with side by side layout. Sync.
 * Additional image will placed to GImage:Data key
 * @param sbsImage indicates the sbs image
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)makeVRWithSBSImage:(nonnull UIImage *)sbsImage
                  withMeta:(nullable OKMetaParam *)meta
                 outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief Getting the conventional extension for vr image
 * @return file extension
 */
- (NSString *)vrExtension;

/*!
 * @abstract FABRICS METHODS FOR MAKING GOOGLE DEPTH MAPIMAGES
 * https://developers.google.com/depthmap-metadata/reference
 */

/*!
 * @brief Make image with depth map. Sync.
 * Depth image will placed to GDepth:Data key
 * @param image indicates the original image
 * @param depthImage indicates the depth image
 * @param near indicates the near distance in meters
 * @param far indicates the far distance in meters
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)makeDepthMapWithImage:(nonnull UIImage *)image
                   depthImage:(nonnull UIImage *)depthImage
                         near:(CGFloat)near
                          far:(CGFloat)far
                    outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief make Dictionary with meta params for image with depth map
 * @param depthImage indicates the depth image
 * @param near indicates the near distance in meters
 * @param far indicates the far distance in meters
 * @return NSDictionary
 */
- (nullable NSDictionary *)depthParamsWithDepthImage:(UIImage *)depthImage
                                                near:(CGFloat)near
                                                 far:(CGFloat)far;


/*!
 * @brief make CIImage depth map from GDepth:Data
 * @param url indicates image file URL
 * @return CIImage
 */
- (nullable CIImage *)depthCIImageFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief make UIImage depth map from GDepth:Data
 * @param url indicates image file URL
 * @return UIImage
 */
- (nullable UIImage *)depthImageFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief make CIImage depth map from GImage:Data
* @param url indicates image file URL
* @return CIImage
*/
- (nullable CIImage *)dataCIImageFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief make UIImage depth map from GImage:Data
 * @param url indicates image file URL
 * @return UIImage
 */
- (nullable UIImage *)dataImageFromImageAtURL:(nonnull NSURL *)url;

@end

NS_ASSUME_NONNULL_END
