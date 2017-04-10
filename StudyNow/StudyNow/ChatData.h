//
//  ChatData.h
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/22/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatData : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSString *recipientId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSNumber *msgRead;
@property (nonatomic, strong) NSDate *readTimestamp;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *thumbnailUrl;

- (BOOL) isMessageRead;
- (void) markMessageRead;
- (BOOL) isTextMessage;

@end
