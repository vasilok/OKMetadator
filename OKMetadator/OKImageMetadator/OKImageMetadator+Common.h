//
//  OKImageMetadator+Common.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/20/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#ifndef OKImageMetadator_Common_h
#define OKImageMetadator_Common_h

#import "OKImageMetadator.h"

@interface OKImageMetadator (Common)

- (BOOL)processInjectionForImage:(nonnull UIImage *)image
                          output:(nonnull NSURL *)outputURL
                   withMetaParam:(nullable OKMetaParam *)param
                         copyOld:(BOOL)copyOld;

- (BOOL)processInjectionForImageURL:(nonnull NSURL *)url
                             output:(nonnull NSURL *)outputURL
                      withMetaParam:(nullable OKMetaParam *)param
                            copyOld:(BOOL)copyOld;

- (BOOL)processInjectionForImage:(_Nonnull CGImageRef)image
                          source:(_Nonnull CGImageSourceRef)source
                          output:(nonnull NSURL *)outputURL
                   withMetaParam:(nullable OKMetaParam *)param
                         copyOld:(BOOL)copyOld;

@end


#endif /* OKImageMetadator_Common_h */
