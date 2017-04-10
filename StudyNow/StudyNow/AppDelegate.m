//
//  AppDelegate.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "AppDelegate.h"
#import "MyAppConstants.h"
#import "BackendHelper.h"
#import "GeneralHelper.h"
#import "GroupChatMessages.h"

static AppDelegate *sharedDelegate;

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate {
    if (!sharedDelegate) {
        sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return sharedDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:49.0f/255.0f green:142.0f/255.0f blue:222.0f/255.0f alpha:1]];

    [BackendHelper initializeService];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"UserDidLoginNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self initSinchClientWithUserId:note.userInfo[@"userId"]];
                                                  }];

    // Override point for customization after application launch.
    
    self.push = [Sinch managedPushWithAPSEnvironment:SINAPSEnvironmentAutomatic];
    self.push.delegate = self;
    [self.push setDesiredPushTypeAutomatically];
    [self.push registerUserNotificationSettings];
    
//    self.locationTracker = [[MyLocationTracker alloc]init];
//    [self.locationTracker startLocationTracking];

    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [BackendHelper didEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (!_sinchClient) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        if (userId) {
            [self initSinchClientWithUserId:userId];
        }
    }

    [BackendHelper updateActiveTime];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BackendHelper appDidBecomeActiveService];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [BackendHelper updateActiveTime];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [BackendHelper didEnterBackground];
    [self saveContext];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    /*    @try {
     NSString *tokenStr = [backendless.messagingService deviceTokenAsString:deviceToken];
     NSString *registrationId = [backendless.messagingService registerDeviceToken:tokenStr];
     }
     @catch (Fault *fault) {
     NSLog(@"FAULT = %@ <%@>", fault.message, fault.detail);
     } */
    [backendless.messaging registerDeviceToken:deviceToken];
    [BackendHelper updateDeviceId:^(BOOL success, NSError *error) {
        
    }];
    [self.push application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // handle error
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    [self handleNotification:userInfo];
    [backendless.messaging didReceiveRemoteNotification:userInfo];
    [self.push application:application didReceiveRemoteNotification:userInfo];
}

- (void) handleNotification:(NSDictionary *)userInfo {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceivedChatNotification object:nil];
}

- (void)initSinchClientWithUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!_sinchClient) {
        _sinchClient = [Sinch clientWithApplicationKey:@"792cc75f-80a9-4781-8003-a4b993415270"
                                applicationSecret:@"JNLqfpLYxEOjf9TNxxWvtw=="
                                  environmentHost:@"sandbox.sinch.com"
                                           userId:userId];
        
        _sinchClient.delegate = self;
        
        [_sinchClient setSupportMessaging:YES];
        [_sinchClient enableManagedPushNotifications];
        
        [_sinchClient start];
        [_sinchClient startListeningOnActiveConnection];
        
        
    }
}

- (void)sendImageMessage:(NSString *)messageText toRecipient:(NSString *)recipientId objectId:(NSString *)objectID {
    NSString* name = [BackendHelper getCurrentUserName];
    NSString* msg = [NSString stringWithFormat:@"%@: Sent an image.",name];
    [self.push setDisplayName:msg];
    SINOutgoingMessage *outgoingMessage = [SINOutgoingMessage messageWithRecipient:recipientId text:messageText];
    [outgoingMessage addHeaderWithValue:MESSAGE_TYPE_IMAGE key:MESSAGE_TYPE];
    [outgoingMessage addHeaderWithValue:objectID key:MESSAGE_OBJECTID];
    [self.sinchClient.messageClient sendMessage:outgoingMessage];
}

// Send a text message
- (void)sendTextMessage:(NSString *)messageText toRecipient:(NSString *)recipientId objectId:(NSString *)objectID {
    NSString* name = [BackendHelper getCurrentUserName];
    NSString* msg = [NSString stringWithFormat:@"%@: %@",name, messageText];
    if([msg length] > 200){
        msg = [msg substringToIndex:199];
        msg = [NSString stringWithFormat:@"%@...",msg];
    }
    [self.push setDisplayName:msg];
    SINOutgoingMessage *outgoingMessage = [SINOutgoingMessage messageWithRecipient:recipientId text:messageText];
    [outgoingMessage addHeaderWithValue:MESSAGE_TYPE_TEXT key:MESSAGE_TYPE];
    [outgoingMessage addHeaderWithValue:objectID key:MESSAGE_OBJECTID];
    [self.sinchClient.messageClient sendMessage:outgoingMessage];
}

- (void)sendGroupImageMessage:(NSString *)groupId messageText:(NSString *)messageText toRecipient:(NSMutableArray *)recipientList objectId:(NSString *)objectID {
    NSString* name = [BackendHelper getCurrentUserName];
    NSString* msg = [NSString stringWithFormat:@"%@: Sent an image.",name];
    [self.push setDisplayName:msg];
    SINOutgoingMessage *outgoingMessage = [SINOutgoingMessage messageWithRecipients:recipientList text:messageText];
    [outgoingMessage addHeaderWithValue:MESSAGE_TYPE_IMAGE key:MESSAGE_TYPE];
    [outgoingMessage addHeaderWithValue:groupId key:@"GroupId"];
    [outgoingMessage addHeaderWithValue:objectID key:MESSAGE_OBJECTID];
    [self.sinchClient.messageClient  sendMessage:outgoingMessage];
}

