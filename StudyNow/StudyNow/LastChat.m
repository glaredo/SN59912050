//
//  LastChat.m
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import "LastChat.h"

@implementation LastChat

- (NSString *) getFriendsName {
    UserData* user = [self getFriendObject];
    return user.name;
}

- (NSString *) getFriendsId {
    UserData* user = [self getFriendObject];
    return user.objectId;
}

- (UserData *) getFriendObject {
    BackendlessUser* user = backendless.userService.currentUser;
    if([user.objectId isEqualToString:self.user1Id])
        return [UserData createWithBackendData:self.user2];
    else
        return [UserData createWithBackendData:self.user1];
}

- (NSString *) getMessageTime {
    NSString* timeSince = @"";
    if(self.timestamp == nil){
    } else {
        NSInteger activeSince = [[NSDate date] timeIntervalSinceDate:self.timestamp];
        if(activeSince < 60){
            timeSince = @"now";
        } else {
            NSInteger minutes = activeSince / 60;
            if(minutes < 60) {
                if(minutes == 1)
                    timeSince = @"1 min ago";
                else
                    timeSince = [NSString stringWithFormat:@"%d min ago", (int)minutes];
            } else {
                NSInteger hours = minutes / 60;
                if(hours == 1){
                    timeSince = @"1 hour ago";
                } else if (hours <= 24) {
                    timeSince = [NSString stringWithFormat:@"%d hours ago", (int)hours];
                } else {
                    NSInteger days = hours / 24;
                    if(days == 1) {
                        timeSince = @"1 day ago";
                    } else {
                        timeSince = [NSString stringWithFormat:@"%d days ago", (int)days];
                    }
                }
            }
        }
    }
    return timeSince;
}

@end
