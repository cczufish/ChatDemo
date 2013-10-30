//
//  XMPPWorkerPrivacy.h
//  AiBa
//
//  Created by Stan Wu on 5/30/13.
//
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPWorkerPrivacy : NSObject<XMPPStreamDelegate>{
    NSMutableDictionary *blacklist;
}

- (void)activate:(XMPPStream *)xmppStream;
- (void)getBlackList;

- (void)blockUser:(NSString *)uid;
- (void)unblockUser:(NSString *)uid;

@end
