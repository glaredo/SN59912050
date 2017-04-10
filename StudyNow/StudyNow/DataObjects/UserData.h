//
//  UserData.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/18/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Backendless.h"
#import "Schools.h"
#import "StudentDetail.h"

@class BackendlessUser;

@interface UserData : NSObject

@property (nonatomic, strong) BackendlessUser *userObj;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *schoolname;
//@property (nonatomic, strong) NSString *schoolemail;
@property (nonatomic, strong) NSString *permNumber;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSNumber *sendNotification;

@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSString *profileImageLoc;

@property (nonatomic, strong) Schools *school;

@property (nonatomic, strong) GeoPoint* geoLocation;

@property (nonatomic, strong) StudentDetail *studentDetail;

- (void) initWithBackendData:(BackendlessUser *)user withImage:(BOOL)withImage;

- (void) initWithBackendData:(BackendlessUser *)user;

+ (UserData *) createWithBackendData:(BackendlessUser *)user;

- (void) fetchProfileImage:(UIImageView *)imgView;

- (void) fetchProfileImageOnly:(UIImage *)img;

- (NSMutableArray *) getCommonSubjectWithCurrentUser;
- (NSMutableArray *) getCommonMyClassesWithCurrentUser;

- (NSString *) getAwayString;

- (BOOL) canSendNotification;

- (NSString *) getActiveTime;
@end
