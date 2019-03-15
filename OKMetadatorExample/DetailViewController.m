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

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *metaView;
@property (weak, nonatomic) IBOutlet UITextView *propView;
@property(nonatomic) NSURL *URL;
@property(nonatomic) UIImage *image;
@property(nonatomic) OKMetaParam *meta;
@property(nonatomic) NSDictionary *params;
@property(nonatomic) OKImageSphericalMetadator *imageMetadator;
@property(nonatomic) OKVideoSphericalMetadator *videoMetadator;
@end

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
    
    _meta = [_imageMetadator metaParamsFromImageAtURL:_URL];
    _params = [_imageMetadator propertiesFromImageAtURL:_URL];
    
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
    _params = [_videoMetadator videoPropertiesFromVideoAtURL:_URL];
    
    self.title = [_URL lastPathComponent];
    
    [self setup];
}

- (void)setup
{
    _imageView.image = _image;
    
    [_metaView setText:[_meta description]];
    [_propView setText:[_params description]];
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

@end
