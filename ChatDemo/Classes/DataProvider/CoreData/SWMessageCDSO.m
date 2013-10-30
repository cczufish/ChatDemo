#import "SWMessageCDSO.h"
#import "SWUserCDSO.h"


@implementation SWMessageCDSO

@dynamic content;
@dynamic status,outbound,dateline;
@dynamic isOutbound,hasBeenRead,isSent;
@dynamic user,relative;
@dynamic paidContent,fullContent;

- (BOOL)isSent
{
    ABMessageStatus msgstatus = [[self status] intValue];
    
    return msgstatus>0;
}

- (void)setIsSent:(BOOL)flag
{
    ABMessageStatus msgstatus = [[self status] intValue];
    if (ABMessageStatusRead!=msgstatus)
        [self setStatus:[NSNumber numberWithInt:flag?ABMessageStatusSent:ABMessageStatusSending]];
}

- (BOOL)isOutbound
{
    return [[self outbound] boolValue];
}

- (void)setIsOutbound:(BOOL)flag
{
    [self setOutbound:[NSNumber numberWithBool:flag]];
}

- (BOOL)hasBeenRead
{
    ABMessageStatus msgstatus = [[self status] intValue];
    
    return (ABMessageStatusRead==msgstatus);
}

- (void)setHasBeenRead:(BOOL)flag
{
	if (flag != [self hasBeenRead])
	{
//		[self.service willChangeValueForKey:@"messages"];
//		
//		[self setRead:[NSNumber numberWithBool:flag]];
//		
//		[self.service didChangeValueForKey:@"messages"];
	}
}

- (ABMessageStatus)messageStatus{
    return (ABMessageStatus)[[self status] intValue];
}

- (void)setMessageStatus:(ABMessageStatus)msgStatus{
    [self setStatus:[NSNumber numberWithInt:msgStatus]];
}

- (NSString *)paidContent{
    if (self.user.pm_privacy.intValue>0 || self.isOutbound)
        return self.content;
    else
        return @"［花费1颗红豆解锁后所有消息可见］";
}

- (NSString *)fullContent{
    if (self.user.pm_privacy.intValue>0 || self.isOutbound)
        return self.content;
    else{
        NSString *str = self.content;
        int len = self.content.length;
        
        if (len<4)
            return @"";
        else if (len<6)
            return [NSString stringWithFormat:@"%@...",[str substringWithRange:NSMakeRange(0, 3)]];
        else
            return [NSString stringWithFormat:@"...%@...",[str substringWithRange:NSMakeRange(len/2, 3)]];
    }
}

@end
