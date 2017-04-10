//
//  MyClasses.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/10/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "MyClasses.h"

@implementation MyClasses

-(MyClasses *)initWithName:(NSString *)name shortname:(NSString *)shortname {
    if (self==[super init]) {
        self.name=name;
        if(shortname)
            self.shortname = shortname;
        else
            self.shortname = @"";
    }
    return self;
}

+(MyClasses *)createMyClasse:(NSString *)name shortname:(NSString *)shortname
                         red:(float)red green:(float)green blue:(float)blue {
    MyClasses* myClass =  [[MyClasses alloc] initWithName:name shortname:shortname ];
    myClass.red = [NSNumber numberWithFloat:red];
    myClass.green = [NSNumber numberWithFloat:green];
    myClass.blue = [NSNumber numberWithFloat:blue];
    
    return myClass;
}

-(void)updateMyClasse:(NSString *)name shortname:(NSString *)shortname
                  red:(float)red green:(float)green blue:(float)blue {
    self.name =  name;
    if(shortname)
        self.shortname = shortname;
    else
        self.shortname = @"";
//    self.shortname = shortname;
    self.red = [NSNumber numberWithFloat:red];
    self.green = [NSNumber numberWithFloat:green];
    self.blue = [NSNumber numberWithFloat:blue];
}

@end
