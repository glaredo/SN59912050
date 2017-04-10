//
//  GroupDetailViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 12/23/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChat.h"

@interface GroupDetailViewController : UIViewController

@property (nonatomic, strong) GroupChat *groupChatData;

@property (weak, nonatomic) IBOutlet UILabel *mSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *mTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *mDeleteButton;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *mLeaveGroupButton;

- (IBAction)onTouchBack:(id)sender;
- (IBAction)onTouchDelete:(id)sender;
- (IBAction)onTouchLeaveGroup:(id)sender;
@end
