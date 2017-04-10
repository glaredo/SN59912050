//
//  SubjectColorView.m
//  StudyNow
//
//  Created by Rajesh Mehta on 10/19/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "SubjectColorView.h"
#import "MyClasses.h"

@implementation SubjectColorView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code

    CGRect viewRect = self.frame;
    int height = viewRect.size.height / [_classesList count];
    NSInteger starty = 0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(MyClasses* classes in _classesList){
        CGRect rectangle = CGRectMake(0, starty, viewRect.size.width, height);
        CGContextSetRGBFillColor(context, [classes.red floatValue], [classes.green floatValue], [classes.blue floatValue], 1.0);   //this is the transparent color
        //        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5);
        CGContextFillRect(context, rectangle);
        //        CGContextStrokeRect(context, rectangle);
        
        starty += height;
    }

}


- (void) initView:(NSMutableArray *)subjects {
    _classesList = [[NSMutableArray alloc] init];
    [_classesList addObjectsFromArray:subjects];
    
    [self setNeedsDisplay];
}

@end
