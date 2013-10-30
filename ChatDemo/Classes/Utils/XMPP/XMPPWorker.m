//
//  XMPPWorker.m
//  AiBa
//
//  Created by Stan Wu on 4/23/13.
//
//

#import "XMPPWorker.h"
#import "SWDataProvider.h"
#import <CoreData/CoreData.h>
#import "SWUserCDSO.h"
#import "SWMessageCDSO.h"
#import "XMPPWorkerPrivacy.h"

static XMPPStream *xmppStream;
static XMPPWorker *sharedWorker;
static XMPPWorkerPrivacy *xmppPrivacy;
static XMPPReconnect *xmppReconnect;
static XMPPAutoPing *xmppAutoPing;

@implementation XMPPWorker
@synthesize chatUID;

+ (XMPPStream *)xmppStream{
    if (!xmppStream){
        [XMPPWorker connect];
    }
    
    return xmppStream;
}

+ (XMPPWorker *)sharedWorker{
    if (!sharedWorker)
        sharedWorker = [[super allocWithZone:NULL] init];
    
    return sharedWorker;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedWorker];
}

+ (void)getBlackList{
//    NSLog(@"Privacy List:%@",[xmppPrivacy listNames]);
//    [XMPPPrivacy ]
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
//    [iq addAttributeWithName:@"id" stringValue:@"getlist1"];
//    [iq addChild:[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"]];
//    [xmppStream sendElement:iq];
    [xmppPrivacy getBlackList];
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:@"getlist2"];
//    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
//    [query addChild:[NSXMLElement elementWithName:@"list" children:nil attributes:[NSArray arrayWithObject:[NSXMLElement attributeWithName:@"name" stringValue:@"blacklist"]]]];
//    
//    [[XMPPWorker xmppStream] sendElement:iq];
}

+ (void)sendMessage:(NSString *)msg toUser:(NSString *)uid{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msg];
    
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",uid,kChatServerDomain]];
    [message addChild:body];
    
    [xmppStream sendElement:message];
}

+ (void)sendMessage:(NSString *)msg toUser:(NSString *)uid paid:(BOOL)paid{    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:msg];
    if (paid)
        [body addAttributeWithName:@"paid" stringValue:@"1"];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",uid,kChatServerDomain]];
    [message addChild:body];
    
    [xmppStream sendElement:message];
}

+ (void)sendFakeMessage:(NSString *)msg fromUser:(NSString *)uid{
    if (![uid isEqualToString:[SWDataProvider myUID]]){
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:msg];
        [message addChild:body];
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@chat.aiba.com",uid]];
        
        [[XMPPWorker sharedWorker] xmppStream:nil didReceiveMessage:(XMPPMessage *)message];
    }
}

