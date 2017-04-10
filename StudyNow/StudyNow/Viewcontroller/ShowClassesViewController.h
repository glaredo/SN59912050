//
//  ShowClassesViewController.h
//  StudyNow
//
//  Created by Rajesh Mehta on 5/10/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowClassesViewDeleage <NSObject>
- (void)selectedSubject:(NSString *)subject shortname:(NSString *)shortname red:(float)red green:(float)green blue:(float)blue viewController:(UIViewController *)controller;
@end

@interface ShowClassesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIImageView *mHueBar;
@property (weak, nonatomic) IBOutlet UISearchBar *mSearchBar;

@property (nonatomic, weak) id <ShowClassesViewDeleage> delegate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) float red;
@property (nonatomic, assign) float green;
@property (nonatomic, assign) float blue;
@property (nonatomic, assign) int index;

- (IBAction)onTouchCancel:(id)sender;
- (IBAction)onTouchSelect:(id)sender;
@end
