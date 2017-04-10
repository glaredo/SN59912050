//
//  InputScheduleViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/18/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputScheduleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (IBAction)onTouchLogout:(id)sender;
- (IBAction)onTouchCancel:(id)sender;
@end
