//
//  SignUpViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schools.h"

@interface SignUpViewController : UIViewController

@property (nonatomic, retain) Schools *currentSchool;

@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mNameBkgLabel;
@property (weak, nonatomic) IBOutlet UILabel *mSchoolBkgLabel;
@property (weak, nonatomic) IBOutlet UILabel *mPermNumBkgLabel;
@property (weak, nonatomic) IBOutlet UILabel *mEmailBkgLabel;
@property (weak, nonatomic) IBOutlet UILabel *mPasswordBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mNameText;
@property (weak, nonatomic) IBOutlet UITextField *mSchoolText;
@property (weak, nonatomic) IBOutlet UITextField *mPermNumText;
@property (weak, nonatomic) IBOutlet UITextField *mEmailText;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordText;
@property (weak, nonatomic) IBOutlet UIButton *mBackButton;
@property (weak, nonatomic) IBOutlet UIButton *mNextButton;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

- (IBAction)onTouchBack:(id)sender;
- (IBAction)onTouchNext:(id)sender;
@end
