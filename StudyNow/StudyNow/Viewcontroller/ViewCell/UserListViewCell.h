//
//  UserListViewCell.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/13/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "SubjectColorView.h"

@interface UserListViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *mDistanceLabel;
@property (weak, nonatomic) IBOutlet SubjectColorView *mSujectColorView;

- (void) initViewWithData:(UserData *)data rowIndex:(int)index;

@end
