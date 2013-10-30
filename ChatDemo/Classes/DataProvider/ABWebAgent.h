//
//  ABWebAgent.h
//  AiBa
//
//  Created by Dream on 11-7-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define     kiPhoneSecretToken     @"iphone20111231wfhspr"

@interface ABWebAgent : NSObject {
    NSDictionary *dicInfo;
}

- (NSDictionary *)getData:(NSString *)api args:(NSArray *)args;
@end
