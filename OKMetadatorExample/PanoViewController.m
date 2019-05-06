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
@property(nonatomic) BOOL isImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation PanoViewController

- (instancetype)initWithImage:(UIImage *)image fromImage:(BOOL)fromImage pano:(NSDictionary *)panoDict
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _image = image;
        _panoDict = panoDict;
        _isImage = fromImage;
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
    
    CGFloat gPanoWidth = _isImage ? [_panoDict[GP(FullPanoWidthPixels)] floatValue] : [_panoDict[FullPanoWidthPixels] floatValue];
    CGFloat gPanoHeight = _isImage ? [_panoDict[GP(FullPanoHeightPixels)] floatValue] : [_panoDict[FullPanoHeightPixels] floatValue];
    CGFloat gImageWidth = _isImage ? [_panoDict[GP(CroppedAreaImageWidthPixels)] floatValue] : [_panoDict[CroppedAreaImageWidthPixels] floatValue];
    CGFloat gImageHeight = _isImage ? [_panoDict[GP(CroppedAreaImageHeightPixels)] floatValue] : [_panoDict[CroppedAreaImageHeightPixels] floatValue];
    CGFloat gLeft = _isImage ? [_panoDict[GP(CroppedAreaLeftPixels)] floatValue] : [_panoDict[CroppedAreaLeftPixels] floatValue];
    CGFloat gTop = _isImage ? [_panoDict[GP(CroppedAreaTopPixels)] floatValue] : [_panoDict[CroppedAreaTopPixels] floatValue];
    
    BOOL error = NO;
    
    if (gImageWidth != _image.size.width) {
        _errorLabel.text = @"CroppedAreaImageWidthPixels != image.size.width";
        error = YES;
    }
    if (gImageHeight != _image.size.height) {
        _errorLabel.text = @"CroppedAreaImageHeightPixels != image.size.height";
        error = YES;
    }
    if (gPanoWidth != gImageWidth + gLeft * 2) {
        _errorLabel.text = @"FullPanoWidthPixels != image.size.width + CroppedAreaLeftPixels * 2";
        error = YES;
    }
    if (gPanoHeight != gImageHeight + gTop * 2) {
        _errorLabel.text = @"FullPanoHeightPixels != image.size.height + CroppedAreaImageHeightPixels * 2";
        error = YES;
    }
    if (_isImage && (gPanoWidth != gPanoHeight * 2)) {
        _errorLabel.text = @"IMAGE: FullPanoWidthPixels != FullPanoHeightPixels * 2";
        error = YES;
    }
    if ( (_isImage && !_panoDict[GP(ProjectionType)]) || (!_isImage && !_panoDict[ProjectionType]) )
    {
        _errorLabel.text = @"ProjectionType does not defined !";
        error = YES;
    }
    
    if (error)
    {
        _errorLabel.hidden = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:@"error"];
        return;
    }
    
    CGFloat newImageWidth = gImageWidth * imageViewSize.width / gPanoWidth;
    CGFloat newImageHeight = gImageHeight * imageViewSize.height / gPanoHeight;
    
    UIImage *resized = [self resize:CGSizeMake(newImageWidth, newImageHeight) image:_image];
    
    _imageView.contentMode = UIViewContentModeCenter;
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
