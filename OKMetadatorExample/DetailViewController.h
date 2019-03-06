//
//  DetailViewController.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 2/28/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Librarian.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController

@property(nonatomic) Librarian *librarian;

- (void)setupWithImageURL:(NSURL * _Nonnull)imageURL;
- (void)setupWithVideoURL:(NSURL * _Nonnull)videoURL;

@end

NS_ASSUME_NONNULL_END
