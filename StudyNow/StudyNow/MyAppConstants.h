//
//  MyAppConstants.h
//  Alike
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define DOCUMENTS_PATH          [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define SINCH_GROUP_MESSAGE_RECIEVED @"SINCH_GROUP_MESSAGE_RECIEVED"
#define SINCH_GROUP_MESSAGE_SENT @"SINCH_GROUP_MESSAGE_SENT"
#define SINCH_MESSAGE_RECIEVED @"SINCH_MESSAGE_RECIEVED"
#define SINCH_MESSAGE_SENT @"SINCH_MESSAGE_SENT"
#define SINCH_MESSAGE_DELIVERED @"SINCH_MESSAGE_DELIVERED"
#define SINCH_MESSAGE_FAILED @"SINCH_MESSAGE_DELIVERED"

#define     APP_ID            @"701F138B-C14F-6FF3-FF66-3FBA4E094D00"
#define     SECRET_ID            @"660D37FD-2F2D-5C5F-FF87-C937D7B7B300"
#define     VERSION_NUM            @"v1"

#define     PROPERTY_NAME             @"name"
#define     PROPERTY_SCHOOL_NAME          @"schoolname"
#define     PROPERTY_PERM_NUMBER            @"permnumber"
#define     PROPERTY_EMAIL            @"email"
#define     PROPERTY_PASSWORD            @"password"
#define     PROPERTY_PICTURE            @"picture"
#define     PROPERTY_SCHOOL            @"school"
#define     PROPERTY_STUDENT_DETAIL    @"userdetail"
#define     PROPERTY_NOTIFY    @"cannotify"

// Notifications
#define     kDidFetchProfileImageNotification            @"studynow.didFetchProfileImage"
#define     kDidReceivedChatNotification                  @"potluck.didReceivedChatNotification"

#define     MESSAGE_OBJECTID        @"MsgObjId"

#define     MESSAGE_TYPE        @"MessageType"
#define     MESSAGE_TYPE_TEXT   @"MessageType_TEXT"
#define     MESSAGE_TYPE_IMAGE  @"MessageType_IMAGE"

#define     UNLIMITED_GROUP_COUNT               9999
#define     UNLIMITED_GROUP_COUNT_STRING        @"Unlimited"


#define METER_TO_MILES      0.000621371192
#define MILES_TO_METER      1609.344
