//
//  ImageViewController.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/3/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (strong) UIImage *image;
@end

@implementation ImageViewController

- (void)setupImage:(UIImage *)image
{
    [self setImage:image];
    
    if ([self isViewLoaded]) {
        [_imageView setImage:image];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_image) {
        [_imageView setImage:_image];
    }
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
