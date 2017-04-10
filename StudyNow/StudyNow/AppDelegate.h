//
//  AppDelegate.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Sinch/Sinch.h>
#import <CoreData/CoreData.h>
#import "MBProgressHUD.h"
#import "MyLocationTracker.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate, SINClientDelegate, SINMessageClientDelegate, SINManagedPushDelegate>

+ (AppDelegate *)sharedDelegate;

@property (strong, nonatomic) id<SINClient> sinchClient;
@property (strong, nonatomic) id<SINMessageClient> sinchMessageClient;
@property (nonatomic, readwrite, strong) id<SINManagedPush> push;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) MyLocationTracker * locationTracker;
@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic, retain) NSString *geoObjectId;

@property (nonatomic, strong) MBProgressHUD *HUD;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) showFetchAlert;
- (void) dissmissFetchAlert;

- (void)sendTextMessage:(NSString *)messageText toRecipient:(NSString *)recipientID objectId:(NSString *)objectID;
- (void)sendImageMessage:(NSString *)messageText toRecipient:(NSString *)recipientID objectId:(NSString *)objectID;
- (void)sendGroupTextMessage:(NSString *)groupId messageText:(NSString *)messageText toRecipient:(NSMutableArray *)recipientList  objectId:(NSString *)objectID;
- (void)sendGroupImageMessage:(NSString *)groupId messageText:(NSString *)messageText toRecipient:(NSMutableArray *)recipientList objectId:(NSString *)objectID;

@end

