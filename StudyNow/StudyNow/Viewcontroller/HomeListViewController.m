//
//  HomeListViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/11/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "HomeListViewController.h"
#import "BackendHelper.h"
#import "UserListViewCell.h"
#import "BaseTabViewController.h"
#import "GroupListViewCell.h"
#import "GroupChat.h"
#import "GroupChatViewController.h"
#import "AppDelegate.h"
#import "GeneralHelper.h"

@interface HomeListViewController () {
    NSMutableArray* friendsList;
    NSMutableArray* groupList;
    NSMutableArray* myClassesList;
    int currentFilterCount;
    NSMutableArray* filterClasses;
    
    NSIndexPath* currentIndex;
}

@end

@implementation HomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view layoutIfNeeded];

    myClassesList = [[NSMutableArray alloc] init];
    friendsList = [[NSMutableArray alloc] init];
    groupList = [[NSMutableArray alloc] init];

    CGRect frame = _mFilter1ColorView.frame;
    _mFilter1ColorView.layer.cornerRadius = frame.size.height / 2.0f;
    _mFilter2ColorView.layer.cornerRadius = frame.size.height / 2.0f;
    _mFilter3ColorView.layer.cornerRadius = frame.size.height / 2.0f;
    _mFilter4ColorView.layer.cornerRadius = frame.size.height / 2.0f;
    _mFilter5ColorView.layer.cornerRadius = frame.size.height / 2.0f;
    _mFilter6ColorView.layer.cornerRadius = frame.size.height / 2.0f;
    
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *filter1Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilter1TapGesture:)];
    filter1Gesture.numberOfTapsRequired = 1;
    [self.mFilter1View addGestureRecognizer:filter1Gesture];

    UITapGestureRecognizer *filter2Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilter2TapGesture:)];
    filter2Gesture.numberOfTapsRequired = 1;
    [self.mFilter2View addGestureRecognizer:filter2Gesture];

    UITapGestureRecognizer *filter3Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilter3TapGesture:)];
    filter3Gesture.numberOfTapsRequired = 1;
    [self.mFilter3View addGestureRecognizer:filter3Gesture];

    UITapGestureRecognizer *filter4Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilter4TapGesture:)];
    filter4Gesture.numberOfTapsRequired = 1;
    [self.mFilter4View addGestureRecognizer:filter4Gesture];

    UITapGestureRecognizer *filter5Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilter5TapGesture:)];
    filter5Gesture.numberOfTapsRequired = 1;
    [self.mFilter5View addGestureRecognizer:filter5Gesture];

    UITapGestureRecognizer *filter6Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilter6TapGesture:)];
    filter6Gesture.numberOfTapsRequired = 1;
    [self.mFilter6View addGestureRecognizer:filter6Gesture];

}

- (void) showAsOverlay {
    _mCancelButton.hidden = true;
    [self initViews];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _mCancelButton.hidden = false;
    [self initViews];
}

- (void) initViews {
    [self updateClassList];
    [self fetchUsers];
    [self fetchGroups];
}

- (void)refreshData {
    [self fetchUsers];
    [self fetchGroups];
}

- (void) fetchGroups {
    [BackendHelper fetchGroupWithMatch:filterClasses completion:^(BOOL success, NSMutableArray *list, NSError *error) {
        if(success){
            [groupList removeAllObjects];
            [groupList addObjectsFromArray:list];
            [self.mTableView reloadData];
        }
    }];
}

- (void) fetchUsers {
    [BackendHelper fetchUserWithMatch:filterClasses completion:^(BOOL success, NSMutableArray *list, NSError *error) {
        if(success){
            [friendsList removeAllObjects];
            [friendsList addObjectsFromArray:list];
            [self.mTableView reloadData];
        }
    }];
}

- (void) updateClassList {
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        NSArray* classes = currentUser.studentDetail.classes;
        if(classes){
            [myClassesList removeAllObjects];
            [myClassesList addObjectsFromArray:classes];
            [self showFilters];
        }
    }
}

- (void) showFilters {
    currentFilterCount = (int)[myClassesList count];
    filterClasses = [[NSMutableArray alloc] init];
    for(MyClasses* mc in myClassesList){
        [filterClasses addObject:mc.name];
    }
    
    _mFilter1View.hidden = true;
    _mFilter2View.hidden = true;
    _mFilter3View.hidden = true;
    _mFilter4View.hidden = true;
    _mFilter5View.hidden = true;
    _mFilter6View.hidden = true;
    if(currentFilterCount > 0) {
        _mFilter1View.hidden = false;
        MyClasses* myclass = myClassesList[0];
        _mFilter1ColorView.backgroundColor = [UIColor colorWithRed:[myclass.red floatValue] green:[myclass.green floatValue] blue:[myclass.blue floatValue] alpha:1.0];
        _mFilter1Label.text = myclass.name;
    }
    if(currentFilterCount > 1) {
        _mFilter2View.hidden = false;
        MyClasses* myclass = myClassesList[1];
        _mFilter2ColorView.backgroundColor = [UIColor colorWithRed:[myclass.red floatValue] green:[myclass.green floatValue] blue:[myclass.blue floatValue] alpha:1.0];
        _mFilter2Label.text = myclass.name;
    }
    if(currentFilterCount > 2) {
        _mFilter3View.hidden = false;
        MyClasses* myclass = myClassesList[2];
        _mFilter3ColorView.backgroundColor = [UIColor colorWithRed:[myclass.red floatValue] green:[myclass.green floatValue] blue:[myclass.blue floatValue] alpha:1.0];
        _mFilter3Label.text = myclass.name;
    }
    if(currentFilterCount > 3) {
        _mFilter4View.hidden = false;
        MyClasses* myclass = myClassesList[3];
        _mFilter4ColorView.backgroundColor = [UIColor colorWithRed:[myclass.red floatValue] green:[myclass.green floatValue] blue:[myclass.blue floatValue] alpha:1.0];
        _mFilter4Label.text = myclass.name;
    }
    if(currentFilterCount > 4) {
        _mFilter5View.hidden = false;
        MyClasses* myclass = myClassesList[4];
        _mFilter5ColorView.backgroundColor = [UIColor colorWithRed:[myclass.red floatValue] green:[myclass.green floatValue] blue:[myclass.blue floatValue] alpha:1.0];
        _mFilter5Label.text = myclass.name;
    }
    if(currentFilterCount > 5) {
        _mFilter6View.hidden = false;
        MyClasses* myclass = myClassesList[5];
        _mFilter6ColorView.backgroundColor = [UIColor colorWithRed:[myclass.red floatValue] green:[myclass.green floatValue] blue:[myclass.blue floatValue] alpha:1.0];
        _mFilter6Label.text = myclass.name;
    }
}

