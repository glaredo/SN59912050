//
//  ChatFriendViewCell.h
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatData.h"

@interface ChatFriendViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mMessageBkgLabel;
@property (weak, nonatomic) IBOutlet UITextView *mMessageText;
@property (weak, nonatomic) IBOutlet UILabel *mDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mMsgReadLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mMsgReadLabelConstant;
@property (weak, nonatomic) IBOutlet UIImageView *mMsgImgView;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;


@property (nonatomic, retain) NSString *imageUrl;

@property (nonatomic, copy) void(^onTouchShowImage)(NSString* imageUrl);

- (void) initViewWithData:(ChatData *)chatData rowIndex:(int)index;

@end
