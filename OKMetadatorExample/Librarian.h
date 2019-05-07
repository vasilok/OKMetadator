//
//  Librarian.h
//  OKMetadatorExample
//
//  Created by Vasil_OK on 3/1/19.
//  Copyright © 2019 Vasil_OK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^LibrarianCompletion)(BOOL);

@interface Librarian : NSObject

- (void)saveImageToLibrary:(NSURL *)imageURL withCompletion:(LibrarianCompletion)completion;
- (void)saveVideoToLibrary:(NSURL *)videoURL withCompletion:(LibrarianCompletion)completion;

- (void)fetchImage:(PHAsset *)asset toURL:(NSURL *)url withCompletion:(LibrarianCompletion)completion;
- (void)fetchVideo:(PHAsset *)asset toURL:(NSURL *)url withCompletion:(LibrarianCompletion)completion;

// HELPER
+ (NSURL *)tempImageURLWithExtension:(NSString *)ext;
+ (NSURL *)tempVideoURLWithExtension:(NSString *)ext;
+ (NSURL *)tempURLWithLastPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
