//
//  SelectSchoolViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/19/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectSchoolViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (IBAction)onTouchCancel:(id)sender;
@end
