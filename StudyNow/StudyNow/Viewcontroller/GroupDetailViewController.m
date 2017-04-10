//
//  GroupDetailViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 12/23/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "GeneralHelper.h"
#import "Backendless.h"
#import "MyAppConstants.h"
#import "AppDelegate.h"
#import "BackendHelper.h"


@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mNameLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNameTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.mNameLabel addGestureRecognizer:singleTapGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([self.groupChatData isOwnerOfGroup])
        [_mDeleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    else
        [_mDeleteButton setTitle:@"Report" forState:UIControlStateNormal];

    _mNameLabel.text = self.groupChatData.groupName;
    _mTimeLabel.text = [GeneralHelper getTodayTomorrowDate:self.groupChatData.chatTime];
    _mLocationLabel.text = self.groupChatData.location;
    _mSubjectLabel.text = self.groupChatData.subject;

    if([self.groupChatData isPartOfGroup]){
        self.mLeaveGroupButton.hidden = false;
    } else {
        self.mLeaveGroupButton.hidden = true;
    }
    
    [_mTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNameTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"LongPress Gesture on Button");
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self showChangeGroupNameAlert];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            break;
        }
        default:
        {
            NSLog(@"LongPress-Default Gesture on Button");
        }
            break;
    }
}

- (void) showChangeGroupNameAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change group name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Group Name";
        textField.text = self.groupChatData.groupName;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self updateGroupName:[[alertController textFields][0] text]];
        //compare the current password and do action here
        
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) updateGroupName:(NSString *)groupName {
    NSLog(@"New name: %@", groupName);

    [BackendHelper updateGroupChatName:self.groupChatData newName:groupName completionBlock:^(BOOL success, NSError *error) {
        if(!error){
            self.groupChatData.groupName = groupName;
            _mNameLabel.text = self.groupChatData.groupName;
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groupChatData.participants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BackendlessUser  *user = self.groupChatData.participants[indexPath.row];
        UITableViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantCell" forIndexPath:indexPath];
    UILabel* nameLabel = (UILabel *)[messageCell viewWithTag:1];
    nameLabel.text = [user getProperty:PROPERTY_NAME];
        return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0f;
}


- (IBAction)onTouchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTouchDelete:(id)sender {
    if([self.groupChatData isOwnerOfGroup]) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Confirmation"
                                              message:@"Are you sure you want to delete group chat?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        UIAlertAction *deleteAction = [UIAlertAction
                                       actionWithTitle:@"Delete"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self deleteGroupChat];
                                       }];
        
        
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        [self onTouchReport];
    }
}

- (IBAction)onTouchLeaveGroup:(id)sender {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Confirmation"
                                              message:@"Are you sure you want to leave this group?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        UIAlertAction *deleteAction = [UIAlertAction
                                       actionWithTitle:@"Leave"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self leaveGroupChat];
                                       }];
        
        
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)onTouchReport {
    NSString *subject = @"StudyNow: A group chat is being reported";
    NSString *body = [NSString stringWithFormat:@"<b>%@(id:%@)</b> wants to report a group chat <b>%@(id: %@)</b>", [BackendHelper getCurrentUser].name, [BackendHelper getCurrentUser].objectId, _groupChatData.groupName , [BackendHelper getCurrentUser].objectId];
    [BackendHelper sendEmail:subject body:body completionBlock:^(BOOL success, NSError *error) {
        if(success){
            [GeneralHelper ShowMessageBoxWithTitle:@"Success" Body:@"Thanks for reporting a group chat. We will follow up on your request." tag:-1 andDelegate:nil];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
        }
    }];
}

- (void) leaveGroupChat {
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper removeFromGroupChat:self.groupChatData completionBlock:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Error leaving the group chat." tag:-1 andDelegate:nil];
        }
    }];
}

- (void) deleteGroupChat {
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper deleteGroupChat:self.groupChatData completionBlock:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Error deleting the group chat." tag:-1 andDelegate:nil];
        }
    }];
}

@end
