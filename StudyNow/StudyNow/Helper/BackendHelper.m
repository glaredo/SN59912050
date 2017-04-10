//
//  BackendHelper.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/18/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "BackendHelper.h"
#import "UIImage+Scale.h"
#import "Backendless.h"
#import "MyAppConstants.h"
#import "GeneralHelper.h"
#import "Schools.h"
#import "Student.h"
#import "Subject.h"
#import "StudentDetail.h"
#import "ChatData.h"
#import "MyClasses.h"
#import "DeviceUserMap.h"
#import "AppDelegate.h"
#import "GroupChat.h"
#import "GroupChatMessages.h"

@implementation BackendHelper

+(NSError *) convertFaultToError:(Fault *)fault {
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey: fault.message};
    NSError* error = [NSError errorWithDomain:@"com.alike.errordomain" code:[fault.faultCode intValue] userInfo:errorDictionary];
    return error;
}

+(void) initializeService {
    [DebLog setIsActive:YES];
    
    [backendless initApp:APP_ID secret:SECRET_ID version:VERSION_NUM];
    [backendless.userService setStayLoggedIn:YES];
    backendless.hostURL = @"http://api.backendless.com";

    [backendless.messaging registerForRemoteNotifications];
}

+(void) appDidBecomeActiveService {
    BackendlessUser* user = backendless.userService.currentUser;
    if(user == nil)
        return;
    
    NSString* userObjectId = user.objectId;
    id<IDataStore> dataStore = [backendless.persistenceService of:[BackendlessUser class]];
    BackendlessUser *newUser = [dataStore findID:userObjectId];
    [user updateProperties:[newUser retrieveProperties]];
}

+(void) didEnterBackground {
    [backendless saveCache];
}

+(UserData *) getCurrentUserNoImg {
    BackendlessUser* user = backendless.userService.currentUser;
    if(!user){
        return nil;
    } else {
        UserData* userdata = [[UserData alloc] init];
        [userdata initWithBackendData:user withImage:false];
        return userdata;
    }
}

+(UserData *) getCurrentUser {
    BackendlessUser* user = backendless.userService.currentUser;
    if(!user){
        return nil;
    } else {
        UserData* userdata = [[UserData alloc] init];
        [userdata initWithBackendData:user];
        return userdata;
    }
}

+(NSString *) getCurrentUserObjectId {
    BackendlessUser* user = backendless.userService.currentUser;
    if(!user){
        return nil;
    } else {
        return user.objectId;
    }
}

+(NSString *) getCurrentUserName {
    BackendlessUser* user = backendless.userService.currentUser;
    if(!user){
        return @"";
    } else {
        NSString* name = [user getProperty:PROPERTY_NAME];
        return name;
    }
}

+(BOOL) isMe:(NSString *)objId {
    BackendlessUser* user = backendless.userService.currentUser;
    if([user.objectId isEqualToString:objId])
        return true;
    
    return false;
}


+(void) doLogout {
    [AppDelegate sharedDelegate].sinchClient = nil;
    [backendless.userService logout];
}

