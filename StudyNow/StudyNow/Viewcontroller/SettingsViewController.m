//
//  SettingsViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/13/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "SettingsViewController.h"
#import "BackendHelper.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [BackendHelper doLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
