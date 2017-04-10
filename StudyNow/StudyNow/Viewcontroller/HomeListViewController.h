//
//  HomeListViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/11/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@protocol UserListDelegate <NSObject>
- (void)selectedUser:(UserData *)data ;
@end

@interface HomeListViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *mCancelButton;

@property (weak, nonatomic) IBOutlet UIView *mFilter1View;
@property (weak, nonatomic) IBOutlet UIView *mFilter1ColorView;
@property (weak, nonatomic) IBOutlet UILabel *mFilter1Label;
@property (weak, nonatomic) IBOutlet UIImageView *mFilter1ChkImgView;

@property (weak, nonatomic) IBOutlet UIView *mFilter2View;
@property (weak, nonatomic) IBOutlet UIView *mFilter2ColorView;
@property (weak, nonatomic) IBOutlet UILabel *mFilter2Label;
@property (weak, nonatomic) IBOutlet UIImageView *mFilter2ChkImgView;

@property (weak, nonatomic) IBOutlet UIView *mFilter3View;
@property (weak, nonatomic) IBOutlet UIView *mFilter3ColorView;
@property (weak, nonatomic) IBOutlet UILabel *mFilter3Label;
@property (weak, nonatomic) IBOutlet UIImageView *mFilter3ChkImgView;

@property (weak, nonatomic) IBOutlet UIView *mFilter4View;
@property (weak, nonatomic) IBOutlet UIView *mFilter4ColorView;
@property (weak, nonatomic) IBOutlet UILabel *mFilter4Label;
@property (weak, nonatomic) IBOutlet UIImageView *mFilter4ChkImgView;

@property (weak, nonatomic) IBOutlet UIView *mFilter5View;
@property (weak, nonatomic) IBOutlet UIView *mFilter5ColorView;
@property (weak, nonatomic) IBOutlet UILabel *mFilter5Label;
@property (weak, nonatomic) IBOutlet UIImageView *mFilter5ChkImgView;

@property (weak, nonatomic) IBOutlet UIView *mFilter6View;
@property (weak, nonatomic) IBOutlet UIView *mFilter6ColorView;
@property (weak, nonatomic) IBOutlet UILabel *mFilter6Label;
@property (weak, nonatomic) IBOutlet UIImageView *mFilter6ChkImgView;

@property (nonatomic, weak) id <UserListDelegate> delegate;

- (void) showAsOverlay;

- (IBAction)onTouchCancel:(id)sender;
- (IBAction)onTouchCreateGroup:(id)sender;
@end
