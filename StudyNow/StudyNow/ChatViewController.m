//
//  ChatViewController.m
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import "ChatViewController.h"
#import "UIImageView+Networking.h"
#import "ChatFriendViewCell.h"
#import "MyAppConstants.h"
#import "GeneralHelper.h"
#import "ChatData.h"
#import "LastChat.h"
#import "BackendHelper.h"
#import "AppDelegate.h"
#import "ImageViewOverlayController.h"

#define OSVersionIsAtLeastiOS7  (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

#define INPUT_HEIGHT    46.0f
#define TOOLBAR_HEIGHT  60.0f

@interface ChatViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, ImageViewOverlayDelegate> {
    ImageViewOverlayController *overlayController;
    NSMutableArray* messageArray;
    UIImage* friendProfileImg;
    UIImage* myProfileImg;
    NSDate* previousChatDate;
    
    NSDateFormatter *viewDateFormatter;
    NSDateFormatter *chatTimeFormatter;
    NSString* lastChatObjectId;
    UserData* currentUserData;
    NSString* currentUserDeviceId;
    
    NSMutableArray* unreadMessages;
    
    float originalBottomHeightConstraint;
    float originalTextViewHeight;
    
    BOOL messagesRetrieved;
}


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    messagesRetrieved = false;
    
    
    viewDateFormatter = [[NSDateFormatter alloc] init];
    [viewDateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    chatTimeFormatter = [[NSDateFormatter alloc] init];
    [chatTimeFormatter setDateFormat:@"hh:mm a"];
    
    _mNameLabel.text = @"";
    _mTimeInfoLabel.text = @"";
    
    _mChatText.text = @"";
    _mChatText.layer.cornerRadius = 5.0f;
    //    _mChatText.textContainer.maximumNumberOfLines = 1;
    
    messageArray = [[NSMutableArray alloc] init];
    unreadMessages = [[NSMutableArray alloc] init];
    
    self.mTableView.rowHeight = UITableViewAutomaticDimension;
    [self.mChatText commonInitialiser];
    //    self.mChatText.maxNumberOfLines = 4;
    self.mChatText.delegate = self;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:kDidReceivedChatNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDelivered:) name:SINCH_MESSAGE_RECIEVED object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDelivered:) name:SINCH_MESSAGE_SENT object:nil];

    
    UITapGestureRecognizer *tapTableGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView)];
    [self.mTableView addGestureRecognizer:tapTableGR];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];

    _mNameLabel.text = _profileSummary.name;
    friendProfileImg = _profileSummary.profileImage;
    myProfileImg = [BackendHelper getCurrentUser].profileImage;
    
    [BackendHelper getDeviceId:_profileSummary.objectId completionBlock:^(BOOL success, NSString *deviceID, NSError *error) {
        if(success){
            currentUserDeviceId = deviceID;
        }
    }];
    
    [self retrieveLastChatFromParseWithChatID:_profileSummary.objectId];
    
//    [self retrieveMessagesFromParseWithChatID:_profileSummary.objectId];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceivedNotification:) name:kRefreshMessageRequested object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    originalBottomHeightConstraint = self.mBottomViewHeightConstraint.constant;
    originalTextViewHeight = self.mChatText.frame.size.height;
    [self.mChatText commonInitialiser];

    [self startRefresh];
    
    [self scrollTableToBottom:true];  // Scroll to the bottom of the table view
}

- (void)messageReceived:(NSNotification *)note {
    [self startRefresh];
    [self scrollTableToBottom:true];  // Scroll to the bottom of the table view
}

- (void)messageDelivered:(NSNotification *)notification
{
    ChatData *chatMessage = [[notification userInfo] objectForKey:@"message"];
    if ([[chatMessage senderId] isEqualToString:_profileSummary.objectId]) {
        [messageArray addObject:chatMessage];
        [self refreshTable];
//    } else if ([[chatMessage recipientId] isEqualToString:_profileSummary.objectId]) {
//        [messageArray addObject:chatMessage];
//        [self refreshTable];
    }
    
}

