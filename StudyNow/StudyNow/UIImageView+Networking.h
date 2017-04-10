//
//  UIImageView+Networking.h
//  Alike
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// UIImageView Extentions resposipble for downloading the image from remote server.

typedef void (^DownloadCompletionBlock) (BOOL succes, UIImage *image, NSError *error);

@interface UIImageView (Networking)
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *URLId;

- (void)setImageURL:(NSURL *)imageURL withCompletionBlock:(DownloadCompletionBlock)block;
@end
