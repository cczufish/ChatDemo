//
//  ABPMCell.h
//  AiBa
//
//  Created by Wu Stan on 12-2-29.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRichLabel.h"

@class SWMessageCDSO;

@interface SWConversationCell : UITableViewCell{
    UIView *vMessage,*vTime;
    SWImageView *imgvAvatar;
    UIImageView *imgvStatus;
    UIActivityIndicatorView *indicator;
    UIImageView *imgvBG,*imgvArrow,*imgvLevel;
    SWRichLabel *lblContent;
    UILabel *lblTime,*lblName;
    CAShapeLayer *slBG;
    
    SWMessageCDSO __weak *message;

//    id <ABBlogCellDelegate> __weak delegate;
}
@property (nonatomic,weak) SWMessageCDSO *message;

//@property (nonatomic,weak) id<ABBlogCellDelegate> delegate;

- (void)showWithTime:(BOOL)showTime;

@end
