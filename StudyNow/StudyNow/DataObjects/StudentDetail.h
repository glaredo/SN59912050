//
//  StudentDetail.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyClasses.h"

@interface StudentDetail : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSMutableArray *classes;

-(void)addMyClass:(MyClasses *)myclass;
-(void)removeMyClass:(MyClasses *)myclass;

- (BOOL) isClassPresent:(NSString *)name;
@end
