//
//  InputScheduleViewCell.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/10/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyClasses.h"

@interface InputScheduleViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mClassText;
@property (weak, nonatomic) IBOutlet UIView *mColorView;
@property (weak, nonatomic) IBOutlet UIButton *mDeleteButton;

@property (nonatomic, assign) int indexRow;

@property (nonatomic, copy) void(^onTouchDelete)(int rowIndex);

- (void) initViewWithData:(MyClasses *)data rowIndex:(int)index;


- (IBAction)onTouchDelete:(id)sender;
@end
