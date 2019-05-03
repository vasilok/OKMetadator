//
//  OKJpegParser.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/3/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OKJpegParser : NSObject

- (NSData *)xmpFromURL:(NSURL *)imageURL;

@end

NS_ASSUME_NONNULL_END