- (void)sendGroupTextMessage:(NSString *)groupId messageText:(NSString *)messageText toRecipient:(NSMutableArray *)recipientList  objectId:(NSString *)objectID {
    
    NSString* name = [BackendHelper getCurrentUserName];
    NSString* msg = [NSString stringWithFormat:@"%@: %@",name, messageText];
    if([msg length] > 200){
        msg = [msg substringToIndex:199];
        msg = [NSString stringWithFormat:@"%@...",msg];
    }
    [self.push setDisplayName:msg];
    SINOutgoingMessage *outgoingMessage = [SINOutgoingMessage messageWithRecipients:recipientList text:messageText];
    [outgoingMessage addHeaderWithValue:MESSAGE_TYPE_TEXT key:MESSAGE_TYPE];
    [outgoingMessage addHeaderWithValue:groupId key:@"GroupId"];
    [outgoingMessage addHeaderWithValue:objectID key:MESSAGE_OBJECTID];
    [self.sinchClient.messageClient  sendMessage:outgoingMessage];
}


#pragma mark - SINManagedPushDelegate
- (void)managedPush:(id<SINManagedPush>)unused
didReceiveIncomingPushWithPayload:(NSDictionary *)payload
            forType:(NSString *)pushType {
    [self handleRemoteNotification:payload];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    if (!_sinchClient) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        if (userId) {
            [self initSinchClientWithUserId:userId];
        }
    }
    [self.sinchClient relayRemotePushNotification:userInfo];
}



#pragma mark - SINClientDelegate

- (void)clientDidStart:(id<SINClient>)client {
    NSLog(@"Sinch client started successfully (version: %@)", [Sinch version]);

    self.sinchMessageClient = [self.sinchClient messageClient];
    self.sinchMessageClient.delegate =  self;
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
    NSLog(@"Sinch client error: %@", [error localizedDescription]);
}

- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp {
    if (severity == SINLogSeverityCritical) {
        NSLog(@"%@", message);
    }
}

#pragma mark SINMessageClientDelegate methods
- (ChatData *) convertToChatData:(id<SINMessage>)message {
    ChatData *messageObject = [[ChatData alloc] init];
    messageObject.messageId = [message messageId];
    messageObject.senderId = [message senderId];
    messageObject.recipientId = [message recipientIds][0];
    messageObject.text = [message text];
    messageObject.timestamp = [message timestamp];
    messageObject.messageType = [GeneralHelper checkForNull:[[message headers] valueForKey:MESSAGE_TYPE]];
    messageObject.objectId =  [GeneralHelper checkForNull:[[message headers] valueForKey:MESSAGE_OBJECTID]];

    return messageObject;
}

- (GroupChatMessages *) convertToGroupChatData:(id<SINMessage>)message {
    GroupChatMessages *messageObject = [[GroupChatMessages alloc] init];
    messageObject.messageId = [message messageId];
    messageObject.senderId = [message senderId];
    messageObject.recipientId = [message recipientIds][0];
    messageObject.text = [message text];
    messageObject.timestamp = [message timestamp];
    messageObject.groupId = [GeneralHelper checkForNull:[[message headers] valueForKey:@"GroupId"]];
    messageObject.messageType = [GeneralHelper checkForNull:[[message headers] valueForKey:MESSAGE_TYPE]];
    messageObject.objectId =  [GeneralHelper checkForNull:[[message headers] valueForKey:MESSAGE_OBJECTID]];

    return messageObject;
}

// Receiving an incoming message.
- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    NSString* groupID = [GeneralHelper checkForNull:[[message headers] valueForKey:@"GroupId"]];
    if(groupID == nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_RECIEVED object:self userInfo:@{@"message" : [self convertToChatData:message]}];
    } else {
//        NSLog(@"Got group message");
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_GROUP_MESSAGE_RECIEVED object:self userInfo:@{@"message" : [self convertToGroupChatData:message], @"groupId" : groupID}];
//        });
    }
}

// Finish sending a message
- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    NSString* groupID = [GeneralHelper checkForNull:[[message headers] valueForKey:@"GroupId"]];
    if(groupID == nil){
        // Save it before
//        [BackendHelper saveMessagesOnParse:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_SENT object:self userInfo:@{@"message" : [self convertToChatData:message]}];
    } else {
//        [BackendHelper saveGroupMessagesOnParse:message groupId:groupID completionBlock:^(BOOL success, NSError *error) {
            
//        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_GROUP_MESSAGE_SENT object:self userInfo:@{@"message" : [self convertToGroupChatData:message], @"groupId" : groupID}];
        NSLog(@"Got group message");
    }
}

// Failed to send a message
- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)messageFailureInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_FAILED object:self userInfo:@{@"message" : message}];
    NSLog(@"MessageBoard: message to %@ failed. Description: %@. Reason: %@.", messageFailureInfo.recipientId, messageFailureInfo.error.localizedDescription, messageFailureInfo.error.localizedFailureReason);
}

-(void)messageDelivered:(id<SINMessageDeliveryInfo>)info
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SINCH_MESSAGE_DELIVERED object:info];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.StudyNow" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StudyNow" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"StudyNow.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark MBProgressHUDDelegate methods

- (void) showFetchAlert {
    if(self.HUD != nil)
        return;
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:self.HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    self.HUD.delegate = self;
    
    [self.HUD show:YES];
    
}

- (void)myTask {
    // Do something usefull in here instead of sleeping ...
}


- (void)hudWasHidden:(MBProgressHUD *)hud {
    NSLog(@"hudWasHidden");
    // Remove HUD from screen when the HUD was hidded
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

- (void) dissmissFetchAlert {
    NSLog(@"dissmissFetchAlert");
    [self.HUD hide:YES];
    /*    if (self.loadingAlert.isVisible) {
     [self.loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
     } */
}

@end
