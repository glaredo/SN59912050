//
//  GroupListViewCell.h
//  StudyNow
//
//  Created by Rajesh Mehta on 10/6/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChat.h"

@interface GroupListViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mNumPeopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mSubjectLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mGroupImgView;
@property (weak, nonatomic) IBOutlet UIView *mDotView;

- (void) initViewWithData:(GroupChat *)data rowIndex:(int)index;

@end
