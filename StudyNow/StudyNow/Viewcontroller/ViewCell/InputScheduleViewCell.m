//
//  InputScheduleViewCell.m
//  StudyNow
//
//  Created by Rajesh Mehta on 5/10/16.
//  Copyright © 2016 StudyNow. All rights reserved.
//

#import "InputScheduleViewCell.h"
#import "GeneralHelper.h"

@implementation InputScheduleViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];

    [GeneralHelper addLabelBorder:_mBkgLabel];
    _mColorView.layer.cornerRadius = 6.0f;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) initViewWithData:(MyClasses *)data rowIndex:(int)index {
    self.indexRow = index;
    if(data){
        _mClassText.text = data.name;
//        _mClassText.text = [NSString stringWithFormat:@"%@ (%@)", data.name, data.shortname];
        _mColorView.backgroundColor = [UIColor colorWithRed:[data.red floatValue] green:[data.green floatValue] blue:[data.blue floatValue] alpha:1.0];
        _mDeleteButton.hidden = false;
    } else {
        _mClassText.text = @"";
        _mClassText.placeholder = [NSString stringWithFormat:@"Class %d(Filter %d)",(index + 1), (index + 1)];
        _mColorView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        _mDeleteButton.hidden = true;
    }
}

- (IBAction)onTouchDelete:(id)sender {
    if (self.onTouchDelete) {
        self.onTouchDelete(self.indexRow);
    }
}

@end
