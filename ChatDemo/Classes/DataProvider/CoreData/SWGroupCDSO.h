//
//  SWGroupCDSO.h
//  ChatDemo
//
//  Created by Stan Wu on 13-11-5.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SWGroupCDSO : NSManagedObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray *memberList;

@end
