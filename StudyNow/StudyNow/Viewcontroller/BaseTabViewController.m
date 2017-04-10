//
//  BaseTabViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/11/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "BaseTabViewController.h"
#import "ChatsViewController.h"

@interface BaseTabViewController () <UITabBarControllerDelegate> {
    BOOL firstLoad;
}

@end

@implementation BaseTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    firstLoad = true;
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"Tab viewWillAppear");
    
//    if(firstLoad){
//        firstLoad = false;
//        if(self.selectedIndex == 0){
//            ChatsViewController* controller = (ChatsViewController *)self.selectedViewController;
//            [controller showSearchView];
//        }
//    }
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    if(self.selectedIndex == 0){
//        ChatsViewController* controller = (ChatsViewController *)viewController;
//        [controller hideSearchView];
//    }
}

- (void)selectedUser:(UserData *)data {
    ChatsViewController* controller = (ChatsViewController *)[self.viewControllers objectAtIndex:1];
    [controller selectedUser:data];
//    [self setSelectedIndex:1];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
