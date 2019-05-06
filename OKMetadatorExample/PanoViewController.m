//
//  PanoViewController.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 5/6/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "PanoViewController.h"

@interface PanoViewController ()
@property(nonatomic) UIImage *image;
@property(nonatomic) NSDictionary *panoDict;
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

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
