//
//  UserListViewCell.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/13/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "UserListViewCell.h"
#import "ImageCacheHelper.h"
#import "GeneralHelper.h"

@implementation UserListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];

    CGRect frame = _mProfileImgView.frame;
    _mProfileImgView.layer.cornerRadius = frame.size.height / 2.0f;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) initViewWithData:(UserData *)userdata rowIndex:(int)index {
    _mProfileImgView.image = nil;
    self.mNameLabel.text = userdata.name;
    NSArray* commonClassList = [userdata getCommonSubjectWithCurrentUser];
    self.mSubjectLabel.text = [commonClassList componentsJoinedByString:@"\n"];
    self.mDistanceLabel.text = [userdata getActiveTime];
    
    [_mSujectColorView initView:[userdata getCommonMyClassesWithCurrentUser]];
    
    UIImage* image = [[ImageCacheHelper sharedObject] getCachedImage:userdata.objectId];
    if(image){
        _mProfileImgView.image = image;
    } else {
        NSString* strUrl = [GeneralHelper checkForNull:userdata.profileImageLoc];
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
                                       [[ImageCacheHelper sharedObject] cacheTheImage:userdata.objectId image:data];
                                       _mProfileImgView.image = [UIImage imageWithData:data];
                                   } else {
                                       
                                   }
                               }];
    }
}


@end
