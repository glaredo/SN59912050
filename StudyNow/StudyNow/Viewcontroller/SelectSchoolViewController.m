//
//  SelectSchoolViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/19/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "SelectSchoolViewController.h"
#import "SignUpViewController.h"
#import "GeneralHelper.h"
#import "BackendHelper.h"
#import "Schools.h"

@interface SelectSchoolViewController () {
    NSMutableArray* schoolList;

    NSIndexPath *currentIndex;
}

@end

@implementation SelectSchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    schoolList = [[NSMutableArray alloc] init];

    [self fetchSchools];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) fetchSchools {
    [BackendHelper fetchSchools:^(BOOL success, NSMutableArray *list, NSError *error) {
        if(success){
            [schoolList removeAllObjects];
            [schoolList addObjectsFromArray:list];
            [_mTableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [schoolList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Schools *data = schoolList[indexPath.row];
    UITableViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:@"mStoreCellView" forIndexPath:indexPath];
    
    UILabel* label = (UILabel *)[viewCell viewWithTag:1];
    label.text = data.name;
    
    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath;
    [self performSegueWithIdentifier:@"showSignUp" sender:self];
}

- (IBAction)onTouchCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSignUp"]) {
        Schools *data = schoolList[currentIndex.row];

        SignUpViewController* viewController = (SignUpViewController *)segue.destinationViewController;
        viewController.currentSchool = data;
    }
}

@end