+(void) performUserSignIn:(NSString *)username password:(NSString *)password completion:(ServiceResponse)completionBlock {
    [backendless.userService login:[username lowercaseString] password:password response:^(BackendlessUser *user) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLoginNotification"
                                                            object:nil
                                                          userInfo:@{
                                                                     @"userId" : user.objectId
                                                                     }];

        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+(void) createUser:(UserData *)userdata completion:(ServiceResponse)completionBlock {
    BackendlessUser *user = [BackendlessUser new];
    user.email = userdata.email;
    user.password = userdata.password;
    //    user.name = userdata.name;
    [user setProperty:PROPERTY_NAME object:userdata.name];
    [user setProperty:PROPERTY_SCHOOL_NAME object:userdata.schoolname];
    [user setProperty:PROPERTY_PERM_NUMBER object:userdata.permNumber];
    [user setProperty:PROPERTY_SCHOOL object:userdata.school ];
    [user setProperty:PROPERTY_STUDENT_DETAIL object:[[StudentDetail alloc] init]];
    [user setProperty:PROPERTY_NOTIFY object:[NSNumber numberWithBool:true]];
    if(userdata.profileImage){
        NSString* fileName = [NSString stringWithFormat:@"img/%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];
        BackendlessFile *profileFile = [backendless.fileService saveFile:fileName content:UIImageJPEGRepresentation(userdata.profileImage, 0.9)];
        [user setProperty:PROPERTY_PICTURE object:profileFile.fileURL];
    }
    
    [backendless.userService registering:user response:^(BackendlessUser *returnUser)  {
        [backendless.userService setStayLoggedIn:YES];
        completionBlock(true,nil);
    } error:^(Fault * fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+(void) updateUser:(UserData *)userdata isProfileImgChanged:(BOOL)isProfileImgChanged isPasswordChanged:(BOOL)isPasswordChanged completion:(ServiceResponse)completionBlock {
    backendless.userService.currentUser.email = userdata.email;
    if(userdata.sendNotification){
        [backendless.userService.currentUser setProperty:PROPERTY_NOTIFY object:userdata.sendNotification];
    }
    if(isPasswordChanged)
        backendless.userService.currentUser.password = userdata.password;
    [backendless.userService.currentUser setProperty:PROPERTY_PERM_NUMBER object:userdata.permNumber];
    if(isProfileImgChanged){
        NSString* fileName = [NSString stringWithFormat:@"img/%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];
        BackendlessFile *profileFile = [backendless.fileService saveFile:fileName content:UIImageJPEGRepresentation(userdata.profileImage, 0.9)];
        [backendless.userService.currentUser setProperty:PROPERTY_PICTURE object:profileFile.fileURL];
    }
    [backendless.userService update:backendless.userService.currentUser response:^(BackendlessUser *use) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);

    }];
}

+(void) updateActiveTime {
    BackendlessUser* user = backendless.userService.currentUser;
    [user setProperty:@"active" object:[NSDate date]];
    [backendless.userService update:backendless.userService.currentUser response:^(BackendlessUser *use) {
    } error:^(Fault *fault) {
    }];
}


+(void) updateLocation:(GeoPoint *)location completion:(ServiceResponse)completionBlock {
    if(![GeneralHelper canDoUpdateLoccation])
        return;
    
    if(location.latitude == 0)
        return;
    
    BackendlessUser* user = backendless.userService.currentUser;
    if(user) {
        if((location.latitude == 0) && (location.longitude == 0)){
            
        } else {
            GeoPoint* currentLoc = [GeneralHelper checkForNull:[user getProperty:@"geolocation" ]];
            if(currentLoc){
                if (!location.objectId) {
                    if([AppDelegate sharedDelegate].geoObjectId){
                        location.objectId = [AppDelegate sharedDelegate].geoObjectId;
                    }
                    //                    location.objectId = currentLoc.objectId;
                }
            }
            
            [backendless.geo
             savePoint:location
             response:^(GeoPoint *response) {
                 if (!location.objectId) {
                     [GeneralHelper updateLocationComplete];
                     location.objectId = response.objectId;
                     [AppDelegate sharedDelegate].geoObjectId = response.objectId;
                     [user setProperty:@"geolocation" object:location];
                     [backendless.userService update:user response:^(BackendlessUser *val) {
                         completionBlock(true,nil);
                     } error:^(Fault *fault) {
                         completionBlock(false,[BackendHelper convertFaultToError:fault]);
                     }];
                 }
                 else {
                     [GeneralHelper updateLocationComplete];
                     NSLog(@"GeoFenceClientCallback -> savePoint: (ASYNC) Geopoint position has been updated: %@", location);
                     completionBlock(true,nil);
                 }
             }
             error:^(Fault *fault) {
                 NSLog(@"GeoFenceClientCallback -> savePoint: (ASYNC) Server reported an error: (FAULT) %@", fault);
                 completionBlock(false,[BackendHelper convertFaultToError:fault]);
             }];
            
        }
    }
}

+(void) forgotPassword:(NSString *)username completion:(ServiceResponse)completionBlock {
    [backendless.userService restorePassword:username response:^(id val) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+(void) fetchSchools:(ServiceListResponse)completionBlock {
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"name ASC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    
    [backendless.persistenceService find:[Schools class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(Schools* event in dataCollection.data){
            [eventDataList addObject:event];
        }
        completionBlock(true, eventDataList, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];

}

+(void) fetchSubjects:(Schools *)school search:(NSString *)searchText completion:(ServiceSubjectListResponse)completionBlock {
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"name ASC"];
    queryOptions.pageSize = [NSNumber numberWithInt:50];

    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    if(searchText)
        dataQuery.whereClause = [NSString stringWithFormat:@"school.objectId = \'%@\' AND name LIKE \'%%%@%%\'", school.objectId, searchText];
    else
        dataQuery.whereClause = [NSString stringWithFormat:@"school.objectId = \'%@\'", school.objectId];
    
    [backendless.persistenceService find:[Subject class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(Subject* event in dataCollection.data){
            [eventDataList addObject:event];
        }
        completionBlock(true, eventDataList, dataCollection, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+(void) fetchMoreSubjects:(id)dataCollection completion:(ServiceSubjectListResponse)completionBlock {
    [dataCollection nextPageAsync:^(BackendlessCollection *dataCollection) {
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(Subject* event in dataCollection.data){
            [eventDataList addObject:event];
        }
        completionBlock(true, eventDataList, dataCollection, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, nil, [BackendHelper convertFaultToError:fault]);
    }];
}


+(void) addMySubject:(NSString *)subject shortname:(NSString *)shortname red:(float)red green:(float)green blue:(float)blue completion:(ServiceResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    StudentDetail* userDetail = [GeneralHelper checkForNull:[user getProperty:PROPERTY_STUDENT_DETAIL]];
    if(!userDetail){
        userDetail = [[StudentDetail alloc] init];
    }
    
    MyClasses* myClass = [MyClasses createMyClasse:subject shortname:shortname red:red green:green blue:blue];
    [userDetail addMyClass:myClass];
    [user setProperty:PROPERTY_STUDENT_DETAIL object:userDetail];
    
    [backendless.userService update:user response:^(BackendlessUser *response) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+(void) updateMySubject:(MyClasses *)myclass completion:(ServiceResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    [backendless.userService update:user response:^(BackendlessUser *response) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+(void) deleteMySubject:(MyClasses *)myclass completion:(ServiceResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    [backendless.userService update:user response:^(BackendlessUser *response) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}


+(void) fetchUserWithMatch:(NSArray *)subjects completion:(ServiceListResponse)completionBlock {
    if([subjects count] == 0){
        completionBlock(true, [[NSMutableArray alloc] init], nil);
    }
    
    BackendlessUser* user = backendless.userService.currentUser;
    StudentDetail* userDetail = [GeneralHelper checkForNull:[user getProperty:PROPERTY_STUDENT_DETAIL]];
    Schools* school = [user getProperty:PROPERTY_SCHOOL];

    NSMutableString* whereClause = [[NSMutableString alloc] initWithString:@""];
    [whereClause appendFormat:@"school.objectId = \'%@\' AND (", school.objectId];
    int i = 0;
    for(MyClasses* myClass in userDetail.classes){
        if([subjects containsObject:myClass.name]){
        if(i != 0){
            [whereClause appendString:@" OR "];
        }
        [whereClause appendFormat:@"userdetail.classes.name = \'%@\'", myClass.name];
        i++;
        }
    }
    [whereClause appendString:@")"];
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"name ASC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = whereClause;
    
    [backendless.persistenceService find:[BackendlessUser class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(BackendlessUser* event in dataCollection.data){
            if([event.objectId isEqualToString:user.objectId])
                continue;
            UserData* data = [[UserData alloc] init];
            [data initWithBackendData:event];
            [eventDataList addObject:data];
        }
        completionBlock(true, eventDataList, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

/*
+(void) checkIFEmailValid:(NSString *)emailId schoolId:(NSString *)schoolId completion:(ServiceBOOLResponse)completionBlock {
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"name ASC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = [NSString stringWithFormat:@"email = \'%@\' AND schoolId = \'%@\'", emailId, schoolId];

    id<IDataStore> dataStore = [backendless.persistenceService of:[Student class]];
    [dataStore find:dataQuery response:^(BackendlessCollection * dataCollection) {
        if([dataCollection.data count] > 0)
            completionBlock(true, true, nil);
        else
            completionBlock(true, false, nil);
    } error:^(Fault *fault) {
        completionBlock(false, false, [BackendHelper convertFaultToError:fault]);
    }];
} */

+ (void) getNewMessageUserList:(NSMutableArray *)users completionBlock:(ServiceListResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    NSMutableString* whereClause = [[NSMutableString alloc] initWithString:@""];
    [whereClause appendFormat:@"recipientId = \'%@\' AND msgRead = false", user.objectId];
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.whereClause = whereClause;

    [backendless.persistenceService find:[ChatData class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(LastChat* event in dataCollection.data){
            if([event.user1Id isEqualToString:user.objectId]){
                NSNumber* num = [GeneralHelper checkForNull:event.deletedUser1];
                if(num){
                    if([num boolValue])
                        continue;
                }
            }
            if([event.user2Id isEqualToString:user.objectId]){
                NSNumber* num = [GeneralHelper checkForNull:event.deletedUser2];
                if(num){
                    if([num boolValue])
                        continue;
                }
            }
            [eventDataList addObject:event];
        }
        completionBlock(true, eventDataList, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) getInboxMessageList:(ServiceListResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"updated DESC"];

    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.whereClause = [NSString stringWithFormat:@"user1Id = \'%@\' OR user2Id = \'%@\'", user.objectId, user.objectId];
    dataQuery.queryOptions = queryOptions;
    
    
    [backendless.persistenceService find:[LastChat class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(LastChat* event in dataCollection.data){
            if([event.user1Id isEqualToString:user.objectId]){
                NSNumber* num = [GeneralHelper checkForNull:event.deletedUser1];
                if(num){
                    if([num boolValue])
                        continue;
                }
            }
            if([event.user2Id isEqualToString:user.objectId]){
                NSNumber* num = [GeneralHelper checkForNull:event.deletedUser2];
                if(num){
                    if([num boolValue])
                        continue;
                }
            }
            [eventDataList addObject:event];
        }
        completionBlock(true, eventDataList, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) getLastMessage:(NSString *)userId completion:(ServiceLastChatResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"timestamp DESC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = [NSString stringWithFormat:@"(user1Id = \'%@\' OR user1Id = \'%@\') AND (user2Id = \'%@\' OR user2Id = \'%@\')", user.objectId, userId, user.objectId, userId];
    
    [backendless.persistenceService find:[LastChat class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        if([dataCollection.data count] > 0){
            LastChat* event = dataCollection.data[0];
            completionBlock(true, event, nil);
        } else
            completionBlock(true, nil, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) getMessageList:(NSString *)forUserId completionBlock:(ServiceListResponse)completionBlock {
    NSMutableArray* returnMessageList = [[NSMutableArray alloc] init];
    BackendlessUser* user = backendless.userService.currentUser;
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"timestamp DESC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = [NSString stringWithFormat:@"(senderId = \'%@\' OR senderId = \'%@\') AND (recipientId = \'%@\' OR recipientId = \'%@\')", user.objectId, forUserId, user.objectId, forUserId];
    
    [backendless.persistenceService find:[ChatData class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        [returnMessageList removeAllObjects];
        NSArray* chatMessageArray = [[dataCollection.data reverseObjectEnumerator] allObjects];
        for(ChatData* event in chatMessageArray){
            if([event isKindOfClass:[ChatData class]]) {
                if(![event isMessageRead]){
                    if([event.recipientId isEqualToString:user.objectId]){
                        [BackendHelper markMessageRead:event];
                    }
                }
            }
            [returnMessageList addObject:event];
        }
        completionBlock(true, returnMessageList , nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) addNewMessage:(NSString *)message toUser:(UserData *)toUser toUserDeviceId:(NSString *)toUserDeviceId lastMessageId:(NSString *)lastMessageId completionBlock:(ServiceMessageResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    
        if(lastMessageId){
            id<IDataStore> dataStore = [backendless.persistenceService of:[LastChat class]];
            [dataStore findID:lastMessageId response:^(id lastMsg) {
                LastChat* lastMessage = (LastChat *)lastMsg;
                lastMessage.text = message;
                lastMessage.timestamp = [NSDate date];
                if([lastMessage.user1Id isEqualToString:user.objectId]){
                    lastMessage.deletedUser1 = [NSNumber numberWithBool:false];
                } else if([lastMessage.user2Id isEqualToString:user.objectId]){
                    lastMessage.deletedUser2 = [NSNumber numberWithBool:false];
                }
                id<IDataStore> dataStoreChat = [backendless.persistenceService of:[LastChat class]];
                [dataStoreChat save:lastMessage response:^(id newLastMsg) {
                    completionBlock(true, nil, ((LastChat *)newLastMsg).objectId, nil);
                } error:^(Fault *fault) {
                    completionBlock(false, nil, nil, [BackendHelper convertFaultToError:fault]);
                }];
            } error:^(Fault *fault) {
                completionBlock(false, nil, nil, [BackendHelper convertFaultToError:fault]);
            }];
        } else {
            LastChat* lastMessage = [[LastChat alloc] init];
            lastMessage.user1Id = user.objectId;
            lastMessage.user1 = user;
            lastMessage.deletedUser1 = [NSNumber numberWithBool:false];
            lastMessage.user2Id = toUser.objectId;
            lastMessage.user2 = toUser.userObj;
            lastMessage.deletedUser2 = [NSNumber numberWithBool:false];
            lastMessage.text = message;
            lastMessage.timestamp = [NSDate date];
            id<IDataStore> dataStoreChat = [backendless.persistenceService of:[LastChat class]];
            [dataStoreChat save:lastMessage response:^(id newLastMsg) {
                completionBlock(true, nil, ((LastChat *)newLastMsg).objectId, nil);
            } error:^(Fault *fault) {
                completionBlock(false, nil, nil, [BackendHelper convertFaultToError:fault]);
            }];
        }
//        if([toUser canSendNotification])
//            [self sendChatNotification:message sendTo:toUser.objectId toUserDeviceId:toUserDeviceId];
//    } error:^(Fault *fault) {
//        completionBlock(false, nil, nil, [BackendHelper convertFaultToError:fault]);
//    }];
}

+ (void) markMessageRead:(ChatData *)message {
    [message markMessageRead];
    id<IDataStore> dataStore = [backendless.persistenceService of:[ChatData class]];
    [dataStore save:message response:^(id msg) {
        
    } error:^(Fault *fault) {
        
    }];
}

+ (void) deleteMessages:(LastChat *)messageData completion:(ServiceResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    NSString* friendId;
    if([messageData.user1Id isEqualToString:user.objectId]){
        messageData.deletedUser1 = [NSNumber numberWithBool:TRUE];
        friendId = messageData.user2Id;
    } else {
        messageData.deletedUser2 = [NSNumber numberWithBool:TRUE];
        friendId = messageData.user1Id;
    }
    id<IDataStore> dataStore = [backendless.persistenceService of:[LastChat class]];
    [dataStore save:messageData response:^(id msg) {
        [BackendHelper markIndividualChatAsDeleted:friendId];
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) markIndividualChatAsDeleted:(NSString *)forUserId {
/*    BackendlessUser* user = backendless.userService.currentUser;
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"timestamp DESC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = [NSString stringWithFormat:@"(senderId = \'%@\' OR senderId = \'%@\') AND (recipientId = \'%@\' OR recipientId = \'%@\')", user.objectId, forUserId, user.objectId, forUserId];
    
    id<IDataStore> dataStore = [backendless.persistenceService of:[ChatData  class]];
    [dataStore find:dataQuery response:^(BackendlessCollection * dataCollection) {
        for(ChatData* event in dataCollection.data){
            if(![event isMessageRead]){
                if([event.recipientId isEqualToString:user.objectId]){
                    [BackendHelper markMessageRead:event];
                }
            }
        }
    } error:^(Fault *fault) {
    }]; */
}

+(void) updateDeviceId:(ServiceResponse)completionBlock {
    NSString* deviceId = backendless.messagingService.currentDevice.deviceId;
    BackendlessUser* currentUser = backendless.userService.currentUser;
    DeviceUserMap* map = [DeviceUserMap deviceMapWith:currentUser.objectId deviceId:deviceId];
    
    [backendless.persistenceService save:map response:^(id obj) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+(void) getDeviceId:(NSString *)userid completionBlock:(ServiceStringResponse)completionBlock {
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.whereClause = [NSString stringWithFormat:@"userId = \'%@\'", userid];
    
    [backendless.persistenceService find:[DeviceUserMap  class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        if([dataCollection.data count] > 0){
            DeviceUserMap* map = dataCollection.data[0];
            completionBlock(true, map.deviceId , nil);
        } else
            completionBlock(true, @"" , nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];

}

+ (void) sendChatNotification:(NSString *)msg sendTo:(NSString *)sendToId toUserDeviceId:(NSString *)toUserDeviceId {
    if(toUserDeviceId == nil)
        return;
        
    DeliveryOptions *deliveryOptions = [DeliveryOptions new];
    deliveryOptions.pushSinglecast = @[toUserDeviceId];
    BackendlessUser* user = backendless.userService.currentUser;

    NSString* alertText = [NSString stringWithFormat:@"%@: %@",[user getProperty:PROPERTY_NAME],msg];

    
    PublishOptions *publishOptions = [PublishOptions new];
    [publishOptions addHeader:@"ios-alert" value:alertText];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          alertText, @"alert",
                          user.objectId, @"id",
                          @"c", @"type",
                          nil];

    
    [backendless.messagingService publish:@"default" message:data publishOptions:publishOptions deliveryOptions:deliveryOptions
        response:^(MessageStatus *messageStatus) {
            NSLog(@"MessageStatus = %@ <%@>", messageStatus.messageId, messageStatus.status);
        }
        error:^(Fault *fault) {
            NSLog(@"FAULT = %@", fault);
        }
     ];
}

+(void) sendEmail:(NSString *)subject body:(NSString *)body completionBlock:(ServiceResponse)completionBlock {
    NSString *recipient = @"studynow8@gmail.com";
    [backendless.messagingService sendHTMLEmail:subject body:body to:@[recipient] response:^(id val) {
        completionBlock(true, nil);
    } error:^(Fault *fault) {
        completionBlock(false, [BackendHelper convertFaultToError:fault]);
    }];
}


+ (void)saveImageMessagesOnParse:(ChatData *)message image:(UIImage *)image completionBlock:(ServiceChatDataResponse)completionBlock {
    
    CGSize origSize = image.size;
    UIImage *eventImage = [image imageScaledToFitSize:[GeneralHelper getMainImageSize:origSize]];
    UIImage *thumbnailImage = [image imageScaledToFitSize:[GeneralHelper getThumbnailImageSize:origSize]];

    NSString* fileName = [NSString stringWithFormat:@"img/%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];
    NSString* thumbFileName = [NSString stringWithFormat:@"img/thumb%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];

    [backendless.fileService saveFile:thumbFileName content:UIImageJPEGRepresentation(thumbnailImage, 0.9) response:^(BackendlessFile *thumbFile) {
        message.thumbnailUrl = thumbFile.fileURL;
        [backendless.fileService saveFile:fileName content:UIImageJPEGRepresentation(eventImage, 0.9) response:^(BackendlessFile *mainFile) {
            message.imageUrl = mainFile.fileURL;
            id<IDataStore> dataStore = [backendless.persistenceService of:[ChatData class]];
            [dataStore save:message response:^(id newChatData) {
                completionBlock(true, newChatData, nil);
            } error:^(Fault *fault) {
                completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
            }];
        } error:^(Fault *fault) {
            completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
        }];
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}


+ (void)saveTextMessagesOnParse:(ChatData *)message completionBlock:(ServiceChatDataResponse)completionBlock {
    id<IDataStore> dataStore = [backendless.persistenceService of:[ChatData class]];
    [dataStore save:message response:^(id newChatData) {
        completionBlock(true, newChatData, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void)saveMessagesOnParse:(id<SINMessage>)message {
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.whereClause = [NSString stringWithFormat:@"messageId = \'%@\'", [message messageId]];
    
    [backendless.persistenceService find:[ChatData class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        if([dataCollection.data count] <= 0){
            ChatData *messageObject = [[ChatData alloc] init];
            messageObject.messageId = [message messageId];
            messageObject.senderId = [message senderId];
            messageObject.recipientId = [message recipientIds][0];
            messageObject.text = [message text];
            messageObject.timestamp = [message timestamp];
            messageObject.msgRead = [NSNumber numberWithBool:false];
            id<IDataStore> dataStore = [backendless.persistenceService of:[ChatData class]];
            [dataStore save:messageObject response:^(id newChatData) {
                
            } error:^(Fault *fault) {
            }];
        }
    } error:^(Fault *fault) {
        NSLog(@"%@", fault.message);
    }];
}

+ (void)saveTextGroupMessagesOnParse:(GroupChatMessages *)message groupId:(NSString *)groupId groupChatDate:(GroupChat *)groupChatData completionBlock:(ServiceGroupDataResponse)completionBlock {
    id<IDataStore> dataStore = [backendless.persistenceService of:[GroupChatMessages class]];
    [dataStore save:message response:^(id newChatData) {
        [BackendHelper updateLatestChatOnGroupChat:groupChatData];
        completionBlock(true, newChatData, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void)saveImageGroupMessagesOnParse:(GroupChatMessages *)message groupId:(NSString *)groupId groupChatDate:(GroupChat *)groupChatData image:(UIImage *)image completionBlock:(ServiceGroupDataResponse)completionBlock {
    
    CGSize origSize = image.size;
    UIImage *eventImage = [image imageScaledToFitSize:[GeneralHelper getMainImageSize:origSize]];
    UIImage *thumbnailImage = [image imageScaledToFitSize:[GeneralHelper getThumbnailImageSize:origSize]];
    
    NSString* fileName = [NSString stringWithFormat:@"img/%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];
    NSString* thumbFileName = [NSString stringWithFormat:@"img/thumb%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];
    
    [backendless.fileService saveFile:thumbFileName content:UIImageJPEGRepresentation(thumbnailImage, 0.9) response:^(BackendlessFile *thumbFile) {
        message.thumbnailUrl = thumbFile.fileURL;
        [backendless.fileService saveFile:fileName content:UIImageJPEGRepresentation(eventImage, 0.9) response:^(BackendlessFile *mainFile) {
            message.imageUrl = mainFile.fileURL;
            id<IDataStore> dataStore = [backendless.persistenceService of:[GroupChatMessages class]];
            [dataStore save:message response:^(id newChatData) {
                [BackendHelper updateLatestChatOnGroupChat:groupChatData];
                completionBlock(true, newChatData, nil);
            } error:^(Fault *fault) {
                completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
            }];
        } error:^(Fault *fault) {
            completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
        }];
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) updateLatestChatOnGroupChat:(GroupChat *)groupChat {
    groupChat.lastChatTime = [NSDate date];
    groupChat.lastChatBy = [BackendHelper getCurrentUserObjectId];

    id<IDataStore> dataStoreChat = [backendless.persistenceService of:[GroupChat class]];
    [dataStoreChat save:groupChat response:^(id newLastMsg) {
    } error:^(Fault *fault) {
    }];
}

+ (void)saveGroupMessagesOnParse:(id<SINMessage>)message groupId:(NSString *)groupId completionBlock:(ServiceResponse)completionBlock {
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.whereClause = [NSString stringWithFormat:@"messageId = \'%@\'", [message messageId]];
    
    [backendless.persistenceService find:[GroupChatMessages class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        if([dataCollection.data count] <= 0){
            GroupChatMessages *messageObject = [[GroupChatMessages alloc] init];
            messageObject.messageId = [message messageId];
            messageObject.senderId = [message senderId];
            messageObject.recipientId = @"";
            messageObject.text = [message text];
            messageObject.timestamp = [message timestamp];
            messageObject.msgRead = [NSNumber numberWithBool:false];
            messageObject.groupId = groupId;
            id<IDataStore> dataStore = [backendless.persistenceService of:[GroupChatMessages class]];
            [dataStore save:messageObject response:^(id newChatData) {
                completionBlock(true, nil);
            } error:^(Fault *fault) {
                completionBlock(false, [BackendHelper convertFaultToError:fault]);
            }];
        } else {
            completionBlock(true, nil);
        }
    } error:^(Fault *fault) {
        NSLog(@"%@", fault.message);
        completionBlock(false, [BackendHelper convertFaultToError:fault]);
    }];
}


+ (void) createNewChatGroup:(NSString *)name chatTime:(NSDate *)chatTime myClass:(MyClasses *)myClass groupSize:(int)groupSize location:(NSString *)location groupImage:(UIImage *)groupImage completionBlock:(ServiceResponse)completionBlock {

    BackendlessUser* user = backendless.userService.currentUser;
//    StudentDetail* userDetail = [GeneralHelper checkForNull:[user getProperty:PROPERTY_STUDENT_DETAIL]];
    Schools* school = [user getProperty:PROPERTY_SCHOOL];

    if(groupImage){
        NSInteger imgWidth = groupImage.size.width;
        NSInteger imgHeight = groupImage.size.height;
        NSInteger newWidth = 400;
        NSInteger newHeight = (newWidth * imgHeight) / imgWidth;
        UIImage * thumbImage = [groupImage imageScaledToFitSize:CGSizeMake(newWidth, newHeight)];

        NSString* thumbFileName = [NSString stringWithFormat:@"img/thumb%0.0f.jpeg",[[NSDate date] timeIntervalSince1970]];
        [backendless.fileService saveFile:thumbFileName content:UIImageJPEGRepresentation(thumbImage, 0.9) response:^(BackendlessFile *profileFile) {
            GroupChat* groupChat = [[GroupChat alloc] init];
            groupChat.groupBy = user.objectId;
            groupChat.chatTime = chatTime;
            groupChat.groupName = name;
            groupChat.subject = myClass.name;
            groupChat.schoolId = school.objectId;
            groupChat.myClass = myClass;
            groupChat.groupSize = [NSNumber numberWithInt:groupSize];
            groupChat.location = location;
            groupChat.picture = profileFile.fileURL;
            NSMutableArray* participants = [[NSMutableArray alloc] init];
            [participants addObject:user];
            groupChat.participants = participants;
        
            id<IDataStore> dataStoreChat = [backendless.persistenceService of:[GroupChat class]];
            [dataStoreChat save:groupChat response:^(id newLastMsg) {
                completionBlock(true, nil);
            } error:^(Fault *fault) {
                completionBlock(false, [BackendHelper convertFaultToError:fault]);
            }];
        } error:^(Fault *fault) {
            completionBlock(false,[BackendHelper convertFaultToError:fault]);
        }];
    } else {
        GroupChat* groupChat = [[GroupChat alloc] init];
        groupChat.groupBy = user.objectId;
        groupChat.chatTime = chatTime;
        groupChat.groupName = name;
        groupChat.subject = myClass.name;
        groupChat.schoolId = school.objectId;
        groupChat.myClass = myClass;
        groupChat.groupSize = [NSNumber numberWithInt:groupSize];
        groupChat.location = location;
        groupChat.picture = @"";
        NSMutableArray* participants = [[NSMutableArray alloc] init];
        [participants addObject:user];
        groupChat.participants = participants;
        
        id<IDataStore> dataStoreChat = [backendless.persistenceService of:[GroupChat class]];
        [dataStoreChat save:groupChat response:^(id newLastMsg) {
            completionBlock(true, nil);
        } error:^(Fault *fault) {
            completionBlock(false, [BackendHelper convertFaultToError:fault]);
        }];
    }
    
}

+(void) fetchGroupWithMatch:(NSArray *)subjects completion:(ServiceListResponse)completionBlock {
    if([subjects count] == 0){
        completionBlock(true, [[NSMutableArray alloc] init], nil);
    }
    
    BackendlessUser* user = backendless.userService.currentUser;
    StudentDetail* userDetail = [GeneralHelper checkForNull:[user getProperty:PROPERTY_STUDENT_DETAIL]];
    Schools* school = [user getProperty:PROPERTY_SCHOOL];
    
    NSMutableString* whereClause = [[NSMutableString alloc] initWithString:@""];
    [whereClause appendFormat:@"schoolId = \'%@\' AND (", school.objectId];
    int i = 0;
    for(MyClasses* myClass in userDetail.classes){
        if([subjects containsObject:myClass.name]){
            if(i != 0){
                [whereClause appendString:@" OR "];
            }
            [whereClause appendFormat:@"myClass.name = \'%@\'", myClass.name];
            i++;
        }
    }
    [whereClause appendString:@")"];
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"chatTime ASC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = whereClause;
    
    [backendless.persistenceService find:[GroupChat class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        NSMutableArray* eventDataList = [[NSMutableArray alloc] init];
        for(GroupChat* event in dataCollection.data){
//            if([event.objectId isEqualToString:user.objectId])
//                continue;
//            UserData* data = [[UserData alloc] init];
//            [data initWithBackendData:event];
            [eventDataList addObject:event];
        }
        completionBlock(true, eventDataList, nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) getGroupMessageList:(NSString *)forGroupId completionBlock:(ServiceListResponse)completionBlock {
    NSMutableArray* returnMessageList = [[NSMutableArray alloc] init];
    BackendlessUser* user = backendless.userService.currentUser;
    
    QueryOptions *queryOptions = [QueryOptions query];
    queryOptions.sortBy = @[@"timestamp DESC"];
    
    BackendlessDataQuery *dataQuery = [BackendlessDataQuery query];
    dataQuery.queryOptions = queryOptions;
    dataQuery.whereClause = [NSString stringWithFormat:@"(groupId = \'%@\')", forGroupId];
    
    [backendless.persistenceService find:[GroupChatMessages class] dataQuery:dataQuery response:^(BackendlessCollection * dataCollection) {
        [returnMessageList removeAllObjects];
        NSArray* chatMessageArray = [[dataCollection.data reverseObjectEnumerator] allObjects];
        for(GroupChatMessages* event in chatMessageArray){
//            if([event isKindOfClass:[GroupChatMessages class]]) {
//                if(![event isMessageRead]){
//                    if([event.recipientId isEqualToString:user.objectId]){
//                        [BackendHelper markMessageRead:event];
//                    }
//                }
//            }
            [returnMessageList addObject:event];
        }
        completionBlock(true, returnMessageList , nil);
    } error:^(Fault *fault) {
        completionBlock(false, nil, [BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) addToGroupChat:(GroupChat *)groupChat completionBlock:(ServiceResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    NSMutableArray* participants = groupChat.participants;
    [participants addObject:user];
    groupChat.participants = participants;
    
    id<IDataStore> dataStoreChat = [backendless.persistenceService of:[GroupChat class]];
    [dataStoreChat save:groupChat response:^(id newLastMsg) {
        completionBlock(true, nil);
    } error:^(Fault *fault) {
        completionBlock(false, [BackendHelper convertFaultToError:fault]);
    }];

}

+ (void) removeFromGroupChat:(GroupChat *)groupChat completionBlock:(ServiceResponse)completionBlock {
    BackendlessUser* user = backendless.userService.currentUser;
    NSMutableArray* participants = groupChat.participants;
    for(BackendlessUser* pUser in participants){
        if([pUser.objectId isEqualToString:user.objectId]){
            [participants removeObject:pUser];
            break;
        }
    }
    groupChat.participants = participants;
    
    id<IDataStore> dataStoreChat = [backendless.persistenceService of:[GroupChat class]];
    [dataStoreChat save:groupChat response:^(id newLastMsg) {
        completionBlock(true, nil);
    } error:^(Fault *fault) {
        completionBlock(false, [BackendHelper convertFaultToError:fault]);
    }];
}


+ (void) deleteGroupChat:(GroupChat *)groupChat completionBlock:(ServiceResponse)completionBlock {
    [backendless.persistenceService remove:groupChat response:^(NSNumber *num) {
        completionBlock(true,nil);
    } error:^(Fault *fault) {
        completionBlock(false,[BackendHelper convertFaultToError:fault]);
    }];
}

+ (void) updateGroupChatName:(GroupChat *)groupChat newName:(NSString *)name completionBlock:(ServiceResponse)completionBlock {
    groupChat.groupName = name;
    id<IDataStore> dataStoreChat = [backendless.persistenceService of:[GroupChat class]];
    [dataStoreChat save:groupChat response:^(id newLastMsg) {
        completionBlock(true, nil);
    } error:^(Fault *fault) {
        completionBlock(false, [BackendHelper convertFaultToError:fault]);
    }];
}


+ (BOOL) isOwnerOfGroup:(GroupChat *)groupChat {
    BackendlessUser* user = backendless.userService.currentUser;
    if([groupChat.groupBy isEqualToString:user.objectId])
        return true;

    return false;
}

+ (BOOL) isPartOfGroup:(GroupChat *)groupChat {
    BackendlessUser* currentUser = backendless.userService.currentUser;
    
    BOOL found = false;
    for(BackendlessUser* user in groupChat.participants){
        if([user.objectId isEqualToString:currentUser.objectId]){
            found = true;
            break;
        }
    }
    
    return found;
}

+ (NSMutableArray *) convertUserToIds:(NSMutableArray *)list {
    NSMutableArray* returnList = [[NSMutableArray alloc] init];
    for(BackendlessUser* user in list){
        [returnList addObject:user.objectId];
    }
    
    return returnList;
}

+ (NSMutableArray *) convertParticipantsToIds:(NSMutableArray *)list {
    BackendlessUser* currentUser = backendless.userService.currentUser;
    NSMutableArray* returnList = [[NSMutableArray alloc] init];
    for(BackendlessUser* user in list){
        if([user.objectId isEqualToString:currentUser.objectId])
            continue;
        
        [returnList addObject:user.objectId];
    }
    
    return returnList;
}

@end
