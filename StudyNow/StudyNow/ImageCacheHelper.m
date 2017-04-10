//
//  ImageCacheHelper.m
//  Alike
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#import "ImageCacheHelper.h"

#define kAttributesImageCacheDateKey           @"cachedt"
#define kAttributesImageKey           @"image"

@interface ImageCacheHelper()

@property (nonatomic, strong) NSCache *cache;
@end

@implementation ImageCacheHelper

-(id) init
{
    if((self = [super init]))
    {
        self.cache = [[NSCache alloc] init];
    }
    
    return self;
}

+ (ImageCacheHelper *)sharedObject
{
    static ImageCacheHelper *objUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objUtility = [[ImageCacheHelper alloc] init];
    });
    return objUtility;
}

- (NSDictionary *)attributesForObjectId:(NSString *)key {
    NSDictionary *dict = [self.cache objectForKey:key];

    return dict;
}

- (void)setAttributes:(NSDictionary *)attributes forObjectId:(NSString *)key {
    [self.cache setObject:attributes forKey:key];
}

- (UIImage *) getCachedImage:(NSString *)objectID {
    NSDictionary* attributes = [self attributesForObjectId:objectID];
    if(!attributes)
        return nil;
    
    NSString* localPath = [attributes objectForKey:kAttributesImageKey];
    if(localPath){
        NSLog(@"From Cache");
        return [UIImage imageWithContentsOfFile:localPath];
    }
    
    return nil;
}

- (void) cacheTheImage:(NSString *)objectID image:(NSData *)imageData {
    NSDictionary* attributes = [self attributesForObjectId:objectID];
    NSMutableDictionary *attributesDict;

    if(!attributes) {
        attributesDict =  [[NSMutableDictionary alloc] init];
    } else {
        attributesDict = [NSMutableDictionary dictionaryWithDictionary:attributes];
    }

    NSString* oldlocalPath = [attributesDict objectForKey:kAttributesImageKey];
    if(oldlocalPath){
        [self removeImage:oldlocalPath];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@.jpeg", objectID];
    NSString* localPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    [imageData writeToFile:localPath atomically:YES];
    [attributesDict setObject:localPath forKey:kAttributesImageKey];
    [attributesDict setObject:[NSDate date] forKey:kAttributesImageCacheDateKey];
    
    [self setAttributes:attributesDict forObjectId:objectID];
}



- (void)removeImage:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
//        UIAlertView *removedSuccessFullyAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removedSuccessFullyAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
@end
