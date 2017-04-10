//
//  ChatViewController.h
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextView.h"
#import "UserData.h"
#import "GroupChat.h"

@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, CustomTextViewDelegate>
@property (nonatomic, strong) UserData *profileSummary;
@property (nonatomic, assign) BOOL canShowMessage;

@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mTimeInfoLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet CustomTextView *mChatText;
@property (weak, nonatomic) IBOutlet UIButton *mSendButton;
@property (weak, nonatomic) IBOutlet UIView *mBottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mBottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mBottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *mCameraButton;



- (IBAction)onTouchBack:(id)sender;
//- (IBAction)onTouchInfo:(id)sender;
- (IBAction)onTouchSend:(id)sender;
//- (IBAction)onTouchProfileIconName:(id)sender;
//- (IBAction)onTouchSelfProfile:(id)sender;
- (IBAction)onTouchReport:(id)sender;
- (IBAction)onTouchCamera:(id)sender;


@end
