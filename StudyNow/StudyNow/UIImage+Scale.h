//
//  UIImage+Scale.h
//  Randevuk
//
//  Created by Rajesh Mehta on 7/17/15.
//  Copyright (c) 2015 Randevuk, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

typedef enum {
    ImageResizeCrop,	// analogous to UIViewContentModeScaleAspectFill, i.e. "best fit" with no space around.
    ImageResizeCropStart,
    ImageResizeCropEnd,
    ImageResizeScale	// analogous to UIViewContentModeScaleAspectFit, i.e. scale down to fit, leaving space around if necessary.
} ImageResizingMethod;

+ (UIImage *)roundedRectImageFromImage :(UIImage *)image
                                  size :(CGSize)imageSize
                      withCornerRadius :(float)cornerRadius;

- (UIImage *)imageToFitSize:(CGSize)size method:(ImageResizingMethod)resizeMethod;
- (UIImage *)imageCroppedToFitSize:(CGSize)size; // uses MGImageResizeCrop
- (UIImage *)imageScaledToFitSize:(CGSize)size; // uses MGImageResizeScale

@end
