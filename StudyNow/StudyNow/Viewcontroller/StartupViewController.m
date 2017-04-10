//
//  StartupViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 4/17/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "StartupViewController.h"
#import "GeneralHelper.h"
#import "BackendHelper.h"

@interface StartupViewController ()

@end

@implementation StartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GeneralHelper addButtonBorder:_mLoginButton];
    [GeneralHelper addButtonBorder:_mSignUpButton];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UserData* currentUser = [BackendHelper getCurrentUser];
    if(currentUser){
        [self goHome];
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

- (IBAction)onTouchSignUp:(id)sender {
    [BackendHelper doLogout];
    [self performSegueWithIdentifier:@"showSignUp" sender:self];
    
}

- (IBAction)onTouchLogin:(id)sender {
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void) goHomeOld {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Study" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"HomeTabViewId"];
    [self.navigationController pushViewController:rootViewController animated:YES];
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
