//
//  InputScheduleViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/18/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "InputScheduleViewController.h"
#import "BackendHelper.h"
#import "GeneralHelper.h"
#import "InputScheduleViewCell.h"
#import "ShowClassesViewController.h"
#import "MyClasses.h"
#import "AppDelegate.h"

@interface InputScheduleViewController () <ShowClassesViewDeleage> {
    NSMutableArray* myClassesList;
    int index;
    NSIndexPath* currentIndex;
}

@end

@implementation InputScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myClassesList = [[NSMutableArray alloc] init];
    
    [self updateClassList];
}

- (void) updateClassList {
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        NSArray* classes = currentUser.studentDetail.classes;
        if(classes){
            [myClassesList removeAllObjects];
            [myClassesList addObjectsFromArray:classes];
            [self.mTableView reloadData];
        }
    }
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

- (IBAction)onTouchLogout:(id)sender {
//    showSelectClass
    [BackendHelper doLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onTouchCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([myClassesList count] < 6)
        return [myClassesList count] + 1;
    
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InputScheduleViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"InputScheduleViewCellId" forIndexPath:indexPath];
    if(indexPath.row < [myClassesList count]) {
        MyClasses* myclass = myClassesList[indexPath.row];
        [messageCell initViewWithData:myclass rowIndex:(int)indexPath.row];
        [messageCell setOnTouchDelete:^(int rowIndex) {
            [self deleteSubject:rowIndex];
        }];
    } else {
        [messageCell initViewWithData:nil rowIndex:(int)indexPath.row];
    }
    return messageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath;
    index = (int)indexPath.row;
    [self performSegueWithIdentifier:@"showSelectClass" sender:self];
}


- (void) deleteSubject:(int) rowIndex {
    NSLog(@"delete %d", rowIndex);
    if(rowIndex < [myClassesList count]) {
        MyClasses* myclass = myClassesList[rowIndex];
        UserData* currentUser = [BackendHelper getCurrentUser];
        if(currentUser){
            [currentUser.studentDetail removeMyClass:myclass];
        }
        [[AppDelegate sharedDelegate] showFetchAlert];
        [BackendHelper deleteMySubject:myclass completion:^(BOOL success, NSError *error) {
            [[AppDelegate sharedDelegate] dissmissFetchAlert];
            if(success){
                [self updateClassList];
            } else {
                [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
            }
        }];
    }
}

- (void)selectedSubject:(NSString *)subject shortname:(NSString *)shortname red:(float)red green:(float)green blue:(float)blue viewController:(UIViewController *)controller {
    if(index < [myClassesList count]) {
        MyClasses* myclass = myClassesList[index];
        [myclass updateMyClasse:subject shortname:shortname red:red green:green blue:blue];
        [[AppDelegate sharedDelegate] showFetchAlert];
        [BackendHelper updateMySubject:myclass completion:^(BOOL success, NSError *error) {
            [[AppDelegate sharedDelegate] dissmissFetchAlert];
            if(success){
                [self updateClassList];
            } else {
                [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
            }
        }];
//        [self.mTableView reloadData];
    } else {
        [[AppDelegate sharedDelegate] showFetchAlert];
        [BackendHelper addMySubject:subject shortname:shortname red:red green:green blue:blue completion:^(BOOL success, NSError *error) {
            [[AppDelegate sharedDelegate] dissmissFetchAlert];
            if(success){
                [self updateClassList];
            } else {
                [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];
            }
        }];
//        MyClasses* myClass = [MyClasses createMyClasse:subject red:red green:green blue:blue];
//        [myClassesList addObject:myClass];
    }
    [controller.navigationController popViewControllerAnimated:YES];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSelectClass"]) {
        ShowClassesViewController* viewcontroller = segue.destinationViewController;
        viewcontroller.index = (index + 1);
        viewcontroller.delegate = self;
    }
    
}

@end
