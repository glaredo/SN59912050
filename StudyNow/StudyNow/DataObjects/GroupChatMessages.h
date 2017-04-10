//
//  GroupChatMessages.h
//  StudyNow
//
//  Created by Rajesh Mehta on 10/7/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupChatMessages : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSString *recipientId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSNumber *msgRead;
@property (nonatomic, strong) NSDate *readTimestamp;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *thumbnailUrl;

- (BOOL) isMessageRead;
- (void) markMessageRead;
- (BOOL) isTextMessage;

@end
