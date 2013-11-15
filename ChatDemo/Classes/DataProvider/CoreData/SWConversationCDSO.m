//
//  SWGroupCDSO.m
//  ChatDemo
//
//  Created by Stan Wu on 13-11-15.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "SWConversationCDSO.h"
#import "SWUserCDSO.h"
#import "SWMessageCDSO.h"
#import "SWDataProvider.h"

@interface SWConversationCDSO()

@property (nonatomic) NSSet *occupants,*messages;

@end

@implementation SWConversationCDSO
@dynamic name,type,dateline,messages,occupants,subject,conversationType,unread;

- (NSArray *)occupantList{
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[self.occupants allObjects]];
    
    return ary;
}

- (NSArray *)allMessages{
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[self.messages allObjects]];
    
    [ary sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
        SWMessageCDSO *msg1 = (SWMessageCDSO *)obj1;
        SWMessageCDSO *msg2 = (SWMessageCDSO *)obj2;
        
        return [msg1.dateline compare:msg2.dateline];
    }];
    
    return ary;
}

- (SWMessageCDSO *)lastMessage{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:[SWDataProvider managedObjectContext]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateline" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversation=%@",self];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    //    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSArray *ary = [[SWDataProvider managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    if (0==ary.count){
        return nil;
    }else{
        return [ary objectAtIndex:0];
        
    }
}

+ (SWConversationCDSO *)conversationWithName:(NSString *)conversationName type:(SWConversationType)conversationType{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:[SWDataProvider managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name=%@) AND (type=%d)",conversationName,conversationType];
    
    [fetchRequest setEntity:userEntity];
    [fetchRequest setPredicate:predicate];
    //    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchLimit:1];
    
    NSArray *ary = [[SWDataProvider managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    if (0==ary.count){
        return nil;
    }else{
        return [ary objectAtIndex:0];
    }
}

- (SWConversationType)conversationType{
    return self.type.intValue;
}

- (void)setConversationType:(SWConversationType)conversationType{
    self.type = [NSNumber numberWithInt:conversationType];
}

- (void)addOccupant:(SWUserCDSO *)user{
    NSMutableSet *set = [NSMutableSet setWithSet:self.occupants];
    [set addObject:user];
    self.occupants = set;
}

@end
