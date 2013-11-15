//
//  CDMessagesViewController.m
//  ChatDemo
//
//  Created by Stan Wu on 13-10-30.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "SWMessagesViewController.h"
#import "SWDataProvider.h"
#import "SWConversationViewController.h"
#import "SWConversationCDSO.h"

@implementation SWMessagesViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[self fetchedResultsController] performFetch:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    tvList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    tvList.delegate = self;
    tvList.dataSource = self;
    [self.view addSubview:tvList];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"切换账号" style:UIBarButtonItemStyleDone target:self action:@selector(showAccountSelection)];
    self.navigationItem.rightBarButtonItem = item;
    
    item = [[UIBarButtonItem alloc] initWithTitle:@"群聊" style:UIBarButtonItemStyleDone target:self action:@selector(mucClicked)];
    self.navigationItem.leftBarButtonItem = item;
 
    
    if (![SWDataProvider myInfo]){
        [self performSelector:@selector(showAccountSelection) withObject:nil afterDelay:.3f];
    }else{
        self.navigationItem.title = [SWDataProvider myUsername];
        [XMPPWorker checkAndConnect];
    }
}

- (void)mucClicked{
    [XMPPWorker initialMUC];
}

- (void)showAccountSelection{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"选择要登录的账号" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"demo0",@"demo1",@"demo2", nil];
    [as showInView:self.view];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:buttonTitle,@"username",buttonTitle,@"nickname", nil];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"UserInfo"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAccount" object:nil];
}

#pragma mark - UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MessagesListIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }
    
    SWConversationCDSO *conversation = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = conversation.conversationType==SWConversationTypeInstant?conversation.name:conversation.subject;
    cell.detailTextLabel.text = conversation.conversationType==SWConversationTypeInstant?conversation.lastMessage.content:[NSString stringWithFormat:@"%@:%@",conversation.lastMessage.user.username,conversation.lastMessage.content];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[[self fetchedResultsController] sections] objectAtIndex:section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self fetchedResultsController] sections].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SWConversationCDSO *conversation = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    SWConversationViewController *vcPM = [[SWConversationViewController alloc] init];
    vcPM.conversation = conversation;
    [self.navigationController pushViewController:vcPM animated:YES];
}

#pragma mark Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSSortDescriptor *statusSD;
		NSArray *sortDescriptors;
		NSFetchRequest *fetchRequest;
		
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversation"
		                                          inManagedObjectContext:[SWDataProvider managedObjectContext]];
		
        //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@""];
        statusSD = [[NSSortDescriptor alloc] initWithKey:@"dateline" ascending:NO];
//		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username!=%@ && username!=nil &&lastcontact>%@",[SWDataProvider myUsername],[NSDate dateWithTimeIntervalSince1970:0]];
		sortDescriptors = [[NSArray alloc] initWithObjects:statusSD, nil];
		
		fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setFetchBatchSize:20];
		[fetchRequest setEntity:entity];
//        [fetchRequest setPredicate:predicate];
		[fetchRequest setSortDescriptors:sortDescriptors];
		
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (![self isViewLoaded]) return;
	
	[tvList beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if(![self isViewLoaded]) return;
	
	NSLog(@"%@: controllerDidChangeContent", [self class]);
    
    [tvList endUpdates];
    tvList.tableFooterView = nil;
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshPrompts object:nil];
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
            [tvList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                           withRowAnimation:UITableViewRowAnimationFade];
			break;
			
        case NSFetchedResultsChangeDelete:
            [tvList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                           withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[tvList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                           withRowAnimation:UITableViewRowAnimationNone];
			break;
			
        case NSFetchedResultsChangeMove:
            [tvList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                           withRowAnimation:UITableViewRowAnimationFade];
			
			[tvList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                           withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

@end
