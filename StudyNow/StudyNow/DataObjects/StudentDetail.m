//
//  StudentDetail.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/12/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "StudentDetail.h"

@implementation StudentDetail

-(void)addMyClass:(MyClasses *)myclass {
    if(!self.classes)
        self.classes = [[NSMutableArray alloc] init];
    
    [self.classes addObject:myclass];
}

- (BOOL) isClassPresent:(NSString *)name {
    for(MyClasses* myclass in self.classes){
        if([myclass.name isEqualToString:name])
            return true;
    }
    
    return false;
}

-(void)removeMyClass:(MyClasses *)removeclass {
    for(MyClasses* myclass in self.classes){
        if([myclass.name isEqualToString:removeclass.name]) {
            [self.classes removeObject:myclass];
            break;
        }
    }
}

@end