- (void)setup
{
    if([self.view isKindOfClass:[UIScrollView class]]) {
        // fix for ipad modal form presentations
        ((UIScrollView *)self.view).scrollEnabled = NO;
    }
    
    CGSize size = self.view.frame.size;
    
    CGRect tableFrame = CGRectMake(0.0f, 0.0f + TOOLBAR_HEIGHT, size.width, size.height - INPUT_HEIGHT - TOOLBAR_HEIGHT);
    self.mTableView.frame = tableFrame;
    self.mTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    CGRect inputFrame = CGRectMake(0.0f, size.height - INPUT_HEIGHT, size.width, INPUT_HEIGHT);
    self.mBottomView.frame = inputFrame;
    self.mBottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect textViewFrame = self.mChatText.frame;
    CGRect sendButtonFrame = self.mSendButton.frame;
    float width = size.width - textViewFrame.origin.x - sendButtonFrame.size.width - 20;
    
    textViewFrame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, width, textViewFrame.size.height);
    self.mChatText.frame = textViewFrame;
    self.mSendButton.frame = CGRectMake(size.width - textViewFrame.origin.x - sendButtonFrame.size.width - 10, sendButtonFrame.origin.y, sendButtonFrame.size.width, sendButtonFrame.size.height);
    
    self.mChatText.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)startRefresh {
    [self retrieveMessagesFromParseWithChatID:_profileSummary.objectId];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)messageReceivedNotification:(NSNotification *)notification {
    NSDictionary* dict = notification.userInfo;
    if(dict) {
        NSLog(@"%@", [dict objectForKey:@"fromid"]);
        NSString* fromid = [dict objectForKey:@"fromid"];
        if([fromid isEqualToString:_profileSummary.objectId]) {
            [self retrieveMessagesFromParseWithChatID:_profileSummary.objectId];
        }
        
    }
    // catches all notifications
}

- (void) updateLabel {
    
}

- (void)didTapOnTableView {
    [self.mChatText resignFirstResponder];
}

- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    
    return kNilOptions;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect keyboardRect = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    self.mBottomViewBottomConstraint.constant = keyboardRect.size.height;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[self animationOptionsForCurve:curve]
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIViewAnimationCurve curve = [[aNotification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[aNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.mBottomViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:[self animationOptionsForCurve:curve]
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    //    _mSendButton.selected = true;
    //    if(!self.previousTextViewContentHeight)
    //        self.previousTextViewContentHeight = textView.contentSize.height;
    
    [self scrollTableToBottom:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    //    _mSendButton.selected = false;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_mChatText refreshHeight];
}

- (void)growingTextView:(CustomTextView *)growingTextView willChangeHeight:(float)height {
    NSLog(@"New Height: %0.2f", height);
    float diff = height - originalTextViewHeight;
    if(diff < 0)
        diff = 0;
    self.mBottomViewHeightConstraint.constant = originalBottomHeightConstraint + diff;
    [self scrollTableToBottom:YES];
}

- (void)scrollTableToBottom:(BOOL)animated {
    NSInteger rowNumber = [self.mTableView numberOfRowsInSection:0];
    if (rowNumber > 0) [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumber-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void) refreshTable {
    __weak typeof(self) weakSelf = self;
    [weakSelf.mTableView reloadData];  // Refresh the table view
    
    NSInteger count = [messageArray count];
    if(count > 0){
        NSIndexPath* path = [NSIndexPath indexPathForRow:(count - 1)  inSection:0];
        [self.mTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        NSInteger time = dispatch_time(DISPATCH_TIME_NOW, 1000);
        
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [weakSelf.mTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            //        [weakSelf scrollTableToBottom:true];  // Scroll to the bottom of the table view
        });
    }
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)position
                      animated:(BOOL)animated
{
    [self.mTableView scrollToRowAtIndexPath:indexPath
                           atScrollPosition:position
                                   animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([messageArray count] == 0){
        if(self.canShowMessage){
            if(messagesRetrieved)
                return 380;
        }
    }
    
    ChatData *chatMessageData = messageArray[indexPath.row];
    if(![chatMessageData isTextMessage]){
        if ([[chatMessageData senderId] isEqualToString:_profileSummary.objectId])
            return 138;
        else
            return 148;
    }
//    MessageData *chatMessageData = messageArray[indexPath.row];
//    if([chatMessageData.senderId isEqualToString:@""])
//        return 40.0;
    
    return UITableViewAutomaticDimension;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([messageArray count] == 0){
        if(self.canShowMessage){
            if(messagesRetrieved)
                return 380;
        }
    }

    ChatData *chatMessageData = messageArray[indexPath.row];
    if(![chatMessageData isTextMessage]){
        if ([[chatMessageData senderId] isEqualToString:_profileSummary.objectId])
            return 138;
        else
            return 148;
    }

//    MessageData *chatMessageData = messageArray[indexPath.row];
//    if([chatMessageData.senderId isEqualToString:@""])
//        return 40.0;
    
    return 69.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([messageArray count] == 0){
        if(self.canShowMessage){
            if(messagesRetrieved)
                return 1;
        }
    }
    // Return the number of rows in the section.
    return [messageArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatData *chatMessageData = messageArray[indexPath.row];
    if([chatMessageData.senderId isEqualToString:@""]) {
        ChatFriendViewCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"ChatDateViewCell" forIndexPath:indexPath];
        messageCell.mMessageBkgLabel.text = chatMessageData.text;
        
        return messageCell;
    }
    if ([[chatMessageData senderId] isEqualToString:_profileSummary.objectId]) {
        ChatFriendViewCell *messageCell;
        if([chatMessageData isTextMessage]) {
            messageCell = [tableView dequeueReusableCellWithIdentifier:@"ChatFriendViewCell" forIndexPath:indexPath];
        } else {
            messageCell = [tableView dequeueReusableCellWithIdentifier:@"ChatFriendImageViewCell" forIndexPath:indexPath];
        }
        [self configureCell:messageCell forIndexPath:indexPath profileImg:friendProfileImg isMe:false];
        return messageCell;
    } else {
        ChatFriendViewCell *messageCell;
        if([chatMessageData isTextMessage]) {
            messageCell = [tableView dequeueReusableCellWithIdentifier:@"ChatMeViewCell" forIndexPath:indexPath];
        } else {
            messageCell = [tableView dequeueReusableCellWithIdentifier:@"ChatMeImageViewCell" forIndexPath:indexPath];
        }
        [self configureCell:messageCell forIndexPath:indexPath profileImg:myProfileImg isMe:true];
        return messageCell;
    }
}

#pragma mark Method to configure the appearance of a message list prototype cell

- (void)configureCell:(ChatFriendViewCell *)messageCell forIndexPath:(NSIndexPath *)indexPath profileImg:(UIImage *)profileImg isMe:(BOOL)isMe {
    ChatData *chatMessageData = messageArray[indexPath.row];
    
    messageCell.mMessageText.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    [messageCell.mMessageText setScrollEnabled:NO];
    messageCell.mMessageBkgLabel.layer.cornerRadius = 5.0f;
    messageCell.mMessageLabel.text = chatMessageData.text;
    messageCell.mMessageText.text = chatMessageData.text;
    messageCell.mProfileImgView.image = profileImg;
    messageCell.mMessageText.textColor = [UIColor whiteColor];
    messageCell.mDateLabel.text = [chatTimeFormatter stringFromDate:chatMessageData.timestamp];
    if(isMe){
        if([chatMessageData isMessageRead]){
//            if(chatMessageData.showMessageRead) {
                messageCell.mMsgReadLabelConstant.constant = 13;
                messageCell.mMsgReadLabel.text = [NSString stringWithFormat:@"Read %@", [chatTimeFormatter stringFromDate:chatMessageData.readTimestamp]];
//            } else {
//                messageCell.mMsgReadLabelConstant.constant = 0;
//            }
        } else {
            messageCell.mMsgReadLabel.text = @"";
            messageCell.mMsgReadLabelConstant.constant = 0;
        }
    }
    
    if([chatMessageData isTextMessage]){
        messageCell.mMsgImgView.hidden = true;
    } else {
        messageCell.mMsgImgView.hidden = false;
        messageCell.imageUrl = chatMessageData.imageUrl;
        [messageCell.mMsgImgView setImageURL:[NSURL URLWithString:chatMessageData.thumbnailUrl] withCompletionBlock:^(BOOL succes, UIImage *image, NSError *error) {
            
        }];
        
        [messageCell setOnTouchShowImage:^(NSString *imageUrl) {
            
            [self showImage:imageUrl];

        }];
    }
}

- (void) showImage:(NSString *) imageUrl {
    if(!imageUrl)
        return;
    
    [_mChatText resignFirstResponder];
    
    //    ShowMediaViewId
    
    overlayController = [[ImageViewOverlayController alloc] initWithNibName:@"ImageViewOverlayController" bundle:nil];
    overlayController.delegate = self;
    overlayController.imageUrl = imageUrl;
    overlayController.view.frame = self.view.frame;
    overlayController.view.alpha = 0;
    [self.view addSubview:overlayController.view];
    [UIView animateWithDuration:0.2 animations:^{
        overlayController.view.alpha = 1;
    } ];
    [overlayController initView];
}

- (void)onReturnFromOverlayView {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (IBAction)onTouchSend:(id)sender {
    NSString* chatMessage = _mChatText.text;
    if([GeneralHelper validateIsEmpty:chatMessage]){
        return;
    }
    
    ChatData *messageObject = [[ChatData alloc] init];
    messageObject.messageId = @"";
    messageObject.senderId = [BackendHelper getCurrentUserObjectId];
    messageObject.recipientId = _profileSummary.objectId;
    messageObject.text = chatMessage;
    messageObject.timestamp = [NSDate date];
    messageObject.msgRead = [NSNumber numberWithBool:false];
    messageObject.messageType = MESSAGE_TYPE_TEXT;
    [BackendHelper saveTextMessagesOnParse:messageObject completionBlock:^(BOOL success, ChatData *data, NSError *error) {
        if(success){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate sendTextMessage:chatMessage toRecipient:_profileSummary.objectId objectId:data.objectId];
        }
    }];
    _mChatText.text = @"";
    [_mChatText refreshHeight];
    
    [messageArray addObject:messageObject];
    [self refreshTable];

}


- (void)retrieveLastChatFromParseWithChatID:(NSString *)chatMateId {
    [BackendHelper getLastMessage:chatMateId completion:^(BOOL success, LastChat *data, NSError *error) {
        if(data){
            lastChatObjectId = data.objectId;
        }
        [self retrieveMessagesFromParseWithChatID:_profileSummary.objectId];
    }];
}


- (void)retrieveMessagesFromParseWithChatID:(NSString *)chatMateId {
    [BackendHelper getMessageList:chatMateId completionBlock:^(BOOL success, NSMutableArray *list, NSError *error) {
        if(success){
            [messageArray removeAllObjects];
            [messageArray addObjectsFromArray:list];
            [self refreshTable];
        }
        
    }];
/*    [ParseHelper getMessageList:chatMateId completionBlock:^(BOOL success, NSArray *messageList, NSError *error) {
        if(success){
            [messageArray removeAllObjects];
            [messageArray addObjectsFromArray:messageList];
            NSInteger count = [messageArray count] - 1;
            for(int i = (int)count; i >= 0; i--){
                MessageData *chatMessageData = messageArray[i];
                if (![[chatMessageData senderId] isEqualToString:_profileSummary.objectId]) {
                    if(chatMessageData.messageRead){
                        chatMessageData.showMessageRead = true;
                        break;
                    }
                }
            }
            messagesRetrieved = true;
            [self refreshTable];
        }
    }]; */
}


/*
- (NSString *) getFirstName:(PFObject *)user {
    NSArray* nameArray = [user[@"name"] componentsSeparatedByString:@" "];
    if([nameArray count] > 0)
        return nameArray[0];
    else
        return user[@"name"];
}
*/

- (IBAction)onTouchReport:(id)sender {
    NSString *subject = @"StudyNow: A user is being reported";
    NSString *body = [NSString stringWithFormat:@"<b>%@(id:%@)</b> wants to report a user named <b>%@(id: %@)</b>", [BackendHelper getCurrentUser].name, [BackendHelper getCurrentUser].objectId, _profileSummary.name, _profileSummary.objectId];
    [BackendHelper sendEmail:subject body:body completionBlock:^(BOOL success, NSError *error) {
        if(success){
            [GeneralHelper ShowMessageBoxWithTitle:@"Success" Body:@"Thanks for reporting a user. We will follow up on your request." tag:-1 andDelegate:nil];
        } else {
            [GeneralHelper ShowMessageBoxWithTitle:@"Error" Body:error.localizedDescription tag:-1 andDelegate:nil];            
        }
    }];
}


- (IBAction)onTouchCamera:(id)sender {
    [self createAlertView:@"Pick a photo" withMessage:@"Pick a photo..." okTitle:@"From Gallery" cancelTitle:@"From Camera" okSelector:@selector(getPictureFromGallery) cancelSelector:@selector(getPictureFromCamera)];

}

// image picker controller
- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* imageFromiOSPicker = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self sendImageChat:imageFromiOSPicker];
    }];
    
}

- (void)sendImageChat:(UIImage *)image {
    ChatData *messageObject = [[ChatData alloc] init];
    messageObject.messageId = @"";
    messageObject.senderId = [BackendHelper getCurrentUserObjectId];
    messageObject.recipientId = _profileSummary.objectId;
    messageObject.text = @"";
    messageObject.timestamp = [NSDate date];
    messageObject.msgRead = [NSNumber numberWithBool:false];
    messageObject.messageType = MESSAGE_TYPE_IMAGE;
    [[AppDelegate sharedDelegate] showFetchAlert];
    [BackendHelper saveImageMessagesOnParse:messageObject image:image completionBlock:^(BOOL success, ChatData *data, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if(success){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate sendImageMessage:@"" toRecipient:_profileSummary.objectId objectId:data.objectId];
            _mChatText.text = @"";
            [_mChatText refreshHeight];
            
            [messageArray addObject:data];
            [self refreshTable];
        }
    }];
}


