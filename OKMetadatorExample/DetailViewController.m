//
//  DetailViewController.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 2/28/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "DetailViewController.h"
#import "OKImageSphericalMetadator.h"
#import "OKVideoSphericalMetadator.h"
#import <AVFoundation/AVFoundation.h>
#import "ImageViewController.h"
#import "OKImageGVRMetadator.h"
#import "PanoViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *panoBtn;
@property (weak, nonatomic) IBOutlet UITextView *metaView;
@property (weak, nonatomic) IBOutlet UITextView *propView;
@property (weak, nonatomic) IBOutlet UITextField *hFOVField;
@property (weak, nonatomic) IBOutlet UITextField *vFOVField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMetasConstraint;
@property (weak, nonatomic) IBOutlet UIButton *propBtn;
@property (weak, nonatomic) IBOutlet UIButton *metaBtn;
@property (weak, nonatomic) IBOutlet UIButton *exBtn;
@property (weak, nonatomic) IBOutlet UIView *exView;
@property (weak, nonatomic) IBOutlet UIImageView *exImageView;
@property (weak, nonatomic) IBOutlet UILabel *exKeyLabel;
@property (weak, nonatomic) IBOutlet UIButton *exportBtn;
@property(nonatomic) NSURL *URL;
@property(nonatomic) UIImage *image;

@property(nonatomic) UIImage *exImage;
@property(nonatomic) NSString *exKey;

@property(nonatomic) OKMetaParam *meta;
@property(nonatomic) NSDictionary *params;
@property(nonatomic) OKImageSphericalMetadator *imageMetadator;
@property(nonatomic) OKVideoSphericalMetadator *videoMetadator;

@end

#define CLOSED 60
#define OPEN 100
#define HIDE 20
#define ONLY_READER NO

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setup];
}

- (void)setupWithImageURL:(NSURL * _Nonnull)imageURL
{
    _URL = imageURL;
    
    NSData *imageData = [NSData dataWithContentsOfURL:_URL options:0 error:NULL];
    _image = [UIImage imageWithData:imageData];
    
    _videoMetadator = nil;
    _imageMetadator = [OKImageSphericalMetadator new];
    
    _meta = [_imageMetadator fullMetaParamsFromImageAtURL:_URL];
    _params = [_imageMetadator propertiesFromImageAtURL:_URL];
    
    _exImage = [_imageMetadator disparityImageFromImageAtURL:_URL];
    if (_exImage) {
        _exKey = CFS(kCGImageAuxiliaryDataTypeDisparity);
    }
    else {
        _exImage = [_imageMetadator depthImageFromImageAtURL:_URL];
        if (_exImage) {
            _exKey = PP(GDepth,Data);
        }
        else {
            _exImage = [_imageMetadator dataImageFromImageAtURL:_URL];
            if (_exImage) {
                _exKey = PP(GImage,Data);
            }
        }
    }
    
    CGImageMetadataRef metadata = [_imageMetadator metaFromImageAtURL:_URL];
    //NSLog(@"Metadata : \n %@", metadata);
    if (metadata) CFRelease(metadata);
    
    self.title = [_URL lastPathComponent];
    
    [self setup];
}

- (void)setupWithVideoURL:(NSURL * _Nonnull)videoURL
{
    _URL = videoURL;
    
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = CMTimeMake(1, 10000);
    
    NSError *error;
    CGImageRef imRef = [gen copyCGImageAtTime:time actualTime:nil error:&error];
    _image = [UIImage imageWithCGImage:imRef];
    
    _imageMetadator = nil;
    _videoMetadator = [OKVideoSphericalMetadator new];
    
    _meta = [_videoMetadator metaParamsFromVideoAtURL:_URL];
    _params = @{ @"Video" : [_videoMetadator videoPropertiesFromVideoAtURL:_URL],
                 @"Audio" : [_videoMetadator audioPropertiesFromVideoAtURL:_URL] };
    
    self.title = [_URL lastPathComponent];
    
    [self setup];
}

