//
//  CDMessagesViewController.h
//  ChatDemo
//
//  Created by Stan Wu on 13-10-30.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SWMessagesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UIActionSheetDelegate>{
    UITableView *tvList;
    
    NSFetchedResultsController *fetchedResultsController;
}

@end
