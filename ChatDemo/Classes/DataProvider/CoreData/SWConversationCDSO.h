//
//  SWGroupCDSO.h
//  ChatDemo
//
//  Created by Stan Wu on 13-11-15.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef enum {
    SWConversationTypeInstant,
    SWConversationTypeGroup
}SWConversationType;

@class SWMessageCDSO;
@class SWUserCDSO;

@interface SWConversationCDSO : NSManagedObject

@property (nonatomic) NSString *name,*subject;
@property (nonatomic) NSNumber *type,*unread;
@property (nonatomic) NSDate *dateline;
@property (nonatomic) SWConversationType conversationType;

- (NSArray *)occupantList;
- (NSArray *)allMessages;
- (SWMessageCDSO *)lastMessage;
+ (SWConversationCDSO *)conversationWithName:(NSString *)conversationName type:(SWConversationType)conversationType;
- (void)addOccupant:(SWUserCDSO *)user;


@end