+ (void)setupStream{
    if (!xmppStream){
        xmppStream = [[XMPPStream alloc] init];
        
        xmppPrivacy = [[XMPPWorkerPrivacy alloc] init];
        [xmppPrivacy activate:xmppStream];
        
        xmppReconnect = [[XMPPReconnect alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        [xmppReconnect addDelegate:[XMPPWorker sharedWorker] delegateQueue:dispatch_get_main_queue()];
        [xmppReconnect activate:xmppStream];
        
        xmppAutoPing = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        xmppAutoPing.pingInterval = 15;
        xmppAutoPing.pingTimeout = 10;
        [xmppAutoPing addDelegate:[XMPPWorker sharedWorker] delegateQueue:dispatch_get_main_queue()];
        [xmppAutoPing activate:xmppStream];
        
        [xmppStream addDelegate:[XMPPWorker sharedWorker] delegateQueue:dispatch_get_main_queue()];
    }
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
}

+ (void)checkAndConnect{
    if (![SWDataProvider myInfo])
        return;
    [[MTStatusBarOverlay sharedInstance] postMessage:@"正在连接..."];

    sw_dispatch_async_on_background_thread(^{
        [XMPPWorker checkLoginStatus];
    });
}

+ (void)checkLoginStatus{
    @autoreleasepool {
        NSDictionary *dict = [SWDataProvider getMyProfile];
        if (![dict objectForKey:@"error"] && [dict objectForKey:@"data"]){
            
            sw_dispatch_sync_on_main_thread(^{
                [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"连接成功" duration:.01f];
                [XMPPWorker connect];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadPromptsFromBG object:nil];
            });
            
        }else{
            sw_dispatch_sync_on_main_thread(^{
                [[MTStatusBarOverlay sharedInstance] postErrorMessage:@"连接失败" duration:.01f];
                [[MTStatusBarOverlay sharedInstance] hide];
            });
        }
        
//        dict = [dp getAiBaConfig:nil];
    }
}

+ (BOOL)connect{
    if (![SWDataProvider myInfo])
        return NO;
    
    [XMPPWorker setupStream];
    
    if (![xmppStream isDisconnected])
        return YES;
    
    xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/iphone",[[SWDataProvider myInfo] objectForKey:@"uid"],kChatServerDomain]];
    xmppStream.hostName = kChatServer;
    
    NSError *error = nil;
    if (![xmppStream connect:&error]){
        NSLog(@"XMPP Error:%@",error);
        return NO;
    }
    
    return YES;
    
}

+ (void)disconnect{
    NSLog(@"XMPP Disconnected");
    [xmppStream disconnect];
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[xmppStream sendElement:presence];
    
    [XMPPWorker getBlackList];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
}

+ (void)blockUser:(NSString *)uid{
    [xmppPrivacy blockUser:uid];
    
    sw_dispatch_sync_on_main_thread(^{
        SWUserCDSO *user = [SWDataProvider userofUID:[uid intValue]];
        if (user){
            [[SWDataProvider managedObjectContext] deleteObject:user];
            [[SWDataProvider managedObjectContext] save:nil];
        }
    });
}

+ (void)unblockUser:(NSString *)uid{
    [xmppPrivacy unblockUser:uid];
}

#pragma mark - XMPP Delegate
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"Disconnected:%@",error);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"Connected");
    
    NSError *error = nil;
    [xmppStream authenticateWithPassword:@"aibachat" error:&error];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"Loginned");
    [self goOnline];
    [XMPPWorker initialMessageCenter];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"Login Error:%@",error);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *type = [message attributeStringValueForName:@"type"];
//    NSLog(@"Message:%@",message);
    NSXMLElement *body = [message elementForName:@"body"];
    BOOL paid = [body attributeBoolValueForName:@"paid"];
    if ([type isEqualToString:@"chat"] && body){
        NSString *from = [message attributeStringValueForName:@"from"];
        NSString *uid = [[from componentsSeparatedByString:@"@"] objectAtIndex:0];
        
        NSDate *dateline = nil;
        NSArray *children = [message children];
        for (NSXMLElement *child in children){
            if ([child.name isEqualToString:@"delay"]){
                NSString *stamp = [child attributeStringValueForName:@"stamp"];
                if (stamp){
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"];
                    dateline = [formatter dateFromString:stamp];                    
                    NSInteger currentGMTOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
                    dateline = [dateline dateByAddingTimeInterval:currentGMTOffset];
                }
                
            }
        }

        
        if (!dateline)
            dateline = [NSDate date];
        
        
        NSString *content = [[message elementForName:@"body"] stringValue];
        
        sw_dispatch_sync_on_main_thread(^{
            SWUserCDSO *user = [SWDataProvider userofUID:[uid intValue]];
            if (user){
                if (!chatUID || ![chatUID isEqualToString:uid])
                    user.newnum = [NSNumber numberWithInt:user.newnum.intValue+1];
                else
                    user.newnum = [NSNumber numberWithInt:0];
                if (paid)
                    user.pm_privacy = [NSNumber numberWithInt:1];
                
                SWMessageCDSO *msg = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:[SWDataProvider managedObjectContext]];
                
                msg.content = content;
                msg.dateline = dateline;
                msg.user = user;
                msg.outbound = [NSNumber numberWithBool:NO];
                
                if (!user.lastcontact || [msg.dateline timeIntervalSinceDate:user.lastcontact]>0)
                    user.lastcontact = msg.dateline;
                
                NSXMLElement *body = [message elementForName:@"body"];
                if ([body attributeStringValueForName:@"uid"]){
                    NSString *relativeUID = [body attributeStringValueForName:@"uid"];
                    NSString *relativeNickname = [body attributeStringValueForName:@"nickname"];
                    SWUserCDSO *relative = [SWDataProvider userofUID:[relativeUID intValue]];
                    if (!relative){
                        relative = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[SWDataProvider managedObjectContext]];
                        relative.uid = [NSNumber numberWithInt:[relativeUID intValue]];
                        relative.nickname = relativeNickname;
                    }
                    msg.relative = relative;
                }
                
                [[SWDataProvider managedObjectContext] save:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshPrompts object:nil];
            }else{
                [NSThread detachNewThreadSelector:@selector(loadProfileForMessage:) toTarget:self withObject:message];
            }
        });
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *type = [presence attributeStringValueForName:@"type"];
    if ([type isEqualToString:@"subscribe"]){
        XMPPJID *jid = [XMPPJID jidWithString:[presence attributeStringValueForName:@"from"]];
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"subscribed" to:[jid bareJID]];
        [xmppStream sendElement:presence];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    return YES;
}


