//
//  Schools.h
//  StudyNow
//
//  Created by Rajesh Mehta on 4/19/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schools : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;

@end
