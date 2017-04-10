//
//  LastChat.h
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Backendless.h"
#import "UserData.h"
#import "ChatData.h"

@interface LastChat : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *user1Id;
@property (nonatomic, strong) BackendlessUser *user1;
@property (nonatomic, strong) NSNumber *deletedUser1;
@property (nonatomic, strong) NSString *user2Id;
@property (nonatomic, strong) BackendlessUser *user2;
@property (nonatomic, strong) NSNumber *deletedUser2;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) ChatData *lastchat;

- (NSString *) getFriendsName;
- (UserData *) getFriendObject;
- (NSString *) getMessageTime;

@end
