//
//  ProfileViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mSchoolBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mSchoolText;
@property (weak, nonatomic) IBOutlet UILabel *mPermBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mPermText;
@property (weak, nonatomic) IBOutlet UILabel *mEmailBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mEmailText;
@property (weak, nonatomic) IBOutlet UILabel *mPasswordBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordText;
@property (weak, nonatomic) IBOutlet UIButton *mSubjectsButton;
@property (weak, nonatomic) IBOutlet UIButton *mSaveButton;
@property (weak, nonatomic) IBOutlet UISwitch *mNotifySwitch;

- (IBAction)mTouchSubjects:(id)sender;
- (IBAction)mTouchSave:(id)sender;
- (IBAction)onTouchLogout:(id)sender;
- (IBAction)onTouchContact:(id)sender;
@end
