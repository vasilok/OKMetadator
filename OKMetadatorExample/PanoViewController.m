//
//  PanoViewController.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/6/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "PanoViewController.h"
#import "OKMetadator.h"

@interface PanoViewController ()
@property(nonatomic) UIImage *image;
@property(nonatomic) NSDictionary *panoDict;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PanoViewController

- (instancetype)initWithImage:(UIImage *)image pano:(NSDictionary *)panoDict
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _image = image;
        _panoDict = panoDict;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupWithSize:self.view.bounds.size];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self setupWithSize:size];
}

- (void)setupWithSize:(CGSize)size
{
    CGSize imageViewSize = CGSizeMake(size.width, size.width/2);
    
    CGFloat gPanoWidth = [_panoDict[GP(FullPanoWidthPixels)] floatValue];
    CGFloat gPanoHeight = [_panoDict[GP(FullPanoHeightPixels)] floatValue];
    CGFloat gImageWidth = [_panoDict[GP(CroppedAreaImageWidthPixels)] floatValue];
    CGFloat gImageHeight = [_panoDict[GP(CroppedAreaImageHeightPixels)] floatValue];
    CGFloat gLeft = [_panoDict[GP(CroppedAreaLeftPixels)] floatValue];
    CGFloat gTop = [_panoDict[GP(CroppedAreaTopPixels)] floatValue];
    
    if ((gImageWidth != _image.size.width) ||
        (gImageHeight != _image.size.height) ||
        (gPanoWidth != gPanoHeight * 2) ||
        (gPanoWidth != gImageWidth + gLeft * 2) ||
        (gPanoHeight != gImageHeight + gTop * 2) )
    {
        _imageView.autoresizingMask = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:@"error"];
        return;
    }
    
    CGFloat newImageWidth = gImageWidth * imageViewSize.width / gPanoWidth;
    CGFloat newImageHeight = gImageHeight * imageViewSize.height / gPanoHeight;
    
    UIImage *resized = [self resize:CGSizeMake(newImageWidth, newImageHeight) image:_image];
    
    _imageView.autoresizingMask = UIViewContentModeCenter;
    _imageView.image = resized;
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)resize:(CGSize)size image:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
