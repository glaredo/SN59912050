//
//  ShowClassesViewController.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/10/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "ShowClassesViewController.h"
#import "BackendHelper.h"
#import "Subject.h"
#import "GeneralHelper.h"

#define DR_COLOR_PICKER_HUE_VIEW_PAGE_COUNT 12

@interface ShowClassesViewController () <UISearchBarDelegate> {
    NSMutableArray* subjectList;
    NSString* selectedSubject;
    NSString* selectedShortName;
    NSIndexPath* selectedPath;
    int colorIndex;

    id dataCollection;
}

@property (nonatomic, strong) UIImageView* hueIndicator;
@property (nonatomic, strong) NSMutableArray* hueColors;

@end

@implementation ShowClassesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mHueBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mHueBar.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hueBarTapped:)];
    [self.mHueBar addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hueBarPanned:)];
    [self.mHueBar addGestureRecognizer:panGesture];

    self.hueIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drcolorpicker-brightnessguide"]];
    self.hueIndicator.layer.shadowColor = [UIColor blackColor].CGColor;
    self.hueIndicator.layer.shadowOffset = CGSizeZero;
    self.hueIndicator.layer.shadowRadius = 1;
    self.hueIndicator.layer.shadowOpacity = 0.8f;
    self.hueIndicator.layer.shouldRasterize = YES;
    self.hueIndicator.layer.rasterizationScale = UIScreen.mainScreen.scale;
    [self.view addSubview:self.hueIndicator];
    


    subjectList = [[NSMutableArray alloc] init];
    
    [self getSubjectList];
    
    colorIndex = 0;
    
    [self setHueColorsList];
}

- (void) getSubjectList {
    UserData *currentUser = [BackendHelper getCurrentUser];
    [BackendHelper fetchSubjects:currentUser.school search:_mSearchBar.text completion:^(BOOL success, NSMutableArray *list, id collection, NSError *error) {
        if(success){
            dataCollection = collection;
            [subjectList removeAllObjects];
            [subjectList addObjectsFromArray:list];
            
            NSArray *currentPage = [dataCollection getCurrentPage];
            NSLog(@"Loaded %lu subjects objects", (unsigned long)[currentPage count]);
            NSLog(@"Total subjects in the Backendless storage - %@", [dataCollection getTotalObjects]);
            
            if([subjectList count] < [[dataCollection getTotalObjects] intValue]) {
                [self getMoreSubjectList];
            }
            
            [self.mTableView reloadData];
        }
    }];
}

- (void) getMoreSubjectList {
    [BackendHelper fetchMoreSubjects:dataCollection completion:^(BOOL success, NSMutableArray *list, id collectionObject, NSError *error) {
        if(list){
            dataCollection = collectionObject;
            [subjectList addObjectsFromArray:list];
            if([subjectList count] < [[dataCollection getTotalObjects] intValue]) {
                [self getMoreSubjectList];
            }

            [self.mTableView reloadData];
        }
    }];
}


- (void) setHueColorsList {
    self.hueColors = [NSMutableArray array];
    
    for (NSInteger i = 0 ; i < DR_COLOR_PICKER_HUE_VIEW_PAGE_COUNT; i++)
    {
        CGFloat hue = i * 30 / 360.0;
        UIColor* color = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
        [self.hueColors addObject:color];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if(self.name){
        _mNameLabel.text = self.name;
    } else {
        _mNameLabel.text = [NSString stringWithFormat:@"Class %d (Filter %d)", self.index, self.index];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updatePage];
}

- (void) updatePage
{
    CGFloat hueSize = self.mHueBar.bounds.size.width / DR_COLOR_PICKER_HUE_VIEW_PAGE_COUNT;

 //   CGFloat percent = self.hueGrid.contentOffset.x / pages;
    CGFloat trackWidth = self.mHueBar.bounds.size.width - hueSize;
    CGPoint center = CGPointMake(self.mHueBar.frame.origin.x + (hueSize * 0.5f) + (hueSize * colorIndex), self.mHueBar.center.y);
    self.hueIndicator.center = center;
}

- (void) scrollFromColorBarPoint:(CGPoint)p
{
    NSInteger page = p.x / (self.mHueBar.bounds.size.width / DR_COLOR_PICKER_HUE_VIEW_PAGE_COUNT);
    colorIndex = page;
    [self updatePage];
}

- (void) hueBarTapped:(UITapGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.mHueBar];
    [self scrollFromColorBarPoint:point];
}

- (void) hueBarPanned:(UIPanGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:self.mHueBar];
    [self scrollFromColorBarPoint:point];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [subjectList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Subject* subject = subjectList[indexPath.row];
    UITableViewCell *mSubjectCell = [tableView dequeueReusableCellWithIdentifier:@"mSubjectCellId" forIndexPath:indexPath];
//    mSubjectCell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", subject.name, subject.shortname];
    mSubjectCell.textLabel.text = subject.name;
    
    if(selectedSubject && [selectedSubject isEqualToString:subject.name]) {
        mSubjectCell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedPath = indexPath;
    } else {
        mSubjectCell.accessoryType = UITableViewCellAccessoryNone;
    }
/*    InputScheduleViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"InputScheduleViewCellId" forIndexPath:indexPath];
    [messageCell initViewWithData:nil rowIndex:indexPath.row];
    return messageCell; */
    return mSubjectCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Subject* subject = subjectList[indexPath.row];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(selectedSubject && [selectedSubject isEqualToString:subject.name]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        selectedPath = nil;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedSubject = subject.name;
        selectedShortName = subject.shortname;
        if(selectedPath){
            UITableViewCell *oldcell = [tableView cellForRowAtIndexPath:selectedPath];
            oldcell.accessoryType = UITableViewCellAccessoryNone;
        }
        selectedPath = indexPath;
    }
    [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onTouchCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTouchSelect:(id)sender {
    if(!selectedSubject || [selectedSubject isEqualToString:@""]) {
        [GeneralHelper ShowMessageBoxWithTitle:@"Error!" Body:@"Please select the subject." tag:1 andDelegate:nil];
        return;
    }
        
    UIColor* selectedColor = self.hueColors[colorIndex];
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    if(self.delegate)
        [self.delegate selectedSubject:selectedSubject shortname:selectedShortName red:red green:green blue:blue viewController:self];
}

#pragma mark - search
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Search text: %@", searchText);
//    if (searchText.length>0) {
        // search and reload data source
        [self filterContentForSearchText:searchText scope:@""];
//    }else{
//        [displayList removeAllObjects];
//        [self.mTableView reloadData];
//    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    [self getSubjectList];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self.mTableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.mSearchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    //    searchBarActive = NO;
    [self.mSearchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    [_mSearchBar resignFirstResponder];
    _mSearchBar.text  = @"";
    [self filterContentForSearchText:_mSearchBar.text scope:@""];
}

@end
