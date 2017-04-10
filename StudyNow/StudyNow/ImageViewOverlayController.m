//
//  ImageViewOverlayController.m
//  CertBox
//
//  Created by Rajesh Mehta on 1/3/16.
//  Copyright © 2016 Lateralus Tech. All rights reserved.
//

#import "ImageViewOverlayController.h"
#import "ImageCacheHelper.h"
#import "AppDelegate.h"
#import "UIImageView+Networking.h"
#import "BackendHelper.h"

@interface ImageViewOverlayController ()  {
}
@property (nonatomic, strong) UIImageView *imageView;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;
@end

@implementation ImageViewOverlayController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height;

    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    [self.mScrollView addSubview:self.imageView];
    
    // Tell the scroll view the size of the contents
    self.mScrollView.contentSize = CGSizeMake(viewWidth, viewHeight);

/*    self.imageView = [[UIImageView alloc] initWithImage:_selectedImage];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=_selectedImage.size};
    [self.mScrollView addSubview:self.imageView];
    
    // Tell the scroll view the size of the contents
    self.mScrollView.contentSize = _selectedImage.size; */
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.mScrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.mScrollView addGestureRecognizer:twoFingerTapRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    [self initView];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    

    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) initView {
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.mScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.mScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.mScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.mScrollView.minimumZoomScale = minScale;
    self.mScrollView.maximumZoomScale = 10.0f;
    self.mScrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
    
        __weak typeof(self) weakSelf = self;
                NSURL *url = [NSURL URLWithString:self.imageUrl];
                [self.imageView setImageURL:url withCompletionBlock:^(BOOL succes, UIImage *image, NSError *error) {
                    if(image){
                        NSLog(@"ImageView: image received");
                        [weakSelf centerScrollViewContents];
                    }
                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

- (IBAction)onTouchClose:(id)sender {
    
    if(self.delegate)
        [self.delegate onReturnFromOverlayView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    } ];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.mScrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.mScrollView.zoomScale * 2.0f;
    newZoomScale = MIN(newZoomScale, self.mScrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.mScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.mScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.mScrollView.zoomScale / 2.0f;
    newZoomScale = MAX(newZoomScale, self.mScrollView.minimumZoomScale);
    [self.mScrollView setZoomScale:newZoomScale animated:YES];
}


@end