- (void)setup
{
    _imageView.image = _image;
    
    _exBtn.hidden = _exImage == nil;
    _exView.hidden = _exImage == nil;
    _exImageView.image = _exImage;
    _exKeyLabel.text = _exKey;
    _exportBtn.hidden = _exImage == nil;
    [_exportBtn setBackgroundImage:nil forState:UIControlStateNormal];
    
    [_metaView setText:[[self printMetaDictionary] description]];
    [_propView setText:[_params description]];
    
    _topMetasConstraint.constant = ONLY_READER ? HIDE : CLOSED;
    
    OKMetadator *m = _imageMetadator ?  _imageMetadator : _videoMetadator;
    CGFloat fileSize = [[m filePropertiesFromURL:_URL][FileSize] floatValue];
    
    if (_imageMetadator) {
        _panoBtn.hidden = _meta[PanoNamespace] == nil;
    }
    else if (_videoMetadator) {
        _panoBtn.hidden = _meta[SphericalVideo] == nil;
    }
    
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%.2f Mb", fileSize] style:UIBarButtonItemStylePlain target:nil action:NULL]];
}

- (NSDictionary *)printMetaDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:_meta copyItems:YES];
    
    NSString *imageData = dict[GoogleNamespace] [PP(GImage,Data)];
    
    if (imageData) {
        imageData = [NSString stringWithFormat:@"<...> length=%ld", imageData.length];
        
        NSMutableDictionary *googleDict = [dict[GoogleNamespace] mutableCopy];
        googleDict[PP(GImage, Data)] = imageData;
        
        dict[GoogleNamespace] = googleDict;
    }
    
    NSString *depthData = dict[GDepthNamespace] [DP(Data)];
    
    if (depthData) {
        depthData = [NSString stringWithFormat:@"<...> length=%ld", depthData.length];
        
        NSMutableDictionary *googleDict = [dict[GDepthNamespace] mutableCopy];
        googleDict[DP(Data)] = depthData;
        
        dict[GDepthNamespace] = googleDict;
    }
    
    return [dict copy];
}

- (IBAction)make180:(id)sender
{
    if (_imageMetadator) {
        NSURL *tempURL = [Librarian tempImageURLWithExtension:[_URL pathExtension]];
        if ([_imageMetadator make180Image:_image withMeta:_meta outputURL:tempURL] )
        {
            [_librarian saveImageToLibrary:tempURL withCompletion:^(BOOL success) {
                if (success) {
                    [[self navigationController] popViewControllerAnimated:YES];
                }
            }];
        }
    }
    else if (_videoMetadator) {
        NSURL *tempURL = [Librarian tempVideoURLWithExtension:[_URL pathExtension]];
        [_videoMetadator make180VideoAtURL:_URL andWriteToURL:tempURL completion:^(BOOL success)
         {
             if (success) {
                 [self.librarian saveVideoToLibrary:tempURL withCompletion:^(BOOL success) {
                     if (success) {
                         [[self navigationController] popViewControllerAnimated:YES];
                     }
                 }];
             }
         }];
    }
}

- (IBAction)make360:(id)sender
{
    if (_imageMetadator) {
        NSURL *tempURL = [Librarian tempImageURLWithExtension:[_URL pathExtension]];
        if ([_imageMetadator make360Image:_image withMeta:_meta outputURL:tempURL] )
        {
            [_librarian saveImageToLibrary:tempURL withCompletion:^(BOOL success) {
                if (success) {
                    [[self navigationController] popViewControllerAnimated:YES];
                }
            }];
        }
    }
    else if (_videoMetadator) {
        NSURL *tempURL = [Librarian tempVideoURLWithExtension:[_URL pathExtension]];
        [_videoMetadator make360VideoAtURL:_URL andWriteToURL:tempURL completion:^(BOOL success)
         {
            if (success) {
                [self.librarian saveVideoToLibrary:tempURL withCompletion:^(BOOL success) {
                    if (success) {
                        [[self navigationController] popViewControllerAnimated:YES];
                    }
                }];
            }
         }];
    }
}

