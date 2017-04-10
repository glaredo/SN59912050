//
//  CreateGroupViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 10/4/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGroupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mGroupBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mGroupNameText;
@property (weak, nonatomic) IBOutlet UILabel *mSubjectBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mSubjectText;
@property (weak, nonatomic) IBOutlet UILabel *mMemCountBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mMemCountBkgText;
@property (weak, nonatomic) IBOutlet UILabel *mTimeBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mTimeBkgText;
@property (weak, nonatomic) IBOutlet UILabel *mLocationBkgLabel;
@property (weak, nonatomic) IBOutlet UITextField *mLocationText;
@property (weak, nonatomic) IBOutlet UIButton *mCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *mCreateButton;

- (IBAction)onTouchCreate:(id)sender;
- (IBAction)onTouchCancel:(id)sender;
@end
