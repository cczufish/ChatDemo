//
//  ABPMViewController.h
//  AiBa
//
//  Created by Wu Stan on 12-2-28.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ABPMCell.h"
#import "HPGrowingTextView.h"
#import "SWMessageCDSO.h"
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"
//#import "ABPMTemplateView.h"

#define kMinutesToDivid     10.0f
typedef enum {
    ABPMTipsTypeUploadPhoto,
    ABPMTipsTypeBasicInfo,
    ABPMTipsTypeSina,
    ABPMTipsTypeMatchMaker
}ABPMTipsType;
@class SWUserCDSO;

@protocol ABPMDelegate

- (void)PMPrivacyChanged;

@end

@interface SWConversationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,HPGrowingTextViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,NSFetchedResultsControllerDelegate,XMPPStreamDelegate>{
    UITableView *tvMessages;
    UIView *vInputField,*vTextBG,*vTips,*vCover;
    HPGrowingTextView *tvContent;
    UIButton *btnEmoticonsKeyboard,*btnTipsList,*btnSend;
    UIButton *btnInputField;

    UIImageView *imgvBirds,*imgvArrow;
    
    NSDictionary *dicPeople;
    NSDictionary *dicCurrentPM;
    NSString *strPM;
    BOOL bBeginEdit,bScrolled,bIsLast;
    
    id<ABPMDelegate> __weak delegate;
    
    //  Core Data
    NSFetchedResultsController *fetchedResultsController;
}
@property (nonatomic,strong) NSDictionary *dicPeople;
@property (nonatomic,strong) NSDictionary *dicCurrentPM;
@property (nonatomic,copy) NSString *strPM;
@property BOOL bBeginEdit;
@property (nonatomic,weak) id<ABPMDelegate> delegate;

@property (nonatomic) SWUserCDSO *user;

@end
