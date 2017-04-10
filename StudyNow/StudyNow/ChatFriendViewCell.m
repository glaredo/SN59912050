//
//  ChatFriendViewCell.m
//  SundayDrivers
//
//  Created by Rajesh Mehta on 5/21/16.
//  Copyright © 2016 Sunday Drivers, LLC. All rights reserved.
//

#import "ChatFriendViewCell.h"

@implementation ChatFriendViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];
    _mMessageText.textContainerInset = UIEdgeInsetsZero;
    CGRect rect = _mProfileImgView.frame;
    _mProfileImgView.layer.cornerRadius = rect.size.height / 2;


    self.mMsgImgView.userInteractionEnabled = true;
    
    UITapGestureRecognizer *movieSingle1GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageTapped)];
    movieSingle1GestureRecognizer.numberOfTapsRequired = 1;
    [self.mMsgImgView addGestureRecognizer:movieSingle1GestureRecognizer];

}

-(void)showImageTapped {
        if (self.onTouchShowImage) {
            self.onTouchShowImage(_imageUrl);
        }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initViewWithData:(ChatData *)chatData rowIndex:(int)index {
    
}


@end
