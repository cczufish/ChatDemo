//
//  ABPMCell.m
//  AiBa
//
//  Created by Wu Stan on 12-2-29.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import "SWConversationCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SWMessageCDSO.h"
#import "SWUserCDSO.h"
#import "SWDataProvider.h"
#import "SWRichLabel.h"

@implementation SWConversationCell
@synthesize message;
//@synthesize delegate;

- (void)showWithTime:(BOOL)showTime{
    float height = [message.content heightForPM];
    if (showTime){
        vTime.frame = CGRectMake(0, 0, 320, 26);
        vMessage.frame = CGRectMake(0, 26, 320, height-26);
        
        lblTime.text = [message.dateline dateString];
        
        float w = [lblTime.text sizeWithFont:lblTime.font].width;
        lblTime.frame = CGRectMake(160-w/2-6, 5, w+12, 16);
        
    }else{
        vTime.frame = CGRectZero;
        vMessage.frame = CGRectMake(0, 0, 320, height);
        lblTime.text = nil;
        lblTime.frame = CGRectZero;
    }
    
    
    
    
    BOOL isSender = message.isOutbound;
    [imgvAvatar loadURL:isSender?[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"avatar"]:message.user.avatar];
    lblName.text = message.user.username;
    
    NSString *content = message.content;
    lblContent.textColor = isSender?[UIColor whiteColor]:[UIColor blackColor];
    lblContent.text = content;
    CGSize size = [SWRichLabel sizeForContent:content font:kPMFont];

    imgvBG.frame = CGRectMake(0, 0, size.width>=kPMCellContentWidth?kPMCellContentWidth+18+6:size.width+18+6, size.height+12);
    slBG.frame = imgvBG.bounds;
    
    lblContent.frame = CGRectMake(9+(isSender?0:6), 6, size.width, size.height);

    
    if (isSender){
        imgvAvatar.frame = CGRectMake(320-37-10, 0, 37, 37);
        CGRect rect = imgvBG.frame;
        rect.origin.x = imgvAvatar.frame.origin.x-5-rect.size.width;
        imgvBG.frame = rect;
        imgvStatus.frame = CGRectZero;
        [imgvStatus setImage:nil];//[UIImage imageNamed:isnew?@"ABPMSent.png":@"ABPMRead.png"]];
     }else{
        imgvAvatar.frame = CGRectMake(9, 0, 37, 37);
        CGRect rect = imgvBG.frame;
        rect.origin.x = imgvAvatar.frame.origin.x+imgvAvatar.frame.size.width+5;
        imgvBG.frame = rect;
        imgvStatus.frame = CGRectZero;
        [imgvStatus setImage:nil];
    }
    
    
    [self addPathToBG:isSender];
}

- (void)addPathToBG:(BOOL)issender{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
    
    
    slBG.fillColor = issender?[UIColor colorWithRed:.42 green:.77 blue:1 alpha:1].CGColor:[UIColor whiteColor].CGColor;
    slBG.frame = imgvBG.bounds;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (issender){
        CGPathMoveToPoint(path, NULL, 0, 6);
        CGPathAddArc(path, NULL, 6, 6, 6, M_PI, M_PI*1.5f, NO);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width-12, 0);
        CGPathAddArc(path, NULL, slBG.frame.size.width-12, 6, 6, M_PI*1.5f, 0, NO);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width-6, 10);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width, 15);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width-6, 20);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width-6, slBG.frame.size.height-6);
        CGPathAddArc(path, NULL, slBG.frame.size.width-12, slBG.frame.size.height-6, 6, 0, M_PI_2, NO);
        CGPathAddLineToPoint(path, NULL, 6, slBG.frame.size.height);
        CGPathAddArc(path, NULL, 6, slBG.frame.size.height-6, 6, M_PI_2, M_PI, NO);
        CGPathCloseSubpath(path);
        
    }else{
        CGPathMoveToPoint(path, NULL, 0, 15);
        CGPathAddLineToPoint(path, NULL, 6, 10);
        CGPathAddLineToPoint(path, NULL, 6, 6);
        CGPathAddArc(path, NULL, 12, 6, 6, M_PI, M_PI*1.5f, NO);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width-6, 0);
        CGPathAddArc(path, NULL, slBG.frame.size.width-6, 6, 6, M_PI*1.5f, 0, NO);
        CGPathAddLineToPoint(path, NULL, slBG.frame.size.width, slBG.frame.size.height-6);
        CGPathAddArc(path, NULL, slBG.frame.size.width-6, slBG.frame.size.height-6, 6, 0, M_PI_2, NO);
        CGPathAddLineToPoint(path, NULL, 12, slBG.frame.size.height);
        CGPathAddArc(path, NULL, 12, slBG.frame.size.height-6, 6, M_PI_2, M_PI, NO);
        CGPathAddLineToPoint(path, NULL, 6, 20);
        CGPathCloseSubpath(path);
    }
    
    slBG.path = path;
    CGPathRelease(path);
    
    [CATransaction commit];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.clipsToBounds = YES;
        vMessage = [[UIView alloc] initWithFrame:CGRectZero];
