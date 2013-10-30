//
//  ABPMViewController.m
//  AiBa
//
//  Created by Wu Stan on 12-2-28.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import "SWConversationViewController.h"
#import "SWDataProvider.h"
//#import "ABProfileViewController.h"
//#import "ABReportAbuseViewController.h"
#import "SWUserCDSO.h"
#import "SWMessageCDSO.h"
//#import "ABWebViewController.h"
//#import "ABBasicInfoViewController.h"
//#import "ABRechargeViewController.h"
//#import "ABMatchMakerViewController.h"
//#import "ABVIPViewController.h"
//#import "ABSNSViewController.h"
#import "SWConversationCell.h"

@implementation SWConversationViewController
@synthesize dicPeople,dicCurrentPM,strPM,bBeginEdit,delegate;
@synthesize user;

- (void)dealloc{
    [XMPPWorker sharedWorker].chatUID = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)navBack{
    [XMPPWorker sharedWorker].chatUID = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Current Funciton:%@",NSStringFromSelector(_cmd));
    if (!user){
        user = [SWUserCDSO userWithProfile:dicPeople];
        [fetchedResultsController performFetch:nil];
    }
    self.view.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    [XMPPWorker sharedWorker].chatUID = [NSString stringWithFormat:@"%d",user.uid.intValue];
    
//    [self addBGColor:[UIColor colorWithWhite:.95 alpha:1]];
//    
//    [self setNavTitle:user.nickname];
//    [self addNavBack];
    
    tvMessages = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, kViewControllerHeight-46) style:UITableViewStylePlain];
    [self.view addSubview:tvMessages];
    tvMessages.delegate = self;
    tvMessages.dataSource = self;
    tvMessages.backgroundColor = [UIColor clearColor];
    tvMessages.backgroundView.backgroundColor = [UIColor clearColor];
    tvMessages.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self scrollToBottomAnimated:NO];
    if (user.group.intValue<3){
        vInputField = [[UIView alloc] initWithFrame:CGRectMake(0, kViewControllerHeight-46, 320, 46)];
        vInputField.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
        [self.view addSubview:vInputField];
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        line.backgroundColor = [UIColor colorWithWhite:.72 alpha:1];

        [vInputField addSubview:line];
        

        
        btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSend.frame = CGRectMake(320-48, 0, 48, vInputField.frame.size.height);
        btnSend.titleLabel.font = [UIFont systemFontOfSize:15];
        [btnSend setTitleColor:[UIColor colorWithWhite:.55 alpha:1] forState:UIControlStateNormal];
        [btnSend setTitle:@"发送" forState:UIControlStateNormal];
        [vInputField addSubview:btnSend];
        [btnSend addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
        
        btnEmoticonsKeyboard = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEmoticonsKeyboard.frame = CGRectMake(0, 0, 30, 30);
        [btnEmoticonsKeyboard setImage:[UIImage imageNamed:@"ABPMEmoticons.png"] forState:UIControlStateNormal];
        btnEmoticonsKeyboard.center = CGPointMake(19, 23);
        [vInputField addSubview:btnEmoticonsKeyboard];
        [btnEmoticonsKeyboard addTarget:self action:@selector(showEmoticonsKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        btnTipsList = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTipsList.frame = CGRectMake(0, 0, 30, 30);
        [btnTipsList setImage:[UIImage imageNamed:@"ABPMTips.png"] forState:UIControlStateNormal];
        btnTipsList.center = CGPointMake(btnEmoticonsKeyboard.center.x+30, 23);
        [vInputField addSubview:btnTipsList];
//        [btnTipsList addTarget:self action:@selector(showPMTemplate) forControlEvents:UIControlEventTouchUpInside];
        
        tvContent = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(70, 7, 320-70-48, 30)];
        tvContent.isScrollable = NO;
        tvContent.minNumberOfLines = 1;
        tvContent.maxNumberOfLines = 6;
        [vInputField addSubview:tvContent];
        tvContent.backgroundColor = [UIColor clearColor];
        tvContent.font = [UIFont systemFontOfSize:14];
        tvContent.delegate = self;
        tvContent.layer.cornerRadius = 5;
        tvContent.layer.borderWidth = 1;
        tvContent.layer.borderColor = [UIColor colorWithWhite:.87 alpha:1].CGColor;
        tvContent.layer.masksToBounds = YES;
        tvContent.internalTextView.returnKeyType = UIReturnKeySend;
        
        btnInputField = [UIButton buttonWithType:UIButtonTypeCustom];
        btnInputField.frame = tvContent.frame;
        [vInputField addSubview:btnInputField];
        btnInputField.hidden = YES;
        [btnInputField addTarget:self action:@selector(growingTextViewClicked) forControlEvents:UIControlEventTouchUpInside];
        
        if (bBeginEdit)
            [tvContent becomeFirstResponder];
        
 
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    }else{
        tvMessages.frame = CGRectMake(0, 0, 320, kViewControllerHeight-44);
        self.navigationItem.rightBarButtonItems = nil;
    }
    
    [tvMessages setContentOffset:CGPointMake(0, MAX(0, tvMessages.contentSize.height-tvMessages.frame.size.height))];
}








#pragma mark - 私信操作
- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"Current Funciton:%@",NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [tvContent resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)showEmoticonsKeyboard{
    if (!tvContent.internalTextView.isFirstResponder)
        [tvContent becomeFirstResponder];
    
    if (!tvContent.internalTextView.inputView){
        SWEmoticonsKeyboard *keyboard = [[SWEmoticonsKeyboard alloc] init];
        keyboard.inputTextView = tvContent.internalTextView;
        tvContent.internalTextView.inputView = keyboard;
        btnInputField.hidden = NO;
        
        [tvContent.internalTextView reloadInputViews];
    }
}



- (void)growingTextViewClicked{
    if (!tvContent.internalTextView.isFirstResponder)
        [tvContent becomeFirstResponder];
    
    btnEmoticonsKeyboard.selected = NO;
    tvContent.internalTextView.inputView = nil;
    
    
    [tvContent.internalTextView reloadInputViews];
    btnInputField.hidden = YES;
}

- (void)reportAbuseClicked{
    //  拉黑举报
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拉黑",@"拉黑并举报", nil];
    as.tag = 200;
    [as showInView:self.view];
}

#pragma mark -  HPGrowingTextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    float diff = (tvContent.frame.size.height - height);
    
	CGRect r = tvContent.frame;
	r.size.height -= diff;
	tvContent.frame = r;
    
    float y = vInputField.frame.origin.y+vInputField.frame.size.height;
    float h = tvContent.frame.origin.y+tvContent.frame.size.height+5;
    vInputField.frame = CGRectMake(0, y-h, 320, h);
    tvMessages.frame = CGRectMake(0, 0, 320, vInputField.frame.origin.y);
    UIImageView *imgv = (UIImageView *)[vInputField viewWithTag:100];
    imgv.frame = vInputField.bounds;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [self send];
    
    return YES;
}


