//
//  VSVideoSphericalMetadator.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 3/6/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKVideoSphericalMetadator.h"

@implementation OKVideoSphericalMetadator

- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make360VideoAsset:(nonnull AVAsset *)asset andWritetoURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl andWriteToURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make180VideoAsset:(nonnull AVAsset *)asset andWritetoURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make360VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make360VideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams writetoURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make180VideoAtURL:(nonnull NSURL *)atUrl withMetaParams:(nullable OKMetaParam *)metaParams writeToURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (BOOL)make180VideoAsset:(nonnull AVAsset *)asset withMetaParams:(nullable OKMetaParam *)metaParams writetoURL:(nonnull NSURL *)toUrl
{
    return NO;
}

- (nonnull NSDictionary *)spatial360ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[Spherical] = @"true";
    updParams[Stitched] = @"true";
    updParams[StitchingSoftware] = @"OKMetadator";
    updParams[ProjectionType] = @"equirectangular";
    updParams[InitialViewHeadingDegrees] = @(0);
    updParams[InitialViewPitchDegrees] = @(0);
    updParams[InitialViewRollDegrees] = @(0);
    updParams[InitialHorizontalFOVDegrees] = @(75.0);
    updParams[PoseHeadingDegrees] = @(360);
    updParams[FullPanoWidthPixels] = @(size.width);
    updParams[FullPanoHeightPixels] = @(size.height);
    updParams[CroppedAreaImageWidthPixels] = @(size.width);
    updParams[CroppedAreaImageHeightPixels] = @(size.height);
    updParams[CroppedAreaLeftPixels] = @(0);
    updParams[CroppedAreaTopPixels] = @(0);
    
    return [updParams copy];
}

- (nonnull NSDictionary *)spatial180ParamsWithSize:(CGSize)size
{
    NSMutableDictionary *updParams = [NSMutableDictionary new];
    
    updParams[Spherical] = @"true";
    updParams[Stitched] = @"true";
    updParams[StitchingSoftware] = @"OKMetadator";
    updParams[ProjectionType] = @"equirectangular";
    updParams[SourceCount] = @(2);
    updParams[InitialViewHeadingDegrees] = @(0);
    updParams[InitialViewPitchDegrees] = @(0);
    updParams[InitialViewRollDegrees] = @(0);
    updParams[InitialHorizontalFOVDegrees] = @(75.0);
    updParams[PoseHeadingDegrees] = @(360);
    updParams[FullPanoWidthPixels] = @(size.width * 2);
    updParams[FullPanoHeightPixels] = @(size.height);
    updParams[CroppedAreaImageWidthPixels] = @(size.width);
    updParams[CroppedAreaImageHeightPixels] = @(size.height);
    updParams[CroppedAreaLeftPixels] = @(size.width/2);
    updParams[CroppedAreaTopPixels] = @(0);
    
    return [updParams copy];
}

@end