- (void)handleFilter1TapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        MyClasses* myclass = myClassesList[0];
        if([filterClasses containsObject:myclass.name]){
            _mFilter1ChkImgView.hidden = true;
            [filterClasses removeObject:myclass.name];
        } else {
            _mFilter1ChkImgView.hidden = false;
            [filterClasses addObject:myclass.name];
        }
        [self refreshData];
    }
}

- (void)handleFilter2TapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        MyClasses* myclass = myClassesList[1];
        if([filterClasses containsObject:myclass.name]){
            _mFilter2ChkImgView.hidden = true;
            [filterClasses removeObject:myclass.name];
        } else {
            _mFilter2ChkImgView.hidden = false;
            [filterClasses addObject:myclass.name];
        }
        [self refreshData];
    }
}

- (void)handleFilter3TapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        MyClasses* myclass = myClassesList[2];
        if([filterClasses containsObject:myclass.name]){
            _mFilter3ChkImgView.hidden = true;
            [filterClasses removeObject:myclass.name];
        } else {
            _mFilter3ChkImgView.hidden = false;
            [filterClasses addObject:myclass.name];
        }
        [self refreshData];
    }
}

- (void)handleFilter4TapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        MyClasses* myclass = myClassesList[3];
        if([filterClasses containsObject:myclass.name]){
            _mFilter4ChkImgView.hidden = true;
            [filterClasses removeObject:myclass.name];
        } else {
            _mFilter4ChkImgView.hidden = false;
            [filterClasses addObject:myclass.name];
        }
        [self refreshData];
    }
}

- (void)handleFilter5TapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        MyClasses* myclass = myClassesList[4];
        if([filterClasses containsObject:myclass.name]){
            _mFilter5ChkImgView.hidden = true;
            [filterClasses removeObject:myclass.name];
        } else {
            _mFilter5ChkImgView.hidden = false;
            [filterClasses addObject:myclass.name];
        }
        [self refreshData];
    }
}

- (void)handleFilter6TapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        MyClasses* myclass = myClassesList[5];
        if([filterClasses containsObject:myclass.name]){
            _mFilter6ChkImgView.hidden = true;
            [filterClasses removeObject:myclass.name];
        } else {
            _mFilter6ChkImgView.hidden = false;
            [filterClasses addObject:myclass.name];
        }
        [self refreshData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
    
    return [friendsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        GroupChat* data = groupList[indexPath.row];
        GroupListViewCell *viewCell = (GroupListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupListViewId" forIndexPath:indexPath];
        [viewCell initViewWithData:data rowIndex:(int)indexPath.row];
        
        return viewCell;
    } else {
        UserData* userData = friendsList[indexPath.row];
        UserListViewCell *viewCell = (UserListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"mUserTableId" forIndexPath:indexPath];
        [viewCell initViewWithData:userData rowIndex:(int)indexPath.row];
        
        return viewCell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        currentIndex = indexPath;
        GroupChat* data = groupList[indexPath.row];
        if([BackendHelper isPartOfGroup:data]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
            GroupChatViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"GroupChatViewId"];
            rootViewController.groupChatData = data;
            [self.navigationController pushViewController:rootViewController animated:YES];
        } else {
            [self showGroupJoinMessage:data];
        }
    } else {
        currentIndex = indexPath;
        UserData* userData = friendsList[indexPath.row];
//    [self.delegate selectedUser:userData];
    
        BaseTabViewController* tabController = (BaseTabViewController *)self.tabBarController;
        [tabController selectedUser:userData];
    }
}

- (void) showGroupJoinMessage:(GroupChat *)data {
    int count = [data.groupSize intValue];
    NSInteger currentCount = [data.participants count];
    if(currentCount < count){
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Group Chat"
                                              message:@"You are not part of the group. Do you want to add yourself to the group?"
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        UIAlertAction *addAction = [UIAlertAction
                                       actionWithTitle:@"Add"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self addToGroupChat];
                                       }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:addAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Group Chat"
                                              message:@"Maximum participant has reached. Cannot add you to the group."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];

    }
}

- (void) addToGroupChat {
    GroupChat* data = groupList[currentIndex.row];

    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper addToGroupChat:data completionBlock:^(BOOL success, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
            GroupChatViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"GroupChatViewId"];
            rootViewController.groupChatData = data;
            [self.navigationController pushViewController:rootViewController animated:YES];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Error adding to group chat." tag:1 andDelegate:nil];
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

- (IBAction)onTouchCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTouchCreateGroup:(id)sender {
    [self performSegueWithIdentifier:@"showCreateGroup" sender:self];
}

@end
