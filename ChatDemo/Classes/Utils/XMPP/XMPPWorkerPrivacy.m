//
//  XMPPWorkerPrivacy.m
//  AiBa
//
//  Created by Stan Wu on 5/30/13.
//
//

#import "XMPPWorkerPrivacy.h"
#import "SWDataProvider.h"

@implementation XMPPWorkerPrivacy

- (id)init{
    self = [super init];
    
    if (self){
        blacklist = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)activate:(XMPPStream *)xmppStream{
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)activateBlacklist{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"active1"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    
    NSXMLElement *active = [NSXMLElement elementWithName:@"active"];
    [active addAttributeWithName:@"name" stringValue:@"blacklist"];
    [query addChild:active];
    [iq addChild:query];
    [[XMPPWorker xmppStream] sendElement:iq];
}

- (void)setBlacklistToDefault{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"default1"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    
    NSXMLElement *active = [NSXMLElement elementWithName:@"default"];
    [active addAttributeWithName:@"name" stringValue:@"blacklist"];
    [query addChild:active];
    [iq addChild:query];
    [[XMPPWorker xmppStream] sendElement:iq];
}

- (void)blockUser:(NSString *)uid{
    int duid = [uid intValue];
    if (9==duid || 18==duid || 140164==duid || 8==duid)
        return;
    
    [blacklist setObject:@"deny" forKey:uid];
    [self updateBlacklist];
}

- (void)unblockUser:(NSString *)uid{
    [blacklist removeObjectForKey:uid];
    [self updateBlacklist];
}

- (void)updateBlacklist{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"msg1"];
    //    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@chat.aiba.com",[SWDataProvider myUID]]];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    [list addAttributeWithName:@"name" stringValue:@"blacklist"];
    
    for (int i=0;i<blacklist.allKeys.count;i++){
        NSString *uid = [blacklist.allKeys objectAtIndex:i];
        
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"type" stringValue:@"jid"];
        [item addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@chat.aiba.com",uid]];
        [item addAttributeWithName:@"action" stringValue:@"deny"];
        [item addAttributeWithName:@"order" stringValue:uid];
        [item addChild:[NSXMLElement elementWithName:@"message"]];
        
        [list addChild:item];
    }
    
    
    
    [query addChild:list];
    [iq addChild:query];
    
    [[XMPPWorker xmppStream] sendElement:iq];
}

- (void)createBlacklist{
    /*
     <iq from='romeo@example.net/orchard' type='set' id='msg1'>
     <query xmlns='jabber:iq:privacy'>
     <list name='message-jid-example'>
     <item type='jid'
     value='tybalt@example.com'
     action='deny'
     order='3'>
     <message/>
     </item>
     </list>
     </query>
     </iq>
     */
    NSString *uid = @"0";
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addAttributeWithName:@"id" stringValue:@"msg1"];
//    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@chat.aiba.com",[SWDataProvider myUID]]];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    NSXMLElement *list = [NSXMLElement elementWithName:@"list"];
    [list addAttributeWithName:@"name" stringValue:@"blacklist"];
    
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"type" stringValue:@"jid"];
    [item addAttributeWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@chat.aiba.com",uid]];
    [item addAttributeWithName:@"action" stringValue:@"allow"];
    [item addAttributeWithName:@"order" stringValue:uid];
    [item addChild:[NSXMLElement elementWithName:@"message"]];
    
    [list addChild:item];
    [query addChild:list];
    [iq addChild:query];
    
    [[XMPPWorker xmppStream] sendElement:iq];
}

- (void)getBlackList{
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:@"getlist2"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:privacy"];
    [query addChild:[NSXMLElement elementWithName:@"list" children:nil attributes:[NSArray arrayWithObject:[NSXMLElement attributeWithName:@"name" stringValue:@"blacklist"]]]];
    [iq addChild:query];
    [[XMPPWorker xmppStream] sendElement:iq];
    
    [self activateBlacklist];
}



#pragma mark - Handle IQ Only
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSString *type = [iq attributeStringValueForName:@"type"];
    NSString *idname = [iq attributeStringValueForName:@"id"];
    
    if ([type isEqualToString:@"error"] && [idname isEqualToString:@"getlist2"]){
        [self createBlacklist];
        [self setBlacklistToDefault];
        [self activateBlacklist];
    }else if ([type isEqualToString:@"result"] && [idname isEqualToString:@"getlist2"]){
        NSXMLElement *query = [iq childElement];
        NSXMLElement *list = [[query children] objectAtIndex:0];
        
        NSArray *items = [list children];
        for (int i=0;i<items.count;i++){
            NSXMLElement *item = [items objectAtIndex:i];
            
            NSString *action = [item attributeStringValueForName:@"action"] ;
            NSString *order = [item attributeStringValueForName:@"order"];
            
            if (order && action)
                [blacklist setObject:action forKey:order];
        }
    }
    
    return YES;
}

@end
