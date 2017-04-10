//
//  GeneralHelper.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "GeneralHelper.h"

@implementation GeneralHelper

+ (void) addButtonBorder:(UIButton *)button {
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor colorWithRed:49.0f/255.0f green:142.0f/255.0f blue:222.0f/255.0f alpha:1.0f].CGColor;
    button.layer.cornerRadius = 6.0f;
}

+ (void) addLabelBorder:(UILabel *)label {
    label.layer.borderWidth = 1.0f;
    label.layer.borderColor = [UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0f].CGColor;
    label.layer.cornerRadius = 6.0f;
}

+ (void) roundProfileImgView:(UIImageView *)imgView {
    CGRect rect = imgView.frame;
    imgView.layer.cornerRadius = rect.size.height / 2.0f;
}


+(BOOL) validateIsEmpty:(NSString *) string{
    if (string==nil) {
        return YES;
    }
    return string.length==0;
}

+(BOOL) validateEmail:(NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

+(BOOL) verifyAStringIsNumber:(NSString *) string{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    
    NSNumber* number = [numberFormatter numberFromString:string];
    
    return (number!=nil);
}

+(void) ShowMessageBoxWithTitle:(NSString*) title Body:(NSString*) message tag:(NSInteger) tag andDelegate:(id) delegate{
    UIAlertView *anAlert=[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [anAlert setTag:tag];
    [anAlert show];
}

+ (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

+ (id) checkForNullWithString:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return @"";
    
    if(obj == nil)
        return @"";
    
    return obj;
}

+ (BOOL) canDoUpdateLoccation {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSDate* lastFetched = [pref objectForKey:@"PREF_UPDATE_LOC"];
    BOOL performFetch = FALSE;
    if(lastFetched == nil){
        performFetch = TRUE;
    }
    if(!performFetch){
        NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:lastFetched];
        if(secs > 60){
            performFetch = TRUE;
        }
    }
    
    if(performFetch){
        NSDate* lastRequest = [pref objectForKey:@"PREF_LAST_LOC_REQUEST"];
        if(lastRequest){
            NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:lastRequest];
            if(secs < 30){
                performFetch = FALSE;
            } else {
                [pref setObject:[NSDate date] forKey:@"PREF_LAST_LOC_REQUEST"];
                [pref synchronize];
            }
        } else {
            [pref setObject:[NSDate date] forKey:@"PREF_LAST_LOC_REQUEST"];
            [pref synchronize];
        }
    }
    return performFetch;
}

// refresh is completed
+ (void) updateLocationComplete {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[NSDate date] forKey:@"PREF_UPDATE_LOC"];
    [pref synchronize];
}

+ (NSDate *) getDateWithTime:(NSDate *)nowDt hour:(int)hour min:(int)min second:(int)second {
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:nowDt];
    
    //set date components
    [dateComponents setHour:hour];
    [dateComponents setMinute:min];
    [dateComponents setSecond:second];
    
    //return date relative from date
    return [calendar dateFromComponents:dateComponents];
}

+ (NSDate *) getNextHour:(NSDate *)firstDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:firstDate];
    
    //set date components
    [dateComponents setHour:dateComponents.hour + 2];
    
    return [GeneralHelper getDateWithTime:[calendar dateFromComponents:dateComponents] hour:0 min:0 second:0];
}

+ (NSString *) getTodayTomorrowDate:(NSDate *)dt {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterShortStyle;
    df.doesRelativeDateFormatting = YES;  // this enables relative dates like yesterday, today, tomorrow...

    return [df stringFromDate:dt];
}


+ (UIImage *) scaleAndRotateImage:(UIImage *)image fitSize:(CGSize)fitSize
{
    int kMaxResolution = MAX(fitSize.width, fitSize.height); // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

+ (CGSize) getThumbnailImageSize:(CGSize) origSize {
    float ratio = (float) origSize.height / (float) origSize.width;
    float width = origSize.width;
    if(width > 300)
        width = 300;
    float height = ratio * width;
    
    return  CGSizeMake(width, height);
}

+ (CGSize) getMainImageSize:(CGSize) origSize {
    float ratio = (float) origSize.height / (float) origSize.width;
    float width = origSize.width;
    if(width > 800)
        width = 800;
    float height = ratio * width;
    
    return  CGSizeMake(width, height);
}

+ (NSDictionary *) getGroupChatPreferenceDictionay {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSDictionary* dict = [pref objectForKey:@"GroupChatSettings"];
    return dict;
}

+ (void) setGroupChatPreferenceDictionay:(NSMutableDictionary *)mDict {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:mDict forKey:@"GroupChatSettings"];
    
    [pref synchronize];
    
}

+ (NSDate *) getLastGroupChatVisitedDate:(NSString *)groupId {
    NSDictionary *dict = [GeneralHelper getGroupChatPreferenceDictionay];
    if(dict){
        return dict[groupId];
    } else {
        return nil;
    }
}

+ (void) setLastGroupChatVisitedDate:(NSString *)objId viewDate:(NSDate *)viewDate {
    NSMutableDictionary *attributesDict;
    NSDictionary *dict = [GeneralHelper getGroupChatPreferenceDictionay];
    if(dict){
        attributesDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    } else {
        attributesDict = [[NSMutableDictionary alloc] init];
    }
    [attributesDict setObject:viewDate forKey:objId];
    
    [GeneralHelper setGroupChatPreferenceDictionay:attributesDict];
}

+ (BOOL) checkIfNewGroupMessageToShow:(NSString *)groupId newDate:(NSDate *)newDate {
    NSDate* oldDate = [GeneralHelper getLastGroupChatVisitedDate:groupId];
    if(oldDate){
        if([oldDate earlierDate:newDate] == oldDate)
            return true;
        else
            return false;
    }
    return true;
}

@end
