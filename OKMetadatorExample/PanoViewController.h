//
//  PanoViewController.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/6/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PanoViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image pano:(NSDictionary *)panoDict;

@end

NS_ASSUME_NONNULL_END
