//
//  OKImageAuxMetadator.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/20/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKImageMetadator.h"

NS_ASSUME_NONNULL_BEGIN

@interface OKImageMetadator (OKImageAuxMetadator)

/*!
 * @brief extract auxiliary metadata of image at URL in friendly format
 * @param url indicates image file URL
 * @return NSDictionary with @MetaFormat
 */
- (nullable OKMetaParam *)auxMetaParamsFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract all available metadata of image at URL in friendly format.
 * Including trivial metadata and auxiliary data
 * @param url indicates image file URL
 * @return NSDictionary with @MetaFormat
 */
- (nullable OKMetaParam *)fullMetaParamsFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract auxiliary metadata of image at URL in original format
 * @param url indicates image file URL
 * @return NSDictionary with @{aux type key : NSDictionary}
 */
- (nullable NSDictionary *)auxMetadataFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract auxiliary metadata of image at URL in original format
 * @param url indicates image file URL
 * @param type indicates type of aux metadata
 * @return NSDictionary
 */
- (nullable NSDictionary *)auxMetadataFromImageAtURL:(nonnull NSURL *)url withType:(CFStringRef)type;

/*!
 * @brief extract images from auxiliary metadata
 * @param url indicates image file URL
 * @return NSDictionary with format : {aux type : UIImage}
 */
- (nullable NSDictionary *)auxImagesFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief Convert aux meta params to aux metadata original format.
 * @param aux indicates NSDictionary with @MetaFormat
 * @return NSDictionary
 */
- (nullable NSDictionary *)auxMetadataFromParams:(OKMetaParam *)aux;

/*!
 * @brief add Portarit exif tag to destination metadata. Used in common flow
 * @param meta indicates destination metadata object
 */
- (BOOL)setPortraitToMeta:(_Nonnull CGMutableImageMetadataRef)meta;

/*!
 * @brief Setup aux meta params to image destination. Used in common flow
 * @param aux indicates aux params with @MetaFormat
 * @param destination indicates target image destination object
 */
- (void)setAuxParams:(nullable NSDictionary *)aux toDestination:(_Nonnull CGImageDestinationRef)destination;

/*!
 * @brief Setup aux metadata to image destination. Used in common flow
 * @param aux indicates aux metadata
 * @param destination indicates target image destination object
 */
- (void)setAuxMetadata:(nullable NSDictionary *)aux toDestination:(_Nonnull CGImageDestinationRef)destination;

/*!
 * @brief Make "Portrait" image from image with depth map. Sync.
 * @param map indicates the depth map (grayscale)
 * @param imageURL indicates the original image url
 * @param url indicates the target url
 * @return result.
 */
- (BOOL)applyMap:(nonnull UIImage *)map
      forImageAt:(nonnull NSURL *)imageURL
      andWriteAt:(nonnull NSURL *)url;

/*!
 * @brief Make "Portrait" image from image with depth map. Sync.
 * @param map indicates the depth map (grayscale)
 * @param image indicates the original image
 * @param url indicates the target url
 * @return result.
 */
- (BOOL)applyMap:(nonnull UIImage *)map
        forImage:(nonnull UIImage *)image
      andWriteAt:(nonnull NSURL *)url;


@end

NS_ASSUME_NONNULL_END