- (void)send{
//    if (![ABDataProvider networkAvaiable]){
//        [UIAlertView showAlertWithTitle:@"无网络" message:@"请在网络连接正常后再重试" cancelButton:nil];
//        
//        return;
//    }
    
    if ([tvContent.text length]>0){
        [self sendMessage:tvContent.text];
        tvMessages.tableFooterView = nil;
        return;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"内容不能为空."
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)sendMessage:(NSString *)msgContent
{
    SWMessageCDSO *msg = [NSEntityDescription insertNewObjectForEntityForName:@"Message"
												 inManagedObjectContext:[SWDataProvider managedObjectContext]];
	
	msg.content = msgContent;
	msg.isOutbound  = YES;
    msg.messageStatus = ABMessageStatusSending;
	msg.dateline   = [NSDate date];
	msg.user = user;
    
    if (!user.lastcontact || [msg.dateline timeIntervalSinceDate:user.lastcontact]>0)
        user.lastcontact = msg.dateline;

	[[SWDataProvider managedObjectContext] save:nil];
    [XMPPWorker sendMessage:msgContent toUser:user.username paid:user.pm_privacy.intValue>0];
    msg.messageStatus = ABMessageStatusSent;
   
    tvContent.text = @"";
    [tvContent textViewDidChange:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView==tvMessages){
        [tvContent resignFirstResponder];
    }
}



- (void)hideKeyboard{
    [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        tvMessages.frame = CGRectMake(0, 0, 320, self.view.frame.size.height-vInputField.frame.size.height);
        vInputField.frame = CGRectMake(0, self.view.frame.size.height-vInputField.frame.size.height, 320, vInputField.frame.size.height);
        UIImageView *imgv = (UIImageView *)[vInputField viewWithTag:100];
        imgv.frame = vInputField.bounds;
        imgvArrow.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)adjustFrame:(NSNotification *)notification{
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float h = rect.size.height;
    
    float y = self.view.frame.size.height-h-vInputField.frame.size.height;
    
    NSLog(@"Keyboard Height:%f",h);
    
    
    
    [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        tvMessages.frame = CGRectMake(0, 0, 320, y);
        
        vInputField.frame = CGRectMake(0, y, 320, vInputField.frame.size.height);
        UIImageView *imgv = (UIImageView *)[vInputField viewWithTag:100];
        imgv.frame = vInputField.bounds;
    } completion:^(BOOL finished) {
        
    }];
    
    [self performSelector:@selector(delayedScrollToBottomAnimated:)
			   withObject:[NSNumber numberWithBool:YES]
			   afterDelay:0.3];
}

#pragma mark -
#pragma mark UITableView Delegate & Data Source
- (void)delayedScrollToBottomAnimated:(NSNumber *)animated
{
	[self scrollToBottomAnimated:[animated boolValue]];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger numRows = [tvMessages numberOfRowsInSection:0];
    if (numRows > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(numRows-1) inSection:0];
        [tvMessages scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"PMCellIdentifier";
    
    SWConversationCell *cell = (SWConversationCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell){
        cell = [[SWConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIView alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.delegate = self;
    }
    
    BOOL bShowTime = [self shouldDisplayTimeStampForMessageAtIndexPath:indexPath];
    cell.message = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [cell showWithTime:bShowTime];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL bShowTime = [self shouldDisplayTimeStampForMessageAtIndexPath:indexPath];
    SWMessageCDSO *msg = (SWMessageCDSO *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    return [msg.paidContent heightForPM]+(bShowTime?26:0)+5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"Section Count:%d",[[[self fetchedResultsController] sections] count]);
    return [[[self fetchedResultsController] sections] count];
}


- (BOOL)shouldDisplayTimeStampForMessageAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
	{
		// Show interval for first message
		return YES;
	}
    // Otherwise, show stamp if messages are seperated by more than 60 seconds
	NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1)
	                                                    inSection:indexPath.section];
	
	SWMessageCDSO *currentMessage  = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	SWMessageCDSO *previousMessage = [[self fetchedResultsController] objectAtIndexPath:previousIndexPath];
	
    NSDate *currentMessageDate = currentMessage.dateline;
	NSDate *previousMessageDate = previousMessage.dateline;
	
    NSTimeInterval interval = ABS([currentMessageDate timeIntervalSinceDate:previousMessageDate]);
	
	return (interval > 300.0);
}







////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Fetched results controller
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (![self isViewLoaded]) return;
	
	[tvMessages beginUpdates];
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSFetchRequest *fetchRequest;
		
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message"
		                                          inManagedObjectContext:[SWDataProvider managedObjectContext]];
		
        //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@""];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateline" ascending:YES];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user==%@",user];

		
		fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setFetchBatchSize:20];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setPredicate:predicate];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:[SWDataProvider managedObjectContext]
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
        fetchedResultsController.delegate = self;
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
			NSLog(@"%@: Error fetching messages: %@ %@", [self class], error, [error userInfo]);
        }
    }
    
	return fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	if (![self isViewLoaded]) return;
	
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tvMessages insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
			                 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
        case NSFetchedResultsChangeDelete:
            [tvMessages deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
			                 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[tvMessages reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
			                 withRowAnimation:UITableViewRowAnimationNone];
			break;
			
        case NSFetchedResultsChangeMove:
            [tvMessages deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
			                 withRowAnimation:UITableViewRowAnimationFade];
			
			[tvMessages insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
			                 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if(![self isViewLoaded]) return;
	
	NSLog(@"%@: controllerDidChangeContent", [self class]);
    
	[tvMessages endUpdates];
    if (user.pm_privacy.intValue==0){
//        [self showPMTips];
    }else
        tvMessages.tableFooterView = nil;
    
    if (tvMessages.contentOffset.y>=0.5f*tvMessages.frame.size.height)
        [self scrollToBottomAnimated:YES];
    
    user.newnum = [NSNumber numberWithInt:0];
    [[SWDataProvider managedObjectContext] save:nil];
//    [self doneLoadingTableViewData];
}


@end
