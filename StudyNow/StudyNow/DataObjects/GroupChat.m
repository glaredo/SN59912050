//
//  GroupChat.m
//  StudyNow
//
//  Created by Rajesh Mehta on 10/5/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "GroupChat.h"
#import "Backendless.h"
#import "GeneralHelper.h"
#import "MyAppConstants.h"
#import "BackendHelper.h"

@implementation GroupChat

- (NSString *) getProfileImgLinkFor:(NSString *)userId {
    for(BackendlessUser* user in _participants){
        if([user.objectId isEqualToString:userId]){
            return [GeneralHelper checkForNull:[user getProperty:PROPERTY_PICTURE]];
        }
    }
    
    return nil;
}

- (BOOL) isOwnerOfGroup {
    NSString* currentId = [BackendHelper getCurrentUserObjectId];
    if([currentId isEqualToString:self.groupBy])
        return true;
    
    return false;
}

- (BOOL) isPartOfGroup {
    NSString* currentId = [BackendHelper getCurrentUserObjectId];
    for(BackendlessUser* user in _participants){
        if([user.objectId isEqualToString:currentId]){
            return true;
        }
    }
    return false;
}

@end
