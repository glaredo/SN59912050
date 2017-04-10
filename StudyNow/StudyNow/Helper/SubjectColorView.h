//
//  SubjectColorView.h
//  StudyNow
//
//  Created by Rajesh Mehta on 10/19/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubjectColorView : UIView

@property (nonatomic, strong) NSMutableArray *classesList;

- (void) initView:(NSMutableArray *)subjects;

@end
