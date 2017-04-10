//
//  ImageCacheHelper.h
//  Alike
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCacheHelper : NSObject

-(id) init;
+ (ImageCacheHelper *) sharedObject;

- (UIImage *) getCachedImage:(NSString *)objectID;
- (void) cacheTheImage:(NSString *)objectID image:(NSData *)imageData;

@end
