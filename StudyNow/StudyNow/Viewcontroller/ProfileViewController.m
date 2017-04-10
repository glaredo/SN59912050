//
//  ProfileViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "ProfileViewController.h"
#import <MessageUI/MessageUI.h>
#import "GeneralHelper.h"
#import "UserData.h"
#import "BackendHelper.h"
#import "Schools.h"
#import "AppDelegate.h"
#import "ImageCacheHelper.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate> {
    UIImage* profileImg;
    BOOL fromPicker;
    UserData* currentUser;
}

@property (nonatomic, strong) UITextField *currentTextField;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];

    [GeneralHelper roundProfileImgView:_mProfileImgView];
    
    [GeneralHelper addButtonBorder:_mSubjectsButton];
    [GeneralHelper addButtonBorder:_mSaveButton];
    
    [GeneralHelper addLabelBorder:_mSchoolBkgLabel];
    [GeneralHelper addLabelBorder:_mPermBkgLabel];
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
    
    _mSchoolText.inputAccessoryView = numberToolbar;
    _mPermText.inputAccessoryView = numberToolbar;
    _mEmailText.inputAccessoryView = numberToolbar;
    _mPasswordText.inputAccessoryView = numberToolbar2;

    
    fromPicker = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self registerForKeyboardNotifications];

    if(!fromPicker){
        currentUser = [BackendHelper getCurrentUser];
        if(currentUser.profileImage)
            self.mProfileImgView.image = currentUser.profileImage;
        else
            self.mProfileImgView.image = [UIImage imageNamed:@"add_avtar"];
        self.mSchoolText.text = currentUser.school.name;
        self.mPermText.text =currentUser.permNumber;
        self.mEmailText.text = currentUser.email;
        self.mPasswordText.text = @"***";
        _mNotifySwitch.on = [currentUser canSendNotification];
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
    if(self.currentTextField == self.mPermText){
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
    [self.mSchoolText resignFirstResponder];
    [self.mPermText resignFirstResponder];
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
        [alertController addAction:maleAva];
        [alertController addAction:femaleAva];
        fromPicker = true;
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)imgPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    profileImg = chosenImage;
    _mProfileImgView.image = profileImg;
    [imgPicker dismissViewControllerAnimated:YES completion:^{
        fromPicker = false;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)mTouchSubjects:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"InputScheduleViewId"];
    [self.navigationController pushViewController:rootViewController animated:YES];
}

- (IBAction)mTouchSave:(id)sender {
    BOOL isProfileChanged = false;
    BOOL isPasswordChanged = false;
    if(profileImg) {
        currentUser.profileImage = profileImg;
        isProfileChanged = true;
    }
        
//    currentUser.permNumber = self.mPermText.text;
    currentUser.permNumber = @"";
    currentUser.email = self.mEmailText.text;
    NSString* pwd = self.mPasswordText.text;
    pwd = [pwd stringByTrimmingWhitespace];
    if(![pwd isEqualToString:@"***"] && ![pwd isEqualToString:@""]) {
        currentUser.password = pwd;
        isPasswordChanged = true;
    }
    
    currentUser.sendNotification = [NSNumber numberWithBool:_mNotifySwitch.on];
    
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper updateUser:currentUser isProfileImgChanged:isProfileChanged isPasswordChanged:isPasswordChanged completion:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
            [[ImageCacheHelper sharedObject] cacheTheImage:currentUser.objectId image:UIImageJPEGRepresentation(profileImg, 0.9)];
            [GeneralHelper ShowMessageBoxWithTitle:@"Success" Body:@"Profile updated successfully." tag:-1 andDelegate:nil];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
        }
        
    }];

}

- (IBAction)onTouchLogout:(id)sender {
    [BackendHelper doLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onTouchContact:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Contact Us"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    UIAlertAction *phoneAction = [UIAlertAction
                                   actionWithTitle:@"Phone"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self phoneContactAction];
                                   }];
    
    UIAlertAction *emailAction = [UIAlertAction
                                actionWithTitle:@"Email"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action)
                                {
                                    [self emailContactAction];
                                }];
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:phoneAction];
    [alertController addAction:emailAction];
    fromPicker = true;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) phoneContactAction {
    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"3102705100"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void) emailContactAction {
    NSString *emailTitle = @"StudyNow";
    NSString *messageBody = @"";
    NSArray *toRecipents = [NSArray arrayWithObject:@"Studynow8@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setToRecipients:toRecipents];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
