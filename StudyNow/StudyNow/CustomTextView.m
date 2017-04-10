//
//  CustomTextView.m
//  SundayDrivers
//
//  Created by Rajesh Mehta on 3/26/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

@dynamic delegate;

-(void)setText:(NSString *)text
{
    BOOL originalValue = self.scrollEnabled;
    //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
    //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
    //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

- (void)setScrollable:(BOOL)isScrollable
{
    [super setScrollEnabled:isScrollable];
}

-(void)setContentOffset:(CGPoint)s
{
    if(self.tracking || self.decelerating){
        //initiated by user...
        
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
        
    } else {
        
        float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
        if(s.y < bottomOffset && self.scrollEnabled){
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;
        }
    }
    
    // Fix "overscrolling" bug
    if (s.y > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
        s = CGPointMake(s.x, self.contentSize.height - self.frame.size.height);
    
    [super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
    UIEdgeInsets insets = s;
    
    if(s.bottom>8) insets.bottom = 0;
    insets.top = 0;
    
    [super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    // is this an iOS5 bug? Need testing!
    if(self.contentSize.height > contentSize.height)
    {
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    
    [super setContentSize:contentSize];
}

-(void)commonInitialiser
{
    // Initialization code
    CGRect r = self.frame;
    r.origin.y = 0;
    r.origin.x = 0;
    self.scrollEnabled = NO;
    self.contentInset = UIEdgeInsetsZero;
    self.showsHorizontalScrollIndicator = NO;
    self.contentMode = UIViewContentModeRedraw;
    
    minHeight = self.frame.size.height;
    maxHeight = 100;
    
    
//    [self setMaxNumberOfLines:3];
    
}

-(CGSize)adjustSizeThatFits:(CGSize)oldsize
{
    CGSize size = [self sizeThatFits:oldsize];
    if (self.text.length == 0) {
        size.height = minHeight;
    }
    return size;
}

- (void)resetScrollPositionForIOS7
{
    CGRect r = [self caretRectForPosition:self.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - self.frame.size.height + r.size.height + 8, 0);
    if (self.contentOffset.y < caretY && r.origin.y != INFINITY)
        self.contentOffset = CGPointMake(0, caretY);
}
/*
-(void)changeMyTextView:(NSInteger)newSizeH
{
    if ([_delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [_delegate growingTextView:self willChangeHeight:newSizeH];
    }
    
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH; // + padding
//    self.frame = internalTextViewFrame;
    
//    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom;
//    internalTextViewFrame.origin.x = contentInset.left;
    
//    if(!CGRectEqualToRect(self.frame, internalTextViewFrame)) self.frame = internalTextViewFrame;
} */

- (CGFloat)measureHeight
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        return ceilf([self adjustSizeThatFits:self.frame.size].height);
    }
    else {
        return self.contentSize.height;
    }
}

- (void)refreshHeight
{
    //size of content, so we can set the frame of self
    NSInteger newSizeH = [self measureHeight];
    if (newSizeH < minHeight || !self.hasText) {
        newSizeH = minHeight; //not smalles than minHeight
    }
    else if (maxHeight && newSizeH > maxHeight) {
        newSizeH = maxHeight; // not taller than maxHeight
    }
    
    if (self.frame.size.height != newSizeH)
    {
        // if our new height is greater than the maxHeight
        // sets not set the height or move things
        // around and enable scrolling
        if (newSizeH >= maxHeight)
        {
            if(!self.scrollEnabled){
                self.scrollEnabled = YES;
                [self flashScrollIndicators];
            }
        } else {
            self.scrollEnabled = NO;
        }
        
        // [fixed] Pasting too much text into the view failed to fire the height change,
        // thanks to Gwynne <http://blog.darkrainfall.org/>
        if (newSizeH <= maxHeight)
        {
//            [self changeMyTextView:newSizeH];
            [UIView animateWithDuration:0.01f
                delay:0
                options:(UIViewAnimationOptionAllowUserInteraction|
                         UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^(void) {
//                                         if ([self respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
                                             [self.delegate growingTextView:self willChangeHeight:newSizeH];
//                                         }

                                         CGRect internalTextViewFrame = self.frame;
                                         internalTextViewFrame.size.height = newSizeH; // + padding
                                     }
                                     completion:^(BOOL finished) {
                                         if ([self respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                                             [self.delegate growingTextView:self didChangeHeight:newSizeH];
                                         }
                                     }];
        }
    }
    // scroll to caret (needed on iOS7)
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self performSelector:@selector(resetScrollPositionForIOS7) withObject:nil afterDelay:0.1f];
    }
    
    // Tell the delegate that the text view changed
    if ([self respondsToSelector:@selector(growingTextViewDidChange:)]) {
        [self.delegate growingTextViewDidChange:self];
    }
}

    
- (void) setMaxNumberOfLines:(int)maxNumberOfLines {
    if(maxNumberOfLines == 0 && maxHeight > 0) return; // the user specified a maxHeight themselves.
    
    // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = self.text, *newText = @"-";
    
//    self.delegate = nil;
    self.hidden = YES;
    
    for (int i = 1; i < maxNumberOfLines; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    self.text = newText;
    
    maxHeight = [self measureHeight];
    
    self.text = saveText;
    self.hidden = NO;
//    self.delegate = self;
    
    [self sizeToFit];
    
    maxNumberOfLines = maxNumberOfLines;
}

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end
