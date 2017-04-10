//
//  GroupChatMessages.m
//  StudyNow
//
//  Created by Rajesh Mehta on 10/7/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "GroupChatMessages.h"
#import "GeneralHelper.h"
#import "MyAppConstants.h"

@implementation GroupChatMessages

- (BOOL) isMessageRead {
    if([GeneralHelper checkForNull:self.msgRead]){
        if([self.msgRead boolValue])
            return true;
    }
    
    return false;
}

- (void) markMessageRead {
    self.msgRead = [NSNumber numberWithBool:true];
    self.readTimestamp = [NSDate date];
}

- (BOOL) isTextMessage{
    NSString* msgType = [GeneralHelper checkForNullWithString:self.messageType];
    if([msgType isEqualToString:MESSAGE_TYPE_IMAGE])
        return false;
    
    return true;
}

@end
