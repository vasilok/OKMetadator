//
//  Librarian.m
//  OKMetadatorExample
//
//  Created by Vasil_OK on 3/1/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import "Librarian.h"

@implementation Librarian

- (void)dealloc
{
    [self clearTempFolder];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self clearTempFolder];
        [self fetchWorkerCollection];
    }
    
    return self;
}

- (void)saveImageToLibrary:(NSURL *)imageURL withCompletion:(LibrarianCompletion)completion
{
    PHPhotoLibrary *pLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    PHAssetCollection *workerCollection = [self fetchWorkerCollection];
    __block NSString *assetID;
    
    [pLibrary performChanges:^
     {
         PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:imageURL];
         assetID = request.placeholderForCreatedAsset.localIdentifier;
         PHAssetCollectionChangeRequest *addRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:workerCollection];
         [addRequest addAssets:@[ request.placeholderForCreatedAsset ]];
     }
           completionHandler:^(BOOL success, NSError * _Nullable error)
     {
         NSLog(@"Save to library - %d with error - %@", success, error);
         
         dispatch_async(dispatch_get_main_queue(), ^{
             completion(success);
         });
     }];
}

- (void)saveVideoToLibrary:(NSURL *)videoURL withCompletion:(LibrarianCompletion)completion
{
    PHPhotoLibrary *pLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    PHAssetCollection *workerCollection = [self fetchWorkerCollection];
    
    __block NSString *assetID;
    
    [pLibrary performChanges:^
     {
         PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
         assetID = request.placeholderForCreatedAsset.localIdentifier;
         
         NSLog(@"Library create - %@, asset ID - %@", videoURL , assetID);
         
         PHAssetCollectionChangeRequest *addRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:workerCollection];
         [addRequest addAssets:@[ request.placeholderForCreatedAsset ]];
     }
           completionHandler:^(BOOL success, NSError * _Nullable error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    completion(success);
                                });
                 
                 if (success == NO)
                 {
                     NSLog(@"Error save to library - %@", error);
                 }
             }];
}

- (void)fetchImage:(PHAsset *)phAsset toURL:(NSURL *)url withCompletion:(LibrarianCompletion)completion
{
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    [[PHImageManager defaultManager] requestImageDataForAsset:phAsset
                                                      options:imageRequestOptions
                                                resultHandler:^(NSData *imageData, NSString *dataUTI,
                                                                UIImageOrientation orientation,
                                                                NSDictionary *info)
     {
         NSLog(@"info = %@", info);
         NSURL *imageURL = info[@"PHImageFileURLKey"];
         
         NSError *error;
         BOOL success = [[NSFileManager defaultManager] copyItemAtURL:imageURL toURL:url error:&error];
         NSLog(@"Fetch from library - %d with error - %@", success, error);
         
         dispatch_async(dispatch_get_main_queue(), ^{
             completion(success);
         });
         
     }];
}

- (void)fetchVideo:(PHAsset *)asset toURL:(NSURL *)url withCompletion:(LibrarianCompletion)completion
{
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            NSURL *assetUrl = [(AVURLAsset *)asset URL];
            NSLog(@"Asset URL %@",assetUrl);
            NSData *videoData = [NSData dataWithContentsOfURL:assetUrl];
            
            BOOL writeResult = [videoData writeToURL:url atomically:true];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(writeResult);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
}

+ (NSURL *)tempImageURL
{
    NSString *tempName = [NSString stringWithFormat:@"TI%ld", (long)CFAbsoluteTimeGetCurrent()];
    return [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"jpg"]] filePathURL];
}

+ (NSURL *)tempVideoURL
{
    NSString *tempName = [NSString stringWithFormat:@"TV%ld", (long)CFAbsoluteTimeGetCurrent()];
    return [[NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:tempName] stringByAppendingPathExtension:@"mp4"]] filePathURL];
}

- (void)clearTempFolder
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

- (void)requestAutorization
{
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            NSLog(@"PH Library status - %ld", status);
        }];
    }
    else
    {
        NSLog(@"PH Library status authorized");
    }
}


- (PHFetchResult *)fetchWorkerAlbum
{
    PHFetchOptions *opt = [PHFetchOptions new];
    opt.predicate = [NSPredicate predicateWithFormat:@"title = %@", [self workAlbumName]];
    
    return [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:opt];
}

- (PHAssetCollection *)fetchWorkerCollection
{
    PHFetchResult<PHAssetCollection *> *result = [self fetchWorkerAlbum];
    
    PHAssetCollection *workerCollection = [result firstObject];
    
    if (workerCollection == nil)
    {
        [self createWorkerAlbum];
    }
    
    return workerCollection;
}

- (void)createWorkerAlbum
{
    PHPhotoLibrary *pLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    NSError *error;
    [pLibrary performChangesAndWait:^
     {
         [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:[self workAlbumName]];
     }
                              error:&error];
}

- (NSString *)workAlbumName
{
    return @"VSMetadator";
}

@end
