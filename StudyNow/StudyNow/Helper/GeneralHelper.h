//
//  GeneralHelper.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GeneralHelper : NSObject

+ (void) addButtonBorder:(UIButton *)button;
+ (void) addLabelBorder:(UILabel *)label;
+ (void) roundProfileImgView:(UIImageView *)imgView;

+(BOOL) validateIsEmpty:(NSString *) string;
+(BOOL) validateEmail:(NSString *) candidate;
+(BOOL) verifyAStringIsNumber:(NSString *) string;

+(void) ShowMessageBoxWithTitle:(NSString*) title Body:(NSString*) message tag:(NSInteger) tag andDelegate:(id) delegate;

+ (id) checkForNull:(id)obj;
+ (id) checkForNullWithString:(id)obj;

+ (BOOL) canDoUpdateLoccation;
+ (void) updateLocationComplete;

+ (UIImage *) scaleAndRotateImage:(UIImage *)image fitSize:(CGSize)fitSize;

+ (NSDate *) getDateWithTime:(NSDate *)nowDt hour:(int)hour min:(int)min second:(int)second;

+ (NSDate *) getNextHour:(NSDate *)firstDate;

+ (NSString *) getTodayTomorrowDate:(NSDate *)dt;

+ (CGSize) getThumbnailImageSize:(CGSize) origSize;
+ (CGSize) getMainImageSize:(CGSize) origSize;

+ (NSDate *) getLastGroupChatVisitedDate:(NSString *)groupId;
+ (void) setLastGroupChatVisitedDate:(NSString *)objId viewDate:(NSDate *)viewDate;

+ (BOOL) checkIfNewGroupMessageToShow:(NSString *)groupId newDate:(NSDate *)newDate;

@end
