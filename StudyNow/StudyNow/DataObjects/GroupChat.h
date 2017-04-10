//
//  GroupChat.h
//  StudyNow
//
//  Created by Rajesh Mehta on 10/5/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyClasses.h"

@interface GroupChat : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *groupBy;
@property (nonatomic, strong) NSDate *chatTime;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) MyClasses *myClass;
@property (nonatomic, strong) NSNumber *groupSize;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSDate *lastChatTime;
@property (nonatomic, strong) NSString *lastChatBy;

@property (nonatomic, strong) NSMutableArray *participants;

- (NSString *) getProfileImgLinkFor:(NSString *)userId;
- (BOOL) isOwnerOfGroup;
- (BOOL) isPartOfGroup;

@end
