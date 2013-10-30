//
//  SWDataProvider.m
//  ChatDemo
//
//  Created by Stan Wu on 13-10-30.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "SWDataProvider.h"
#import "CDAppDelegate.h"

@implementation SWDataProvider

+ (NSDictionary *)myInfo{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"demo0",@"username", nil];
}

+ (NSString *)myUID{
    return @"demo0";
}

+ (NSDictionary *)getMyProfile{
    return nil;
}

#pragma mark - Core Data
+ (NSManagedObjectContext *)managedObjectContext{
    CDAppDelegate *appdelegate = (CDAppDelegate *)[UIApplication sharedApplication].delegate;
    
    return appdelegate.managedObjectContext;
}

@end
