//
//  ChatsViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface ChatsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (void) showSearchView;
- (void) hideSearchView;

- (void)selectedUser:(UserData *)data;

- (IBAction)onTouchSearch:(id)sender;
@end
