//
//  SWGroupCDSO.m
//  ChatDemo
//
//  Created by Stan Wu on 13-11-5.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "SWGroupCDSO.h"

@interface SWGroupCDSO()

@property (nonatomic) NSSet *users;

@end

@implementation SWGroupCDSO
@dynamic name,users,memberList;

- (NSArray *)memberList{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group"
	                                          inManagedObjectContext:self.managedObjectContext];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group==%@", self];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateline" ascending:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
    NSError *error = nil;
    
	NSArray *ary = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	
	if (error)
    {
		NSLog(@"Error getting unread count: %@, %@", error, [error userInfo]);
	}
    
    
    
	return ary;
}

@end