- (IBAction)FOV:(id)sender
{
    if (_topMetasConstraint.constant == OPEN)
    {
        _topMetasConstraint.constant = CLOSED;
    }
    else
    {
        _topMetasConstraint.constant = OPEN;
    }
    
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)makeFOV:(id)sender
{
    _topMetasConstraint.constant = CLOSED;
    [UIView animateWithDuration:.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    CGFloat hFov = [_hFOVField.text integerValue];
    CGFloat vFov = [_vFOVField.text integerValue];
    
    if (_imageMetadator) {
        NSURL *tempURL = [Librarian tempImageURLWithExtension:[_URL pathExtension]];
        [_imageMetadator makePanoImage:_image withHorizontalFOV:hFov verticalFOV:vFov meta:_meta outputURL:tempURL completion:^(BOOL success) {
            if (success) {
                [self.librarian saveImageToLibrary:tempURL withCompletion:^(BOOL libSuccess) {
                    if (libSuccess) {
                        [[self navigationController] popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
}

- (IBAction)clearPano:(id)sender
{
    if (_imageMetadator) {
        NSURL *tempURL = [Librarian tempImageURLWithExtension:[_URL pathExtension]];
        
        if ([_imageMetadator removePanoFromImageAt:_URL outputURL:tempURL]) {
            [_librarian saveImageToLibrary:tempURL withCompletion:^(BOOL success) {
                if (success) {
                    [[self navigationController] popViewControllerAnimated:YES];
                }
            }];
        }
    }
    else if (_videoMetadator) {
        NSURL *tempURL = [Librarian tempVideoURLWithExtension:[_URL pathExtension]];
        [_videoMetadator removeSphericalFromVideoAt:_URL outputURL:tempURL completion:^(BOOL success) {
            if (success) {
                [self.librarian saveVideoToLibrary:tempURL withCompletion:^(BOOL success) {
                    if (success) {
                        [[self navigationController] popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
}

- (IBAction)showImage:(UITapGestureRecognizer *)sender
{
    if (_imageMetadator) {
        ImageViewController *ivc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ImageViewController"];
        [ivc setupImage:((UIImageView *)(sender.view)).image];
        
        [self presentViewController:ivc animated:YES completion:NULL];
    }
}

- (IBAction)changeView:(UIButton *)sender
{
    if (sender == _propBtn) {
        [_propView.superview bringSubviewToFront:_propView];
    }
    else if (sender == _metaBtn) {
        [_metaView.superview bringSubviewToFront:_metaView];
    }
    else if (sender == _exBtn) {
        [_exView.superview bringSubviewToFront:_exView];
    }
}

- (IBAction)exportEx:(id)sender
{
    _librarian = [Librarian new];
    
    NSURL *tempURL = [Librarian tempImageURLWithExtension:@"jpg"];
    
    NSData *imageData = UIImageJPEGRepresentation(_exImage, 1.0);
    [imageData writeToURL:tempURL atomically:YES];
    
    [_librarian saveImageToLibrary:tempURL withCompletion:^(BOOL success)
     {
        
    }];
}

- (IBAction)showPano:(UIButton *)sender
{
    UIImage *panoImage = _image;
    NSDictionary *panoDict = _meta[PanoNamespace];
    if (_videoMetadator) {
        AVAsset *expAsset = [AVAsset assetWithURL:_URL];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:expAsset];
        CMTime time = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
        
        NSError *error;
        CGImageRef imRef = [gen copyCGImageAtTime:time actualTime:nil error:&error];
        
        panoImage = [UIImage imageWithCGImage:imRef];
        panoDict = _meta[SphericalVideo];
    }
    
    PanoViewController *panoVC = [[PanoViewController alloc] initWithImage:panoImage
                                                                 fromImage:(_imageMetadator != nil)
                                                                      pano:panoDict];
    [self presentViewController:panoVC animated:YES completion:NULL];
}

@end
