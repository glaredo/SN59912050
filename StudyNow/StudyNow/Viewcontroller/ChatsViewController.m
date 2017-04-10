//
//  ChatsViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "ChatsViewController.h"
#import "HomeListViewController.h"
#import "AppDelegate.h"
#import "BackendHelper.h"
#import "LastChat.h"
#import "MessageListViewCell.h"
#import "MyAppConstants.h"
#import "ChatViewController.h"
#import "GroupListViewCell.h"
#import "GroupChatViewController.h"

@interface ChatsViewController () <UserListDelegate> {
    HomeListViewController *searchListViewController;
    NSMutableArray* messageList;
    NSMutableArray* groupList;
    NSMutableArray* filterClasses;
    UserData* selectedUserData;
}

@end

@implementation ChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    messageList = [[NSMutableArray alloc] init];
    groupList = [[NSMutableArray alloc] init];
    filterClasses = [[NSMutableArray alloc] init];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:kDidReceivedChatNotification object:nil];

    [self updateClassList];
    [self getMessageList];
    [self fetchGroups];
}

- (void)messageReceived:(NSNotification *)note {
    [self getMessageList];
    [self fetchGroups];
}

- (void) getMessageList {
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper getInboxMessageList:^(BOOL success, NSArray *friendList, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(!error) {
            [messageList removeAllObjects];
            [messageList addObjectsFromArray:friendList];
            [self refreshList];
        }
    }];
}

- (void) fetchGroups {
    [BackendHelper fetchGroupWithMatch:filterClasses completion:^(BOOL success, NSMutableArray *list, NSError *error) {
        if(success){
            [groupList removeAllObjects];
            for(GroupChat* data in list){
                if([BackendHelper isPartOfGroup:data]){
                    [groupList addObject:data];
                }
            }
            [self refreshList];
        }
    }];
}

- (void) updateClassList {
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        NSArray* classes = currentUser.studentDetail.classes;
        if(classes){
            for(MyClasses* mc in classes){
                [filterClasses addObject:mc.name];
            }
        }
    }
}

- (void) refreshList {
    [self.mTableView reloadData];
}

#pragma mark - UITableViewDelegate-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"mHeaderTableId";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel* headingLabel = (UILabel *)[headerView viewWithTag:1];
    if(section == 0) {
        headingLabel.text = @"Groups";
    } else {
        headingLabel.text = @"Individuals";
    }
    return headerView.contentView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return [groupList count];

    return [messageList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        return 80.0;

    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        GroupChat* data = groupList[indexPath.row];
        GroupListViewCell *viewCell = (GroupListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupListViewId" forIndexPath:indexPath];
        [viewCell initViewWithData:data rowIndex:(int)indexPath.row];
        
        return viewCell;
    } else {
        MessageListViewCell *cell =  (MessageListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageListViewId" forIndexPath:indexPath];
    
        UIImageView *indicator;
        indicator = (UIImageView *)[cell.contentView viewWithTag:100];
    
        LastChat* data = messageList[indexPath.row];
        [cell initViewWithData:data rowIndex:(int)indexPath.row];
    
    
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        GroupChat* data = groupList[indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
        GroupChatViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"GroupChatViewId"];
        rootViewController.groupChatData = data;
        [self.navigationController pushViewController:rootViewController animated:YES];
    } else {
        LastChat* data = messageList[indexPath.row];
        selectedUserData = [data getFriendObject];
        [self performSegueWithIdentifier:@"showChat" sender:self];
    }
/*    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Helper" bundle:nil];
    ChatViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewControllerId"];
    rootViewController.profileSummary = [data getFriendObject];
    [self.navigationController pushViewController:rootViewController animated:YES]; */
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LastChat* data = messageList[indexPath.row];
        
        [self performDeleteMessage:data];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void) performDeleteMessage:(LastChat *)chatMessageData {
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper deleteMessages:chatMessageData completion:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        [self getMessageList];
    }];
    
    /*    PFUser* user = [PFUser currentUser];
     
     if(chatMessageData.parseObject) {
     [ParseHelper deleteMessages:chatMessageData completion:^(BOOL success, NSError *error) {
     if(success){
     [self getMessageList];
     }
     }];
     } */
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) showSearchView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
    searchListViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeListViewId"];
    searchListViewController.delegate = self;
    searchListViewController.view.frame = self.view.frame;
    searchListViewController.view.alpha = 0;
    [self.view addSubview:searchListViewController.view];
    [UIView animateWithDuration:0.2 animations:^{
        searchListViewController.view.alpha = 1;
    } ];
    [searchListViewController showAsOverlay];
}

- (void) hideSearchView {
    if(searchListViewController){
        [UIView animateWithDuration:0.3 animations:^{
            searchListViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [searchListViewController.view removeFromSuperview];
        } ];
        searchListViewController = nil;
    }
}

#pragma mark - UserListDelegate
- (void)selectedUser:(UserData *)data {
    selectedUserData = data;
    [self hideSearchView];
    [self performSegueWithIdentifier:@"showChat" sender:self];
}


- (IBAction)onTouchSearch:(id)sender {
    [self showSearchView];
//    [self performSegueWithIdentifier:@"showSearch" sender:self];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showChat"]) {
        ChatViewController* viewController = (ChatViewController *)segue.destinationViewController;
        viewController.profileSummary = selectedUserData;
        viewController.canShowMessage = false;
    }
}

@end
