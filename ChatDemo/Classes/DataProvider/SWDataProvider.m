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
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
}

+ (NSString *)myUsername{
    return [[SWDataProvider myInfo] objectForKey:@"username"];
}

+ (NSDictionary *)getMyProfile{
    return nil;
}

#pragma mark - Core Data
+ (SWUserCDSO *)userofUsername:(NSString *)username{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[SWDataProvider managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username==%@",username];
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    
    [fetchRequest setEntity:userEntity];
    [fetchRequest setPredicate:predicate];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchLimit:1];
    
    NSArray *ary = [[SWDataProvider managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    
    if (0==ary.count){
        return nil;
    }else{
        return [ary objectAtIndex:0];
    }
}

+ (NSManagedObjectContext *)managedObjectContext{
    CDAppDelegate *appdelegate = (CDAppDelegate *)[UIApplication sharedApplication].delegate;
    
    return appdelegate.managedObjectContext;
}

@end
