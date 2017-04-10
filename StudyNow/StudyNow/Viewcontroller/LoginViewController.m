//
//  LoginViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "LoginViewController.h"
#import "GeneralHelper.h"
#import "BackendHelper.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [GeneralHelper addButtonBorder:_mBackButton];
    [GeneralHelper addButtonBorder:_mStudyNow];

    [GeneralHelper addLabelBorder:_mEmailBkgLabel];
    [GeneralHelper addLabelBorder:_mPasswordBkgLabel];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.barTintColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    UIToolbar* numberToolbar2 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar2.barStyle = UIBarStyleDefault;
    numberToolbar2.barTintColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    numberToolbar2.items = [NSArray arrayWithObjects:
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                            nil];
    [numberToolbar2 sizeToFit];

    _mEmailText.inputAccessoryView = numberToolbar;
    _mPasswordText.inputAccessoryView = numberToolbar2;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [_mEmailText resignFirstResponder];
        [_mPasswordText resignFirstResponder];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        [self goHome];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSizeOrg = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = CGSizeMake(kbSizeOrg.width, kbSizeOrg.height + 20);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _mScrollView.contentInset = contentInsets;
    _mScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.currentTextField.frame.origin) ) {
        [self.mScrollView scrollRectToVisible:self.currentTextField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _mScrollView.contentInset = contentInsets;
    _mScrollView.scrollIndicatorInsets = contentInsets;
}

-(void)nextNumberPad{
    if(self.currentTextField == self.mEmailText){
        [self.mPasswordText becomeFirstResponder];
    } else if(self.currentTextField == self.mPasswordText){
        [self.mPasswordText resignFirstResponder];
    }
}

-(void)doneWithNumberPad{
    [self dismissKeyboard];
}

- (void) dismissKeyboard {
    [self.mEmailText resignFirstResponder];
    [self.mPasswordText resignFirstResponder];
    self.mScrollView.contentOffset = CGPointMake(0, 0);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
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

- (IBAction)onTouchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTouchStudyNow:(id)sender {
    if([GeneralHelper validateIsEmpty:_mEmailText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Email is empty." tag:1 andDelegate:nil];
        return;
    }
    
    if(![GeneralHelper validateEmail:_mEmailText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Not a valid email." tag:1 andDelegate:nil];
        return;
    }
    
    if([GeneralHelper validateIsEmpty:_mPasswordText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Password is empty." tag:1 andDelegate:nil];
        return;
    }
    
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper performUserSignIn:_mEmailText.text password:_mPasswordText.text completion:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
//            [[AppDelegate sharedDelegate] refreshCurrentUser];
            [self goHome];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
        }
    }];

}

- (IBAction)onTouchForgotPwd:(id)sender {
    [self performSegueWithIdentifier:@"showForgotPwd" sender:self];

}


- (void) goHome {
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        if(currentUser.studentDetail){
            NSArray* classes = currentUser.studentDetail.classes;
            if(classes && ([classes count] > 0)){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
                UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabViewId"];
                [self.navigationController pushViewController:rootViewController animated:YES];
                return;
            }
        }
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"InputScheduleViewId"];
    [self.navigationController pushViewController:rootViewController animated:YES];
}


@end