- (void)getPictureFromCamera
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //[picker setAllowsEditing:YES];
    
    picker.delegate = (id)self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [self createAlertView:@"Error" withMessage:@"There's an error with the gallery" okTitle:@"Ok" cancelTitle:nil okSelector:nil cancelSelector:nil];
    }
}

- (void)getPictureFromGallery
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //[picker setAllowsEditing:YES];
    
    picker.delegate = (id)self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [self createAlertView:@"Error" withMessage:@"There's an error with the camera" okTitle:@"Ok" cancelTitle:nil okSelector:nil cancelSelector:nil];
    }
}

- (void)createAlertView:(NSString *)title withMessage:(NSString *)message okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle okSelector:(SEL)okSelector cancelSelector:(SEL)cancelSelector
{
    UIAlertController *alert =	[UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alert.view setTintColor:[UIColor colorWithRed:93.0f/255.0f green:156.0f/255.0f blue:236.0f/255.0f alpha:1.0f]];
    
    if (okTitle != nil)
    {
        UIAlertAction *okButton = [UIAlertAction
                                   actionWithTitle:okTitle
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       if (okSelector != nil) {
                                           ((void (*)(id, SEL))[self methodForSelector:okSelector])(self, okSelector);
                                       }
                                       
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        [alert addAction:okButton];
    }
    
    if (cancelTitle != nil)
    {
        UIAlertAction *cancelButton = [UIAlertAction
                                       actionWithTitle:cancelTitle
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           if (cancelSelector != nil) {
                                               ((void (*)(id, SEL))[self methodForSelector:cancelSelector])(self, cancelSelector);
                                           }
                                           
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
        
        [alert addAction:cancelButton];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
