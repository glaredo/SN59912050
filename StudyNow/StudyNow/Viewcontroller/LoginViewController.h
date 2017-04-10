//
//  LoginViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UILabel *mEmailBkgLabel;
@property (weak, nonatomic) IBOutlet UILabel *mPasswordBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mEmailText;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordText;
@property (weak, nonatomic) IBOutlet UIButton *mBackButton;
@property (weak, nonatomic) IBOutlet UIButton *mStudyNow;


- (IBAction)onTouchBack:(id)sender;
- (IBAction)onTouchStudyNow:(id)sender;
- (IBAction)onTouchForgotPwd:(id)sender;

@end
