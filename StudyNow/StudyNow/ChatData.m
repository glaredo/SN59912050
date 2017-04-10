//
//  ChatData.m
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/22/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import "ChatData.h"
#import "GeneralHelper.h"
#import "MyAppConstants.h"

@implementation ChatData

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
