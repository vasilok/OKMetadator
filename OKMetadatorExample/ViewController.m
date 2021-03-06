//
//  ViewController.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 2/28/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "Librarian.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic) IBOutlet UIButton *galleryBtn;
@property(nonatomic) IBOutlet UIButton *cameraBtn;
@property(nonatomic) Librarian *librarian;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _librarian = [Librarian new];
}

- (IBAction)galleryAction:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)cameraAction:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = PHAssetSourceTypeUserLibrary;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{ }];
    
    NSLog(@"INFO: %@ ", info);
    
    PHAsset *phAsset = [info objectForKey:UIImagePickerControllerPHAsset];
    
    if (phAsset) // library
    {
        NSString *ext = [[info objectForKey:UIImagePickerControllerMediaURL] pathExtension];
        
        if (phAsset.mediaType == PHAssetMediaTypeImage)
        {
            NSURL *imageURL = [info objectForKey:UIImagePickerControllerImageURL];
            NSURL *tempURL = imageURL ? [Librarian tempURLWithLastPath:imageURL.lastPathComponent] : [Librarian tempImageURLWithExtension:ext];
            [[NSFileManager defaultManager] removeItemAtURL:tempURL error:NULL];
            
            [_librarian fetchImage:phAsset toURL:tempURL withCompletion:^(BOOL success) {
                if (success)
                {
                    DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
                    [detailVC setLibrarian:self.librarian];
                    [detailVC setupWithImageURL:tempURL];
                    [self.navigationController pushViewController:detailVC animated:YES];
                }
            }];
        }
        else if (phAsset.mediaType == PHAssetMediaTypeVideo)
        {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            NSURL *tempURL = videoURL ? [Librarian tempURLWithLastPath:videoURL.lastPathComponent] : [Librarian tempVideoURLWithExtension:ext];
            [[NSFileManager defaultManager] removeItemAtURL:tempURL error:NULL];
            
            [_librarian fetchVideo:phAsset toURL:tempURL withCompletion:^(BOOL success) {
                if (success)
                {
                    DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
                    [detailVC setLibrarian:self.librarian];
                    [detailVC setupWithVideoURL:tempURL];
                    [self.navigationController pushViewController:detailVC animated:YES];
                }
            }];
        }
    }
    else
    {
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        
        if (type == (NSString *)kUTTypeImage)
        {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            NSString *ext = [[info objectForKey:UIImagePickerControllerMediaURL] pathExtension];

            if (image)
            {
                NSDictionary *meta = info[UIImagePickerControllerMediaMetadata];
                NSLog(@"Picker Input Meta: %@", meta);
                NSLog(@"Picker Image Orientation - %ld", image.imageOrientation);

                NSError *error;
                NSURL *tempURL = [Librarian tempImageURLWithExtension:ext];
                if ([UIImageJPEGRepresentation(image, 1) writeToURL:tempURL atomically:YES] == NO)
                {
                    NSLog(@"Errro: %@", error);
                    return;
                }

                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
                                   [detailVC setLibrarian:self.librarian];
                                   [detailVC setupWithImageURL:tempURL];
                                   [self.navigationController pushViewController:detailVC animated:YES];
                               });
            }
        }
        else if (type == (NSString *)kUTTypeMovie)
        {
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            
            DetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
            [detailVC setLibrarian:self.librarian];
            [detailVC setupWithVideoURL:url];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
