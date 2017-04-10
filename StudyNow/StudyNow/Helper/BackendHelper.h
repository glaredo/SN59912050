//
//  BackendHelper.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/18/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Sinch/Sinch.h>
#import "UserData.h"
#import "LastChat.h"
#import "ChatData.h"
#import "GroupChat.h"
#import "GroupChatMessages.h"

@class Fault;

@interface BackendHelper : NSObject

typedef void (^ServiceBOOLResponse)(BOOL success, BOOL result, NSError *error);
typedef void (^ServiceResponse)(BOOL success, NSError *error);
typedef void (^ServiceListResponse)(BOOL success, NSMutableArray* list, NSError *error);
typedef void (^ServiceSubjectListResponse)(BOOL success, NSMutableArray* list, id collection, NSError *error);
typedef void (^ServiceStringResponse)(BOOL success, NSString* list, NSError *error);
typedef void (^ServiceLastChatResponse)(BOOL success, LastChat* data, NSError *error);
typedef void (^ServiceChatDataResponse)(BOOL success, ChatData* data, NSError *error);
typedef void (^ServiceGroupDataResponse)(BOOL success, GroupChatMessages* data, NSError *error);
typedef void (^ServiceMessageResponse)(BOOL success, ChatData* data, NSString* lastMsgId, NSError *error);

+(NSError *) convertFaultToError:(Fault *)fault;

+(void) initializeService;
+(void) appDidBecomeActiveService;
+(void) didEnterBackground;

+(UserData *) getCurrentUser;
+(UserData *) getCurrentUserNoImg;
+(NSString *) getCurrentUserObjectId;
+(NSString *) getCurrentUserName;
+(BOOL) isMe:(NSString *)objId;

+(void) updateActiveTime;

+(void) doLogout;
+(void) performUserSignIn:(NSString *)username password:(NSString *)password completion:(ServiceResponse)completionBlock;
+(void) createUser:(UserData *)userdata completion:(ServiceResponse)completionBlock;
+(void) forgotPassword:(NSString *)username completion:(ServiceResponse)completionBlock;
+(void) updateUser:(UserData *)userdata isProfileImgChanged:(BOOL)isProfileImgChanged isPasswordChanged:(BOOL)isPasswordChanged completion:(ServiceResponse)completionBlock;
+(void) updateLocation:(GeoPoint *)location completion:(ServiceResponse)completionBlock;

+(void) fetchSchools:(ServiceListResponse)completionBlock;
+(void) fetchSubjects:(Schools *)school search:(NSString *)searchText completion:(ServiceSubjectListResponse)completionBlock;
+(void) fetchMoreSubjects:(id)dataCollection completion:(ServiceSubjectListResponse)completionBlock;

+(void) addMySubject:(NSString *)subject shortname:(NSString *)shortname red:(float)red green:(float)green blue:(float)blue completion:(ServiceResponse)completionBlock;
+(void) updateMySubject:(MyClasses *)myclass completion:(ServiceResponse)completionBlock;
+(void) deleteMySubject:(MyClasses *)myclass completion:(ServiceResponse)completionBlock;

+(void) fetchUserWithMatch:(NSArray *)subjects completion:(ServiceListResponse)completionBlock;

//+(void) checkIFEmailValid:(NSString *)emailId schoolId:(NSString *)schoolId completion:(ServiceBOOLResponse)completionBlock;

// Messages
+ (void) getInboxMessageList:(ServiceListResponse)completionBlock;
+ (void) getMessageList:(NSString *)forUserId completionBlock:(ServiceListResponse)completionBlock;
+ (void) getLastMessage:(NSString *)userId completion:(ServiceLastChatResponse)completionBlock;
+ (void) addNewMessage:(NSString *)message toUser:(UserData *)toUser toUserDeviceId:(NSString *)toUserDeviceId lastMessageId:(NSString *)lastMessageId completionBlock:(ServiceMessageResponse)completionBlock;
+ (void) deleteMessages:(LastChat *)messageData completion:(ServiceResponse)completionBlock;
+ (void) markIndividualChatAsDeleted:(NSString *)profileSummary;
+ (void) getNewMessageUserList:(NSMutableArray *)users completionBlock:(ServiceListResponse)completionBlock;

+(void) updateDeviceId:(ServiceResponse)completionBlock;
+(void) getDeviceId:(NSString *)userid completionBlock:(ServiceStringResponse)completionBlock;

+(void) sendEmail:(NSString *)subject body:(NSString *)body completionBlock:(ServiceResponse)completionBlock;

+ (void)saveMessagesOnParse:(id<SINMessage>)message;
+ (void)saveTextMessagesOnParse:(ChatData *)message completionBlock:(ServiceChatDataResponse)completionBlock;
+ (void)saveImageMessagesOnParse:(ChatData *)message image:(UIImage *)image completionBlock:(ServiceChatDataResponse)completionBlock;
+ (void)saveGroupMessagesOnParse:(id<SINMessage>)message groupId:(NSString *)groupId completionBlock:(ServiceResponse)completionBlock;
+ (void)saveTextGroupMessagesOnParse:(GroupChatMessages *)message groupId:(NSString *)groupId groupChatDate:(GroupChat *)groupChatData completionBlock:(ServiceGroupDataResponse)completionBlock;
+ (void)saveImageGroupMessagesOnParse:(GroupChatMessages *)message groupId:(NSString *)groupId groupChatDate:(GroupChat *)groupChatData image:(UIImage *)image completionBlock:(ServiceGroupDataResponse)completionBlock;

+ (void) createNewChatGroup:(NSString *)name chatTime:(NSDate *)chatTime myClass:(MyClasses *)myClass groupSize:(int)groupSize location:(NSString *)location groupImage:(UIImage *)groupImage completionBlock:(ServiceResponse)completionBlock;
+(void) fetchGroupWithMatch:(NSArray *)subjects completion:(ServiceListResponse)completionBlock;
+ (void) getGroupMessageList:(NSString *)groupId completionBlock:(ServiceListResponse)completionBlock;
+ (void) addToGroupChat:(GroupChat *)groupChat completionBlock:(ServiceResponse)completionBlock;
+ (void) removeFromGroupChat:(GroupChat *)groupChat completionBlock:(ServiceResponse)completionBlock;
+ (void) deleteGroupChat:(GroupChat *)groupChat completionBlock:(ServiceResponse)completionBlock;
+ (void) updateGroupChatName:(GroupChat *)groupChat newName:(NSString *)name completionBlock:(ServiceResponse)completionBlock;

+ (BOOL) isOwnerOfGroup:(GroupChat *)groupChat;
+ (BOOL) isPartOfGroup:(GroupChat *)groupChat;
+ (NSMutableArray *) convertUserToIds:(NSMutableArray *)list;
+ (NSMutableArray *) convertParticipantsToIds:(NSMutableArray *)list;

@end
