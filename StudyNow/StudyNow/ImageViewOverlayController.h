//
//  ImageViewOverlayController.h
//  CertBox
//
//  Created by Rajesh Mehta on 1/3/16.
//  Copyright © 2016 Lateralus Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageViewOverlayDelegate <NSObject>
- (void)onReturnFromOverlayView;
@end

@interface ImageViewOverlayController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

//@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, weak) id <ImageViewOverlayDelegate> delegate;

- (IBAction)onTouchClose:(id)sender;

- (void) initView;
@end
