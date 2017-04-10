//
//  MessageListViewCell.m
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import "MessageListViewCell.h"
#import "BackendHelper.h"

@implementation MessageListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];

    CGRect rect = _mProfileImageView.frame;
    _mProfileImageView.layer.cornerRadius = rect.size.height / 2;
    
    CGRect dotRect = _mDotView.frame;
    _mDotView.layer.cornerRadius = dotRect.size.height / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initViewWithData:(LastChat *)chatData rowIndex:(int)index {
    UserData* data = [chatData getFriendObject];
    _mNameLabel.text = data.name;
    if(!chatData.text) {
        _mMessageLabel.text = @"Image Sent";
    } else {
        if([chatData.text isEqualToString:@""]){
            _mMessageLabel.text = @"Image Sent";
        } else {
            _mMessageLabel.text = chatData.text;
        }
    }
    _mMessageTimeLabel.text = [chatData getMessageTime];
    [data fetchProfileImage:_mProfileImageView];
    
    NSString* userID = [BackendHelper getCurrentUserObjectId];
    
    if(chatData.lastchat){
        if([chatData.lastchat.recipientId isEqualToString:userID]){
            if([chatData.lastchat.msgRead boolValue]){
                _mDotView.hidden = true;
            } else {
                _mDotView.hidden = false;
            }
        } else {
            _mDotView.hidden = true;
        }
    } else {
        _mDotView.hidden = true;
    }
}


@end
