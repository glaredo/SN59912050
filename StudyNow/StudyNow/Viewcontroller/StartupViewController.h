//
//  StartupViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *mLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *mSignUpButton;

- (IBAction)onTouchSignUp:(id)sender;
- (IBAction)onTouchLogin:(id)sender;
@end
