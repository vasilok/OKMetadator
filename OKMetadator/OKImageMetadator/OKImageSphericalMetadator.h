//
//  VSImageSphericalMetadator.h
//  VSMetadator
//
//  Created by Vasil_OK on 1/10/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageMetadator.h"

NS_ASSUME_NONNULL_BEGIN


/*!
 * @brief Injector and extractor spherical metadata from image
 * @see detail: https://developers.google.com/streetview/spherical-metadata
*/
@interface OKImageSphericalMetadator : OKImageMetadator

/*!
 * @brief Callback queue. Main by default
 */
@property(nonatomic) dispatch_queue_t completionQueue;

/*!
 * @brief Setup value for CaptureSoftware key.
 * Can be used for -make..  interface.
 * "OKMetadator" by default.
 */
@property(nonatomic, copy) NSString *captureSoftware;

/*!
 * @brief Remove GPano tags from metadata
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation.
 */
- (void)removePanoFromImageAt:(NSURL *)url outputURL:(nonnull NSURL *)outputURL completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Remove GPano tags from metadata
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)removePanoFromImageAt:(NSURL *)url outputURL:(nonnull NSURL *)outputURL;

/*!
 * @abstract FABRICS METHODS FOR MAKING 360/180 SPHERE IMAGES.
 */

/*!
 * @brief Make 360 image with image at URL. Async
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)make360ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL
               completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Make 180 image with image at URL. Async
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)make180ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL
               completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Make panorama image with image at URL. Async.
 * If one from horizontalFOV and verticalFOV is 0, other will be calculated, based on the image size.
 * @param horizntalFOV indicates horizontal field of view, in grad
 * @param verticalFOV indicates vertical field of view, in grad
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)makePanoWithHorizontalFOV:(CGFloat)horizntalFOV
                      verticalFOV:(CGFloat)verticalFOV
                            atURL:(nonnull NSURL *)url
                        outputURL:(nonnull NSURL *)outputURL
                       completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Make panorama image with image at URL. Async
 * If one from horizontalFOV and verticalFOV is 0, other will be calculated, based on the image size.
 * @param image indicates original image
 * @param horizntalFOV indicates horizontal field of view, in grad
 * @param verticalFOV indicates vertical field of view, in grad
 * @param meta indicates other metadata of image
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)makePanoImage:(nonnull UIImage *)image
    withHorizontalFOV:(CGFloat)horizntalFOV
          verticalFOV:(CGFloat)verticalFOV
                 meta:(nullable OKMetaParam *)meta
            outputURL:(nonnull NSURL *)outputURL
           completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Make 360 image with UIImage. Async
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param image indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)make360Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL
          completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Make 180 image with UIImage. Async
 * @param image indicates original url of image file
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)make180Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL
          completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Make 360 image with image at URL. Sync
 * @param url indicates image URL
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)make360ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief Make 180 image with image at URL. Sync
 * @param url indicates image URL
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)make180ImageAtURL:(nonnull NSURL *)url
                outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief Make 360 image with UIImage. Sync
 * @param image indicates original image
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)make360Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL;

/*!
 * @brief Make 180 image with UIImage. Sync
 * @param image indicates original image
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param outputURL indicates processed url of image file
 * @return result.
 */
- (BOOL)make180Image:(nonnull UIImage *)image
            withMeta:(nullable OKMetaParam *)meta
           outputURL:(nonnull NSURL *)outputURL;


/*!
 * @abstract GETTERS
 */

/*!
 * @brief Getting required pano metadata for 360 image with size.
 * @param size indicates image size
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)pano360ParamsWithSize:(CGSize)size;

/*!
 * @brief Getting required pano metadata for 180 image with size.
 * @param size indicates image size
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)pano180ParamsWithSize:(CGSize)size;

/*!
 * @brief Getting required pano metadata for image with specific FOV and size.
 * @param hFov indicates horizontal field of view image
 * @param vFov indicates vertical field of view image
 * @param size indicates image size
 * @return NSDictionary with obvious format
 */
- (nonnull NSDictionary *)panoParams:(CGFloat)hFov vFov:(CGFloat)vFov withSize:(CGSize)size;

/*!
 * @brief Getting required aspect for 360 image.
 * @return aspect (width/height)
 */
- (CGFloat)pano360Aspect;

/*!
 * @brief Getting required aspect for 180 image.
 * @return aspect (width/height)
 */
- (CGFloat)pano180Aspect;

/*!
 * @brief Getting the conventional extension for vr image
 * @return file extension
 */
- (NSString *)vrExtension;


/*!
 * @abstract CUSTOM INJECTIONS
 */

/*!
 * @brief Injection process. Async
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)injectPanoToImageAtURL:(nonnull NSURL *)url
                     outputURL:(nonnull NSURL *)outputURL
                      withMeta:(nullable OKMetaParam *)meta
                    completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Injection process. Sync
 * @param url indicates original url of image file
 * @param outputURL indicates processed url of image file
 * @param meta indicates the set of params with @MetaFormat
 * @return result
 */
- (BOOL)injectPanoToImageAtURL:(nonnull NSURL *)url
                     outputURL:(nonnull NSURL *)outputURL
                      withMeta:(nullable OKMetaParam *)meta;

/*!
 * @brief Injection process. Async
 * @param image indicates original image
 * @param outputURL indicates processed url of image file
 * @param meta indicates the set of image meta params with @MetaFormat
 * @param completion indicates success of operation. Calling in the Main queue.
 */
- (void)injectPanoToImage:(nonnull UIImage *)image
                outputURL:(nonnull NSURL *)outputURL
                 withMeta:(nullable OKMetaParam *)meta
               completion:(nullable OKSphereMetaInjectorCompletion)completion;

/*!
 * @brief Injection process. Sync
 * @param image indicates original image
 * @param outputURL indicates processed url of image file
 * @param meta indicates the set of params with @MetaFormat
 * @return result.
 */
- (BOOL)injectPanoToImage:(nonnull UIImage *)image
                outputURL:(nonnull NSURL *)outputURL
                 withMeta:(nullable OKMetaParam *)meta;

/*!
 * @brief Getting pano metadata from image URL
 * @param url indicates image url
 * @return NSDictionary with obvious format
 */
- (nullable NSDictionary *)extractPanoFromImageAtURL:(nonnull NSURL *)url;

@end

NS_ASSUME_NONNULL_END