#pragma mark - Message Received Action
- (void)loadProfileForMessage:(XMPPMessage *)message{
    @autoreleasepool {
        NSString *from = [message attributeStringValueForName:@"from"];
        NSString *uid = [[from componentsSeparatedByString:@"@"] objectAtIndex:0];
        NSString *content = [[message elementForName:@"body"] stringValue];
        
        NSDate *dateline = nil;
        NSArray *children = [message children];
        for (NSXMLElement *child in children){
            if ([child.name isEqualToString:@"delay"]){
                NSString *stamp = [child attributeStringValueForName:@"stamp"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"];
                dateline = [formatter dateFromString:stamp];
                NSInteger currentGMTOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
                dateline = [dateline dateByAddingTimeInterval:currentGMTOffset];
            }
        }
        
        if (!dateline)
            dateline = [NSDate date];
        
//        ABParamInfo *paramInfo = [[ABParamInfo alloc] init];
//        paramInfo.parameters = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uid", nil];
        NSDictionary *dict = nil;//[[[SWDataProvider sharedInstance] getProfile:paramInfo] objectForKey:@"data"];
        if (dict){
            sw_dispatch_sync_on_main_thread(^{
                SWUserCDSO *user = [SWUserCDSO userWithProfile:dict];
                if (!chatUID || ![chatUID isEqualToString:uid])
                    user.newnum = [NSNumber numberWithInt:user.newnum.intValue+1];
                else
                    user.newnum = [NSNumber numberWithInt:0];
                                
                SWMessageCDSO *msg = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:[SWDataProvider managedObjectContext]];
                
                msg.content = content;
                msg.dateline = dateline;
                msg.user = user;
                msg.outbound = [NSNumber numberWithBool:NO];
                
                if (!user.lastcontact || [msg.dateline timeIntervalSinceDate:user.lastcontact]>0)
                    user.lastcontact = msg.dateline;
                
                NSXMLElement *body = [message elementForName:@"body"];
                if ([body attributeStringValueForName:@"uid"]){
                    NSString *relativeUID = [body attributeStringValueForName:@"uid"];
                    NSString *relativeNickname = [body attributeStringValueForName:@"nickname"];
                    SWUserCDSO *relative = [SWDataProvider userofUID:[relativeUID intValue]];
                    if (!relative){
                        relative = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[SWDataProvider managedObjectContext]];
                        relative.uid = [NSNumber numberWithInt:[relativeUID intValue]];
                        relative.nickname = relativeNickname;
                    }
                    msg.relative = relative;
                }
                
                [[SWDataProvider managedObjectContext] save:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshPrompts object:nil];
            });
        }
        
    }
}

#pragma mark - Other Actions
+ (void)initialMessageCenter{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:[SWDataProvider managedObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid!=%@ && uid>0 && lastcontact>%@",[SWDataProvider myUID],[NSDate dateWithTimeIntervalSince1970:0]]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray *users = [[SWDataProvider managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    BOOL bMessagesInserted = [[NSUserDefaults standardUserDefaults] boolForKey:@"MessagesInserted"];
    if (0==users.count && !bMessagesInserted){
        NSArray *messages = [NSArray arrayWithContentsOfFile:[@"messages.plist" bundlePath]];
        
        for (NSDictionary *msg in messages){
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[msg objectForKey:@"content"]];
            [message addChild:body];
            
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@chat.aiba.com",[msg objectForKey:@"uid"]]];
            
            [[XMPPWorker sharedWorker] xmppStream:nil didReceiveMessage:(XMPPMessage *)message];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MessagesInserted"];
    }
}

#pragma mark - XMPPAutoReconnect Delegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags{
    NSLog(@"XMPP Detected Disconnect");
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags{
    return YES;
}

#pragma mark XMPPAutoPing Delegate
- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender{
    sw_dispatch_sync_on_main_thread(^{
        NSLog(@"XMPP Timeout");
        [XMPPWorker connect];
    });
}

@end
