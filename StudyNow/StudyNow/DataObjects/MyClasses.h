//
//  MyClasses.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/10/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyClasses : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *updated;

@property (nonatomic, strong) NSString *schoolId;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortname;
@property (nonatomic, strong) NSNumber *red;
@property (nonatomic, strong) NSNumber *green;
@property (nonatomic, strong) NSNumber *blue;

+(MyClasses *)createMyClasse:(NSString *)name shortname:(NSString *)shortname
                        red:(float)red green:(float)green blue:(float)blue;

-(MyClasses *)initWithName:(NSString *)name shortname:(NSString *)shortname;

-(void)updateMyClasse:(NSString *)name shortname:(NSString *)shortname 
                         red:(float)red green:(float)green blue:(float)blue;

@end
