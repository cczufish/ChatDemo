#import <CoreData/CoreData.h>

@class SWUserCDSO;
@class SWConversationCDSO;

typedef enum{
    ABMessageStatusSending,
    ABMessageStatusFailed,
    ABMessageStatusSent,
    ABMessageStatusRead
}ABMessageStatus;

@interface SWMessageCDSO : NSManagedObject

// Properties

@property (nonatomic) NSString *content;
@property (nonatomic) NSNumber *status,*outbound;
@property (nonatomic) NSDate *dateline;
@property (nonatomic,readonly) NSString *paidContent,*fullContent;
// Relationships

@property (nonatomic) SWUserCDSO *user;
@property (nonatomic) SWConversationCDSO *conversation;

// Convenience Properties

@property (nonatomic, assign) BOOL isOutbound,hasBeenRead,isSent;

- (ABMessageStatus)messageStatus;
- (void)setMessageStatus:(ABMessageStatus)msgStatus;

@end
