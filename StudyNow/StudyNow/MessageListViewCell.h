//
//  MessageListViewCell.h
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LastChat.h"

@interface MessageListViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *mMessageTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *mDotView;

- (void) initViewWithData:(LastChat *)chatData rowIndex:(int)index;

@end
