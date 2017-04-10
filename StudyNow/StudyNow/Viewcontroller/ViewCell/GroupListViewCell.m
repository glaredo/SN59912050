//
//  GroupListViewCell.m
//  StudyNow
//
//  Created by Rajesh Mehta on 10/6/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "GroupListViewCell.h"
#import "UIImageView+Networking.h"
#import "GeneralHelper.h"
#import "MyAppConstants.h"
#import "BackendHelper.h"

@implementation GroupListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self layoutIfNeeded];

    CGRect rect = _mGroupImgView.frame;
    _mGroupImgView.layer.cornerRadius = rect.size.height / 2;
    
    CGRect dotRect = _mDotView.frame;
    _mDotView.layer.cornerRadius = dotRect.size.height / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initViewWithData:(GroupChat *)data rowIndex:(int)index {
    _mNameLabel.text = data.groupName;
//    _mTimeLabel.text = [GeneralHelper getTodayTomorrowDate:data.chatTime];
    _mTimeLabel.text = @"";
    _mLocationLabel.text = @"";
//    _mLocationLabel.text = data.location;
    int groupSize = [data.groupSize intValue];
    if(groupSize == UNLIMITED_GROUP_COUNT)
        _mNumPeopleLabel.text = [NSString stringWithFormat:@"%@ People", UNLIMITED_GROUP_COUNT_STRING];
    else
        _mNumPeopleLabel.text = [NSString stringWithFormat:@"%d People", [data.groupSize intValue]];
    _mSubjectLabel.text = data.subject;

    NSURL *url = [NSURL URLWithString:data.picture];
    [_mGroupImgView setImageURL:url withCompletionBlock:^(BOOL succes, UIImage *image, NSError *error) {
    }];

    if(data.lastChatBy) {
        if([data.lastChatBy isEqualToString:[BackendHelper getCurrentUserObjectId]]){
            _mDotView.hidden = true;
        } else {
            if([GeneralHelper checkIfNewGroupMessageToShow:data.objectId newDate:data.lastChatTime]){
                _mDotView.hidden = false;
            } else {
                _mDotView.hidden = true;
            }
        }
    } else {
        _mDotView.hidden = true;
    }
    
}

@end