//        vMessage.clipsToBounds = YES;
        [self.contentView addSubview:vMessage];
        
        vTime = [[UIView alloc] initWithFrame:CGRectZero];
        vTime.clipsToBounds = YES;
        [self.contentView addSubview:vTime];
        
        imgvAvatar = [[SWImageView alloc] initWithFrame:CGRectMake(9, 0, 37, 37)];
//        imgvAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
//        imgvAvatar.layer.borderWidth = 2;
        imgvAvatar.layer.masksToBounds = YES;
        [vMessage addSubview:imgvAvatar];
        imgvAvatar.userInteractionEnabled = YES;
        
        lblName = [UILabel createLabelWithFrame:imgvAvatar.bounds font:[UIFont systemFontOfSize:8]];
        [imgvAvatar addSubview:lblName];
        lblName.textAlignment = NSTextAlignmentCenter;
        
        
        imgvLevel = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgvLevel.center = CGPointMake(imgvAvatar.frame.origin.x+imgvAvatar.frame.size.width, imgvAvatar.frame.origin.y+imgvAvatar.frame.size.height);
        [vMessage addSubview:imgvLevel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = imgvAvatar.bounds;
        [imgvAvatar addSubview:btn];
        [btn addTarget:self action:@selector(avatarClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        imgvBG = [[UIImageView alloc] initWithFrame:CGRectZero];
        [vMessage addSubview:imgvBG];
        
        slBG = [[CAShapeLayer alloc] init];
        slBG.strokeColor = [UIColor clearColor].CGColor;
        slBG.contentsScale = [UIScreen mainScreen].scale;
        [imgvBG.layer addSublayer:slBG];
        
        
        lblContent = [[SWRichLabel alloc] initWithFrame:CGRectZero];
        lblContent.userInteractionEnabled = NO;
        lblContent.textColor = [UIColor blackColor];
        lblContent.font = kPMFont;
        lblContent.backgroundColor = [UIColor clearColor];
        [imgvBG addSubview:lblContent];
        
        
        imgvStatus = [[UIImageView alloc] initWithFrame:CGRectZero];
        [vMessage addSubview:imgvStatus];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = YES;
        [vMessage addSubview:indicator];
        
        imgvBG.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActions)];
        [imgvBG addGestureRecognizer:longPress];
        
        //  时间
        lblTime = [UILabel createLabelWithFrame:CGRectZero font:[UIFont systemFontOfSize:10] textColor:[UIColor colorWithWhite:.56 alpha:1]];
        lblTime.backgroundColor = [UIColor clearColor];
        lblTime.textAlignment = NSTextAlignmentCenter;
        [vTime addSubview:lblTime];
    }
    return self;
}

- (void)showActions{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:lblContent.frame inView:lblContent.superview];
    [menu setMenuVisible:YES animated:YES];
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    NSString *straction = NSStringFromSelector(action);
    NSString *allowactions = @"copy:,delete:";
    NSRange range = [allowactions rangeOfString:straction];
    
    return range.location!=NSNotFound;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)copy:(id)sender{
    [[UIPasteboard generalPasteboard] setString:message.content];
}

- (void)delete:(id)sender{
    [[SWDataProvider managedObjectContext] deleteObject:message];
    [[SWDataProvider managedObjectContext] save:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)avatarClicked{
//    [delegate showProfile:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",message.user.uid.intValue],@"uid", nil]];
}

@end
