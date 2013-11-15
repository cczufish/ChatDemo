//
//  XMPPWorker.h
//  AiBa
//
//  Created by Stan Wu on 4/23/13.
//
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#define kChatServer     @"222.73.136.117"
#define kChatServerDomain   @"xmppserver"

@class SWConversationCDSO;

@interface XMPPWorker:NSObject<XMPPStreamDelegate,XMPPReconnectDelegate,XMPPAutoPingDelegate>{
    
}
@property (nonatomic,strong) NSString *chatUID;

+ (XMPPStream *)xmppStream;
+ (XMPPWorker *)sharedWorker;

+ (void)sendMessage:(NSString *)msg toConversation:(SWConversationCDSO *)conversation;
+ (void)sendMessage:(NSString *)msg toUser:(NSString *)uid;
+ (void)sendMessage:(NSString *)msg toUser:(NSString *)uid paid:(BOOL)paid;
+ (void)sendFakeMessage:(NSString *)msg fromUser:(NSString *)uid;

+ (void)checkAndConnect;
+ (BOOL)connect;
+ (void)disconnect;

+ (void)initialMessageCenter;
+ (void)blockUser:(NSString *)uid;
+ (void)unblockUser:(NSString *)uid;

#pragma mark - Room
+ (void)initialMUC;

@end
