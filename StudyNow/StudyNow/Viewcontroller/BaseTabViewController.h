//
//  BaseTabViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/11/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface BaseTabViewController : UITabBarController

- (void)selectedUser:(UserData *)data;

@end
