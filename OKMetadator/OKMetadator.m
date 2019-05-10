//
//  OKMetadator.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 4/24/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "OKMetadator.h"
#import <UIKit/UIKit.h>

@implementation OKMetadator

- (nonnull NSDictionary *)filePropertiesFromURL:(nonnull NSURL *)url
{
    NSNumber *fileSizeValue = nil;
    [url getResourceValue:&fileSizeValue
                   forKey:NSURLFileSizeKey
                    error:nil];
    CGFloat mb = [fileSizeValue longValue] / 1024.0 / 1024.0;
    
    return @{FileSize : @(mb)};
}

@end

@implementation NSData (SafePrint)

- (NSString *)description
{
    return [NSString stringWithFormat:@"<...> length=%ld", self.length];
}

@end
