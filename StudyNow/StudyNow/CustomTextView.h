//
//  CustomTextView.h
//  SundayDrivers
//
//  Created by Rajesh Mehta on 3/26/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTextView;

@protocol CustomTextViewDelegate
@optional
- (BOOL)growingTextViewShouldBeginEditing:(CustomTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(CustomTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(CustomTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(CustomTextView *)growingTextView;

- (BOOL)growingTextView:(CustomTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(CustomTextView *)growingTextView;

- (void)growingTextView:(CustomTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(CustomTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(CustomTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(CustomTextView *)growingTextView;
@end

@interface CustomTextView : UITextView {
    int minHeight;
    int maxHeight;

}

@property (nonatomic) int maxHeight;
@property (nonatomic) int minHeight;

@property (nonatomic, weak) id <CustomTextViewDelegate, UITextViewDelegate> delegate;

@property (nonatomic, assign) int maxNumberOfLines;

@property (nonatomic, assign) int currentCount;

@property (nonatomic, copy) NSString* fontName;

- (void)refreshHeight;
- (void)changeMyTextView:(NSInteger)newSizeH;
-(void)commonInitialiser;

@end
