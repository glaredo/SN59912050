//
//  SignUpViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "SignUpViewController.h"
#import "GeneralHelper.h"
#import "UserData.h"
#import "BackendHelper.h"
#import "Schools.h"
#import "AppDelegate.h"

@interface SignUpViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImage* profileImg;
}

@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];

    [GeneralHelper roundProfileImgView:_mProfileImgView];
    
    [GeneralHelper addButtonBorder:_mBackButton];
    [GeneralHelper addButtonBorder:_mNextButton];
    
    [GeneralHelper addLabelBorder:_mNameBkgLabel];
    [GeneralHelper addLabelBorder:_mSchoolBkgLabel];
    [GeneralHelper addLabelBorder:_mPermNumBkgLabel];
    [GeneralHelper addLabelBorder:_mEmailBkgLabel];
    [GeneralHelper addLabelBorder:_mPasswordBkgLabel];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];

    UITapGestureRecognizer *tapImgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImgTapGesture:)];
    tapImgGesture.numberOfTapsRequired = 1;
    [self.mProfileImgView addGestureRecognizer:tapImgGesture];

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
    
    _mNameText.inputAccessoryView = numberToolbar;
    _mSchoolText.inputAccessoryView = numberToolbar;
    _mPermNumText.inputAccessoryView = numberToolbar;
    _mEmailText.inputAccessoryView = numberToolbar;
    _mPasswordText.inputAccessoryView = numberToolbar2;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    _mSchoolText.text = _currentSchool.name;
    
    [self registerForKeyboardNotifications];
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
    if(self.currentTextField == self.mNameText){
//        [self.mSchoolText becomeFirstResponder];
//    } else if(self.currentTextField == self.mSchoolText){
        [self.mPermNumText becomeFirstResponder];
    } else if(self.currentTextField == self.mPermNumText){
        [self.mEmailText becomeFirstResponder];
    } else if(self.currentTextField == self.mEmailText){
        [self.mPasswordText becomeFirstResponder];
    } else if(self.currentTextField == self.mPasswordText){
        [self.mPasswordText resignFirstResponder];
    }
}

-(void)doneWithNumberPad{
    [self dismissKeyboard];
}

- (void) dismissKeyboard {
    [self.mNameText resignFirstResponder];
    [self.mSchoolText resignFirstResponder];
    [self.mPermNumText resignFirstResponder];
    [self.mEmailText resignFirstResponder];
    [self.mPasswordText resignFirstResponder];
    self.mScrollView.contentOffset = CGPointMake(0, 0);
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self dismissKeyboard];
    }
}

- (void)handleImgTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Profile Picture"
                                              message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        UIAlertAction *cameraAction = [UIAlertAction
                                       actionWithTitle:@"Take a picture"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                                           imgPicker.delegate = self;
                                           imgPicker.allowsEditing = NO;
                                           imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                           [self presentViewController:imgPicker animated:YES completion:NULL];
                                       }];
        
        UIAlertAction *libAction = [UIAlertAction
                                    actionWithTitle:@"Choose a photo from library"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                                        imgPicker.delegate = self;
                                        imgPicker.allowsEditing = NO;
                                        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        [self presentViewController:imgPicker animated:YES completion:NULL];
                                    }];

        UIAlertAction *maleAva = [UIAlertAction
                                    actionWithTitle:@"Choose Male Avatar"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        profileImg = [UIImage imageNamed:@"male_avatar"];
                                        _mProfileImgView.image = profileImg;
                                    }];

        UIAlertAction *femaleAva = [UIAlertAction
                                    actionWithTitle:@"Choose Female Avatar"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        profileImg = [UIImage imageNamed:@"female_avatar"];
                                        _mProfileImgView.image = profileImg;
                                    }];

        [alertController addAction:cancelAction];
        [alertController addAction:cameraAction];
        [alertController addAction:libAction];
//        [alertController addAction:maleAva];
//        [alertController addAction:femaleAva];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)imgPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    profileImg = chosenImage;
    _mProfileImgView.image = profileImg;
    [imgPicker dismissViewControllerAnimated:YES completion:^{
    }];
    //    self.mImageView.image = chosenImage;
    //    isImageChanged = true;
    //    [imgPicker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imgPicker {
    
    [imgPicker dismissViewControllerAnimated:YES completion:NULL];
    
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

- (IBAction)onTouchNext:(id)sender {
//    if(profileImg == nil){
//        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Please add profile image." tag:1 andDelegate:nil];
//        return;
//    }

    if([GeneralHelper validateIsEmpty:_mNameText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Name is empty." tag:1 andDelegate:nil];
        return;
    }

    if([GeneralHelper validateIsEmpty:_mSchoolText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"School is empty." tag:1 andDelegate:nil];
        return;
    }

//    if([GeneralHelper validateIsEmpty:_mPermNumText.text]){
//        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Perm Number is empty." tag:1 andDelegate:nil];
//        return;
//    }

    if([GeneralHelper validateIsEmpty:_mEmailText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Email is empty." tag:1 andDelegate:nil];
        return;
    }
    
    if(![GeneralHelper validateEmail:_mEmailText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Not a valid Email" tag:1 andDelegate:nil];
        return;
    }
    
    if([GeneralHelper validateIsEmpty:_mPasswordText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Password is empty." tag:1 andDelegate:nil];
        return;
    }
    
//    [BackendHelper checkIFEmailValid:[_mSchoolEmailText.text lowercaseString] schoolId:_currentSchool.objectId completion:^(BOOL success, BOOL result, NSError *error) {
//        if(result){
            [self saveUserData];
//        } else {
//            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:@"School Email incorrect. Please re-enter and try again." tag:-1 andDelegate:nil];
//        }
        
//    }];
}

- (void) saveUserData {
    UserData* data = [[UserData alloc] init];
    data.email = [_mEmailText.text lowercaseString];
    data.name = _mNameText.text;
    data.password = _mPasswordText.text;
    data.permNumber = @"";
//    data.permNumber = _mPermNumText.text;
    data.schoolname = _mSchoolText.text;
    data.profileImage = profileImg;
    data.school = _currentSchool;
    
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper createUser:data completion:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
            //                [BackendHelper doLogout];
            [BackendHelper performUserSignIn:data.email password:data.password completion:^(BOOL success, NSError *error) {
                if(success){
                    [GeneralHelper ShowMessageBoxWithTitle:@"Success" Body:@"Account created successfully." tag:100 andDelegate:self];
                    //            [self performSegueWithIdentifier:@"showHome" sender:self];
                } else {
                    [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
                }
            }];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.description tag:-1 andDelegate:nil];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 100){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
        UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"InputScheduleViewId"];
        [self.navigationController pushViewController:rootViewController animated:YES];
    }
}

@end
