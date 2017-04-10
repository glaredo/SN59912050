//
//  ForgotPwdViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/29/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import "GeneralHelper.h"
#import "BackendHelper.h"

@interface ForgotPwdViewController ()

@end

@implementation ForgotPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [GeneralHelper addButtonBorder:_mSubmitButton];

    [GeneralHelper addLabelBorder:_mEmailBkgLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTouchSubmit:(id)sender {
    if([GeneralHelper validateIsEmpty:_mEmailText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Email is empty." tag:1 andDelegate:nil];
        return;
    }
    
    if(![GeneralHelper validateEmail:_mEmailText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Not a valid Email" tag:1 andDelegate:nil];
        return;
    }
    
    [BackendHelper forgotPassword:[_mEmailText.text lowercaseString] completion:^(BOOL success, NSError *error) {
        if(success){
            [GeneralHelper ShowMessageBoxWithTitle:@"Success" Body:@"New password sent. Please check your email." tag:100 andDelegate:self];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.description tag:-1 andDelegate:nil];
        }
    }];
}

- (IBAction)onTouchCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 100){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
