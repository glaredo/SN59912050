//
//  CreateGroupViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 10/4/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "GeneralHelper.h"
#import "UserData.h"
#import "BackendHelper.h"
#import "Schools.h"
#import "AppDelegate.h"
#import "ImageCacheHelper.h"
#import "MyAppConstants.h"


@interface CreateGroupViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImage* profileImg;
    BOOL fromPicker;
    UIPickerView *picker;
    UIDatePicker *datePicker;
    
    NSDate* timeDate;
    NSArray* noOfMemberList;
    NSMutableArray* myClassesList;
    MyClasses* currentClass;
}

@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];

    myClassesList = [[NSMutableArray alloc] init];
    noOfMemberList = @[@"4", @"6", @"8", @"10", UNLIMITED_GROUP_COUNT_STRING];
    
    [GeneralHelper roundProfileImgView:_mProfileImgView];
    
    [GeneralHelper addButtonBorder:_mCancelButton];
    [GeneralHelper addButtonBorder:_mCreateButton];
    
    [GeneralHelper addLabelBorder:_mGroupBkgLabel];
    [GeneralHelper addLabelBorder:_mSubjectBkgLabel];
    [GeneralHelper addLabelBorder:_mMemCountBkgLabel];
    [GeneralHelper addLabelBorder:_mTimeBkgLabel];
    [GeneralHelper addLabelBorder:_mLocationBkgLabel];

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
    
    picker   = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 210, 320, 216)];
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.dataSource = self;
    
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    datePicker.minimumDate = [NSDate date];
//    [datePicker setDate:[GeneralHelper getNextHour:[NSDate date]] animated:NO];
    [datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];


    _mSubjectText.inputView = picker;
    _mMemCountBkgText.inputView = picker;
    _mTimeBkgText.inputView = datePicker;

    _mGroupNameText.inputAccessoryView = numberToolbar;
    _mSubjectText.inputAccessoryView = numberToolbar;
    _mMemCountBkgText.inputAccessoryView = numberToolbar;
    _mTimeBkgText.inputAccessoryView = numberToolbar;
    _mLocationText.inputAccessoryView = numberToolbar2;
    
    [self updateClassList];
    
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
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateClassList {
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        NSArray* classes = currentUser.studentDetail.classes;
        if(classes){
            [myClassesList removeAllObjects];
            [myClassesList addObjectsFromArray:classes];
        }
    }
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
    if(self.currentTextField == _mSubjectText) {
        NSInteger index = [picker selectedRowInComponent:0];
        currentClass = myClassesList[index];
//        self.mSubjectText.text = [NSString stringWithFormat:@"%@(%@)", currentClass.name, currentClass.shortname];
        self.mSubjectText.text = currentClass.name;
    } else if(self.currentTextField == _mMemCountBkgText) {
        NSInteger index = [picker selectedRowInComponent:0];
        self.mMemCountBkgText.text = noOfMemberList[index];
    } else if(self.currentTextField == _mTimeBkgText) {
        [self datePickerChanged:datePicker];
    }

    if(self.currentTextField == self.mGroupNameText){
        [self.mSubjectText becomeFirstResponder];
    } else if(self.currentTextField == self.mSubjectText){
        [self.mMemCountBkgText becomeFirstResponder];
    } else if(self.currentTextField == self.mMemCountBkgText){
        [self.mTimeBkgText becomeFirstResponder];
    } else if(self.currentTextField == self.mTimeBkgText){
        [self.mLocationText becomeFirstResponder];
    } else if(self.currentTextField == self.mLocationText){
        [self.mLocationText resignFirstResponder];
    }
}

-(void)doneWithNumberPad{
    [self dismissKeyboard];
}

- (void) dismissKeyboard {
    [self.mGroupNameText resignFirstResponder];
    [self.mSubjectText resignFirstResponder];
    [self.mMemCountBkgText resignFirstResponder];
    [self.mTimeBkgText resignFirstResponder];
    [self.mLocationText resignFirstResponder];
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

    if((textField == _mSubjectText) || (textField == _mMemCountBkgText))
        [picker reloadAllComponents];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onTouchCreate:(id)sender {
    if([GeneralHelper validateIsEmpty:_mGroupNameText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Group Name is empty." tag:1 andDelegate:nil];
        return;
    }
    
    if([GeneralHelper validateIsEmpty:_mSubjectText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Subject is empty." tag:1 andDelegate:nil];
        return;
    }
    
    if([GeneralHelper validateIsEmpty:_mMemCountBkgText.text]){
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Please enter number of group member." tag:1 andDelegate:nil];
        return;
    }
    
    int countInt = 0;
    NSString* countString = _mMemCountBkgText.text;
    if([countString isEqualToString:UNLIMITED_GROUP_COUNT_STRING])
        countInt = UNLIMITED_GROUP_COUNT;
    else
        countInt = [countString intValue];
    
//    if([GeneralHelper validateIsEmpty:_mTimeBkgText.text]){
//        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Time is empty." tag:1 andDelegate:nil];
//        return;
//    }
    
//    if([GeneralHelper validateIsEmpty:_mLocationText.text]){
//        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Location is empty." tag:1 andDelegate:nil];
//        return;
//    }

    [BackendHelper createNewChatGroup:_mGroupNameText.text chatTime:timeDate myClass:currentClass groupSize:countInt location:_mLocationText.text groupImage:profileImg completionBlock:^(BOOL success, NSError *error) {
        if(success){
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
        }
    }];
    
}

- (IBAction)onTouchCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (void)datePickerChanged:(UIDatePicker*)dtPicker {
    timeDate = dtPicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy hh:mm a"];
    
    self.mTimeBkgText.text = [formatter stringFromDate:dtPicker.date];
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(self.currentTextField == _mSubjectText){
        return [myClassesList count];
    } else {
        return [noOfMemberList count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(self.currentTextField == _mSubjectText){
        MyClasses* myclass = myClassesList[row];
        return myclass.name;
//        return [NSString stringWithFormat:@"%@(%@)", myclass.name,myclass.shortname];
    } else {
        return noOfMemberList[row];
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(self.currentTextField == _mSubjectText){
        currentClass = myClassesList[row];
        self.mSubjectText.text = currentClass.name;
//        self.mSubjectText.text = [NSString stringWithFormat:@"%@ (%@)", currentClass.name, currentClass.shortname];
    } else {
        self.mMemCountBkgText.text = noOfMemberList[row];
    }
}

@end
