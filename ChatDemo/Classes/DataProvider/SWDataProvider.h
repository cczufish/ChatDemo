//
//  SWDataProvider.h
//  ChatDemo
//
//  Created by Stan Wu on 13-10-30.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDAppDelegate.h"
#import "SWUserCDSO.h"
#import "SWMessageCDSO.h"

@interface SWDataProvider : NSObject

+ (NSDictionary *)myInfo;
+ (NSString *)myUsername;
+ (NSDictionary *)getMyProfile;

#pragma mark - Core Data
+ (SWUserCDSO *)userofUsername:(NSString *)username;
+ (NSManagedObjectContext *)managedObjectContext;

@end
