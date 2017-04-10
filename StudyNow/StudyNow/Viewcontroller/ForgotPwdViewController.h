//
//  ForgotPwdViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/29/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPwdViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *mEmailText;
@property (weak, nonatomic) IBOutlet UILabel *mEmailBkgLabel;
@property (weak, nonatomic) IBOutlet UIButton *mSubmitButton;

- (IBAction)onTouchSubmit:(id)sender;
- (IBAction)onTouchCancel:(id)sender;
@end
