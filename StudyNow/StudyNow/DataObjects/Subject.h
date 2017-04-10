//
//  Subject.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schools.h"

@interface Subject : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortname;
@property (nonatomic, strong) Schools *school;

@end
