//
//  XMPPWorker.h
//  AiBa
//
//  Created by Stan Wu on 4/23/13.
//
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

#define kChatServer     @"chat.aiba.com"
#define kChatServerDomain   @"chat.aiba.com"

@interface XMPPWorker:NSObject<XMPPStreamDelegate,XMPPReconnectDelegate,XMPPAutoPingDelegate>{
    
}
@property (nonatomic,strong) NSString *chatUID;

+ (XMPPStream *)xmppStream;
+ (XMPPWorker *)sharedWorker;

+ (void)sendMessage:(NSString *)msg toUser:(NSString *)uid;
+ (void)sendMessage:(NSString *)msg toUser:(NSString *)uid paid:(BOOL)paid;
+ (void)sendFakeMessage:(NSString *)msg fromUser:(NSString *)uid;

+ (void)checkAndConnect;
+ (BOOL)connect;
+ (void)disconnect;

+ (void)initialMessageCenter;
+ (void)blockUser:(NSString *)uid;
+ (void)unblockUser:(NSString *)uid;

@end
