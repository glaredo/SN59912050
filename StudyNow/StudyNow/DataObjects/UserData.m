//
//  UserData.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/18/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "UserData.h"
#import "Backendless.h"
#import "MyAppConstants.h"
#import "GeneralHelper.h"
#import "ImageCacheHelper.h"
#import "BackendHelper.h"
#import "AppDelegate.h"

@implementation UserData

+ (UserData *) createWithBackendData:(BackendlessUser *)user {
    UserData* data = [[UserData alloc] init];
    [data initWithBackendData:user];
    return data;
}

- (void) initWithBackendData:(BackendlessUser *)user {
    [self initWithBackendData:user withImage:true];
}

- (void) initWithBackendData:(BackendlessUser *)user withImage:(BOOL)withImage {
    self.userObj = user;
    self.objectId = user.objectId;
    self.email = user.email;
    self.name = [user getProperty:PROPERTY_NAME];
    self.school = [user getProperty:PROPERTY_SCHOOL];
    self.schoolname = [user getProperty:PROPERTY_SCHOOL_NAME];
    self.permNumber = [user getProperty:PROPERTY_PERM_NUMBER];
    self.studentDetail = [GeneralHelper checkForNull:[user getProperty:PROPERTY_STUDENT_DETAIL]];
    self.profileImageLoc = [GeneralHelper checkForNull:[user getProperty:PROPERTY_PICTURE]];
    self.sendNotification = [GeneralHelper checkForNull:[user getProperty:PROPERTY_NOTIFY]];
    
    self.geoLocation = [GeneralHelper checkForNull:[user getProperty:@"geolocation" ]];

//    if(withImage) {
    UIImage* image = [[ImageCacheHelper sharedObject] getCachedImage:self.objectId];
    if(image){
        self.profileImage = image;
    } else {
        NSString* strUrl = [GeneralHelper checkForNull:[user getProperty:PROPERTY_PICTURE]];
        if(!strUrl)
            return;
        NSURL *url = [NSURL URLWithString:strUrl];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   NSHTTPURLResponse *responseUrl = [(NSHTTPURLResponse *)response copy];
                                   NSInteger statusCode = [responseUrl  statusCode];
                                   NSString *statusCause = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
                                   NSDictionary *headers = [responseUrl  allHeaderFields];
                                   
                                   if (statusCode == 200) {
                                       [[ImageCacheHelper sharedObject] cacheTheImage:self.objectId image:data];
                                       self.profileImage = [UIImage imageWithData:data];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kDidFetchProfileImageNotification object:nil userInfo:nil];
                                   } else {
                                       
                                   }
                               }];
    }
//    }
}

- (void) fetchProfileImage:(UIImageView *)imgView {
    UIImage* image = [[ImageCacheHelper sharedObject] getCachedImage:self.objectId];
    if(image){
        imgView.image = image;
    } else {
        NSString* strUrl = self.profileImageLoc;
        if(!strUrl)
            return;
        NSURL *url = [NSURL URLWithString:strUrl];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   NSHTTPURLResponse *responseUrl = [(NSHTTPURLResponse *)response copy];
                                   NSInteger statusCode = [responseUrl  statusCode];
                                   NSString *statusCause = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
                                   NSDictionary *headers = [responseUrl  allHeaderFields];
                                   
                                   if (statusCode == 200) {
                                       [[ImageCacheHelper sharedObject] cacheTheImage:self.objectId image:data];
                                       self.profileImage = [UIImage imageWithData:data];
                                       imgView.image = self.profileImage;
                                       
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kDidFetchProfileImageNotification object:nil userInfo:nil];
                                   } else {
                                       
                                   }
                               }];
    }
}

- (void) fetchProfileImageOnly:(UIImage *)imgOnly {
    UIImage* image = [[ImageCacheHelper sharedObject] getCachedImage:self.objectId];
    if(image){
        imgOnly = image;
    } else {
        NSString* strUrl = self.profileImageLoc;
        if(!strUrl)
            return;
        NSURL *url = [NSURL URLWithString:strUrl];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   NSHTTPURLResponse *responseUrl = [(NSHTTPURLResponse *)response copy];
                                   NSInteger statusCode = [responseUrl  statusCode];
                                   NSString *statusCause = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
                                   NSDictionary *headers = [responseUrl  allHeaderFields];
                                   
                                   if (statusCode == 200) {
                                       [[ImageCacheHelper sharedObject] cacheTheImage:self.objectId image:data];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kDidFetchProfileImageNotification object:nil userInfo:nil];
                                   } else {
                                       
                                   }
                               }];
    }
}

- (NSMutableArray *) getCommonSubjectWithCurrentUser {
    UserData* currentUser = [BackendHelper getCurrentUserNoImg];
    NSArray* currentUserClasses = currentUser.studentDetail.classes;
    
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for(MyClasses* myclasses in currentUserClasses){
        if([self.studentDetail isClassPresent:myclasses.name])
            [list addObject:myclasses.name];
//            [list addObject:[NSString stringWithFormat:@"%@ (%@)", myclasses.name, myclasses.shortname]];
    }
    
    return list;
}

- (NSMutableArray *) getCommonMyClassesWithCurrentUser {
    UserData* currentUser = [BackendHelper getCurrentUserNoImg];
    NSArray* currentUserClasses = currentUser.studentDetail.classes;
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for(MyClasses* myclasses in currentUserClasses){
        if([self.studentDetail isClassPresent:myclasses.name])
            [list addObject:myclasses];
    }
    
    return list;
}


- (NSString *) getAwayString {
    if(self.geoLocation){
        CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake([self.geoLocation.latitude doubleValue], [self.geoLocation.longitude doubleValue]);
        
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:userCoordinate.latitude longitude:userCoordinate.longitude];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:[AppDelegate sharedDelegate].myLocation.latitude longitude:[AppDelegate sharedDelegate].myLocation.longitude];
        CLLocationDistance distanceFromCurrent = [pointALocation distanceFromLocation:pointBLocation];
        float distance=(distanceFromCurrent * METER_TO_MILES);
        
        return [NSString stringWithFormat:@"%0.1f mi away",distance];
        
    }
    
    return @"";
}

- (BOOL) canSendNotification {
    if(self.sendNotification) {
        return [self.sendNotification boolValue];
    }
    
    return true;
}

- (NSString *) getActiveTime {
    NSDate* date = [GeneralHelper checkForNull:[self.userObj getProperty:@"active"]];
    if(date){
        NSString* timeSince = @"";
        NSInteger activeSince = [[NSDate date] timeIntervalSinceDate:date];
        if(activeSince < 60){
            timeSince = @"ACTIVE NOW";
        } else {
            NSInteger minutes = activeSince / 60;
            if(minutes < 60) {
                if(minutes == 1)
                    timeSince = @"ACTIVE 1 MINUTE AGO";
                else
                    timeSince = [NSString stringWithFormat:@"ACTIVE %d MINUTES AGO", (int)minutes];
            } else {
                NSInteger hours = minutes / 60;
                if(hours == 1){
                    timeSince = @"ACTIVE 1 HOUR AGO";
                } else if (hours <= 24) {
                    timeSince = [NSString stringWithFormat:@"ACTIVE %d HOURS AGO", (int)hours];
                } else {
                    NSInteger days = hours / 24;
                    if(days == 1) {
                        timeSince = @"ACTIVE 1 DAY AGO";
                    } else {
                        timeSince = [NSString stringWithFormat:@"ACTIVE %d DAYS AGO", (int)days];
                    }
                }
            }
        }
        return timeSince;
    } else {
        return @"";
    }
}


@end
