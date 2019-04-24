//
//  VSImageMetadator.h
//  VSMetadator
//
//  Created by Vasil_OK on 1/14/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "OKMetadator.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * @brief Doing with image properties and metadata
 */
@interface OKImageMetadator : OKMetadator

/*!
 * @brief extract metadata of image at URL.
 * @param url indicates image file URL
 * @return CGImageMetadataRef. Caller is responsible of lifetime of object
 */
- (CGImageMetadataRef)metaFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract metadata of image at URL in friendly format
 * @param url indicates image file URL
 * @return NSDictionary with @MetaFormat
 */
- (nullable OKMetaParam *)metaParamsFromImageAtURL:(nonnull NSURL *)url;

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
 * @brief extract XMP data of image at URL
 * @param url indicates image file URL
 * @return NSData
 */
- (nullable NSData *)xmpFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief extract properties of image at URL
 * @param url indicates image file URL
 * @return NSDictionary with obvious format
 */
- (nullable NSDictionary *)propertiesFromImageAtURL:(nonnull NSURL *)url;

/*!
 * @brief writer image with meta/props
 * @param image indicates UIImage
 * @param meta indicates metadata CGImageMetadataRef
 * @param aux indicates auxiliarity dictionary.
 * If not nil this can reject some metadata from @meta param.
 * @param props indicates properties NSDictionary with obvious format
 * @return result
 */
- (BOOL)writeImage:(UIImage *)image
          withMeta:(nullable CGImageMetadataRef)meta
           auxDict:(nullable NSDictionary *)aux
        properties:(nullable NSDictionary *)props
             atURL:(nonnull NSURL *)imageURL;

/*!
 * @brief writer image with meta/props
 * @param image indicates UIImage
 * @param metaParams indicates metadata NSDictionary with @MetaFormat
 * @param props indicates properties NSDictionary with obvious format
 * @return result
 */
- (BOOL)writeImage:(UIImage *)image
    withMetaParams:(nullable OKMetaParam *)metaParams
        properties:(nullable NSDictionary *)props
             atURL:(nonnull NSURL *)imageURL;

/*!
 * @brief inject XMP data and write with image at URL
 * @param image indicates image
 * @param xmpData indicates XMP data
 * @param url indicates file path url
 * @return result
 */
- (BOOL)writeImage:(nonnull UIImage *)image
           withXMP:(nonnull NSData *)xmpData
        properties:(nullable NSDictionary *)props
             atURL:(nonnull NSURL *)url;



/*!
 @abstract Converters CGMetadata to @MetaFormat and back
 */

/*!
 * @brief Convert meta params to CGImageMetadataRef. Caller should release object
 * @param params indicates NSDictionary with @MetaFormat
 * @return CGImageMetadataRef
 */
- (nonnull CGImageMetadataRef)metadataFromMetaParams:(nonnull OKMetaParam *)params;

/*!
 * @brief Convert CGImageMetadataRef to NSDcitionary with @MetaFormat.
 * @param meta indicates CGImageMetadataRef
 * @return NSDcitionary with @MetaFormat
 */
- (nonnull OKMetaParam *)metaParamsFromMetadata:(nonnull CGImageMetadataRef)meta;

/*!
 * @brief Extract auxiliarity dictionary from meta params
 * @param params indicates NSDictionary with @MetaFormat
 * @return NSDictionary
 */
- (nullable NSDictionary *)auxDictionaryFromMetaParams:(OKMetaParam *)params;


/*!
 @abstract Resizing, location, data
 */

/*!
 * @brief resize image
 * @param aspect indicates desired image aspect width/height
 * @param image indicates the image
 * @return result image
 */
- (nonnull UIImage *)resizeAspect:(CGFloat)aspect
                            image:(nonnull UIImage *)image;

/*!
 * @brief resize image and update existing metadata
 * @param aspect indicates desired image aspect width/height
 * @param image indicates the image
 * @param props indicates the properties for image
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resizeAspect:(CGFloat)aspect
               image:(nonnull UIImage *)image
      withProperties:(nullable NSDictionary *)props
         andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize image and update existing metadata
 * @param size indicates the new size of image
 * @param image indicates the image
 * @param props indicates the properties for image
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resize:(CGSize)size
         image:(nonnull UIImage *)image
withProperties:(nullable NSDictionary *)props
   andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief append location and date to existing metadata
 * @param location indicates desired location
 * @param date indicates desired date
 * @param image indicates the image
 * @param props indicates the properties for image
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)addLocation:(nullable CLLocation *)location
       creationDate:(nullable NSDate *)date
            toImage:(nonnull UIImage *)image
     withProperties:(nullable NSDictionary *)props
        andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize and append location and date to existing metadata
 * @param aspect indicates desired image aspect width/height
 * @param location indicates desired location
 * @param date indicates desired date
 * @param image indicates the image
 * @param props indicates the properties for image
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resizeAspect:(CGFloat)aspect
         addLocation:(nullable CLLocation *)location
        creationDate:(nullable NSDate *)date
               image:(nonnull UIImage *)image
      withProperties:(nullable NSDictionary *)props
         andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize and append location and date to existing metadata
 * @param size indicates desired size of image
 * @param location indicates desired location
 * @param date indicates desired date
 * @param image indicates the image
 * @param props indicates the properties for image
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resize:(CGSize)size
   addLocation:(nullable CLLocation *)location
  creationDate:(nullable NSDate *)date
       toImage:(nonnull UIImage *)image
withProperties:(nullable NSDictionary *)props
   andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize image with URL and update existing metadata
 * @param aspect indicates desired image aspect width/height
 * @param imageURL indicates the image URL
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resizeAspect:(CGFloat)aspect
          imageAtURL:(nonnull NSURL *)imageURL
         andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize image with URL and update existing metadata
 * @param size indicates desired size of image
 * @param imageURL indicates the image URL
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resize:(CGSize)size
    imageAtURL:(nonnull NSURL *)imageURL
   andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief append location and date to existing metadata of image at URL
 * @param location indicates desired location
 * @param date indicates desired date
 * @param imageURL indicates the image URL
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)addLocation:(nullable CLLocation *)location
       creationDate:(nullable NSDate *)date
       toImageAtURL:(nonnull NSURL *)imageURL
        andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize and append location and date to existing metadata of image at URL
 * @param aspect indicates desired image aspect (width/height)
 * @param location indicates desired location
 * @param date indicates desired date
 * @param imageURL indicates the image URL
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resizeAspect:(CGFloat)aspect
         addLocation:(nullable CLLocation *)location
        creationDate:(nullable NSDate *)date
          imageAtURL:(nonnull NSURL *)imageURL
         andWriteURL:(nonnull NSURL *)url;

/*!
 * @brief resize and append location and date to existing metadata of image at URL
 * @param size indicates desired size of image
 * @param location indicates desired location
 * @param date indicates desired date
 * @param imageURL indicates the image URL
 * @param url indicates file path url for writing
 * @return result
 */
- (BOOL)resize:(CGSize)size
   addLocation:(nullable CLLocation *)location
  creationDate:(nullable NSDate *)date
  toImageAtURL:(nonnull NSURL *)imageURL
   andWriteURL:(nonnull NSURL *)url;

@end

NS_ASSUME_NONNULL_END
