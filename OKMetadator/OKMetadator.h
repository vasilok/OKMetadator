//
//  OKMetadator.h
//  OKMetadator
//
//  Created by Vasil_OK on 1/23/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#ifndef VSMetadator_h
#define VSMetadator_h

#import <Foundation/Foundation.h>

/*!
 @abstract @MetaFormat = NSDictionary {"namespace" : {"prefix:name" : value}}
 */
typedef NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> OKMetaParam;

/*!
 @abstract completion block. Returns result of injection.
 */
typedef void (^OKSphereMetaInjectorCompletion)(BOOL);


/*!
 @abstract XML descriptions
 https://developers.google.com/streetview/spherical-metadata
 https://github.com/google/spatial-media/blob/master/docs/spherical-video-rfc.md
 */

// Available Image namespace
#define PanoNamespace   @"http://ns.google.com/photos/1.0/panorama/"
#define GoogleNamespace @"http://ns.google.com/photos/1.0/image/"
#define AppleNamespace  @"http://ns.apple.com/ImageIO/1.0/"

// Available Image prefixes
#define GPano   @"GPano"
#define GImage  @"GImage"
#define ImageIO @"iio"

// Image spherical specific Keys
#define FirstPhotoDate               @"FirstPhotoDate"
#define LastPhotoDate                @"LastPhotoDate"
#define SourcePhotosCount            @"SourcePhotosCount"
#define ExposureLockUsed             @"ExposureLockUsed"

#define Mime   @"Mime"
#define hasXMP @"hasXMP"

// Common Spherical Keys
#define FullPanoWidthPixels          @"FullPanoWidthPixels"
#define FullPanoHeightPixels         @"FullPanoHeightPixels"
#define UsePanoramaViewer            @"UsePanoramaViewer"
#define ProjectionType               @"ProjectionType"
#define PoseHeadingDegrees           @"PoseHeadingDegrees"
#define PosePitchDegrees             @"PosePitchDegrees"
#define PoseRollDegrees              @"PoseRollDegrees"
#define InitialViewHeadingDegrees    @"InitialViewHeadingDegrees"
#define InitialViewPitchDegrees      @"InitialViewPitchDegrees"
#define InitialViewRollDegrees       @"InitialViewRollDegrees"
#define InitialHorizontalFOVDegrees  @"InitialHorizontalFOVDegrees"
#define InitialVerticalFOVDegrees    @"InitialVerticalFOVDegrees"
#define CroppedAreaLeftPixels        @"CroppedAreaLeftPixels"
#define CroppedAreaImageHeightPixels @"CroppedAreaImageHeightPixels"
#define CroppedAreaTopPixels         @"CroppedAreaTopPixels"
#define CroppedAreaImageWidthPixels  @"CroppedAreaImageWidthPixels"

// Video namespace(head rdf)
#define SphericalVideo @"SphericalVideo"

// Video prefix
#define GSpherical @"GSpherical"

// Video spherical specific Keys
#define Spherical         @"Spherical"
#define Stitched          @"Stitched"
#define StitchingSoftware @"StitchingSoftware"
#define StereoMode        @"StereoMode"
#define SourceCount       @"SourceCount"
#define Timestamp         @"Timestamp"

// value for ProjectionType only supported
#define equirectangular @"equirectangular"

// values for StereoMode key:
#define mono       @"mono"
#define left_right @"left-right"
#define top_bottom @"top-bottom"

#define PP(prefix, param) [NSString stringWithFormat:@"%@:%@", prefix, param]


#endif /* VSMetadator_h */
