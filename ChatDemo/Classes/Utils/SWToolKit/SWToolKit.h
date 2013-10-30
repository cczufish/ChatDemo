//
//  SWToolKit.h
//  SWToolKit
//
//  Created by Wu Stan on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "SWUIToolKit.h"
#import "SWDataToolKit.h"
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#ifndef SWThreadUtil_h
#define SWThreadUtil_h

#define kScreenSize     [[UIScreen mainScreen] bounds]
//#define kScreenHeight   [[[UIScreen mainScreen] bounds] height]
#define kTableViewHeaderHeight      32.0f
#define kTableViewCellHeight        42.0f
#define kBlueColor                  [UIColor colorWithRed:0.1 green:.45 blue:.84 alpha:1]

#define kViewControllerHeight       [UIScreen mainScreen].bounds.size.height-20.0f
#define kViewControllerRealHeight   [UIScreen mainScreen].bounds.size.height-64.0f

static BOOL is_jailbroken(){
    NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

static void sw_dispatch_sync_on_main_thread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static void sw_dispatch_async_on_background_thread(dispatch_block_t block){
    if (![NSThread isMainThread]){
        block();
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),block);
    }
}

static float sw_get_height_for_full_content(){
    float h = [UIScreen mainScreen].bounds.size.height;
    
    return h-20-44;
}

static float sw_get_height_for_center_content(){
    float h = [UIScreen mainScreen].bounds.size.height;
    
    return h-20-44-49;
}

static float sw_get_navigation_bar_height(){
    float version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
        return 64;
    else
        return 44;
}

static void print_memory_usage(){
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %u", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

typedef enum {
    ABGroupDefault,
    ABGroupFake,//  运营账号
    ABGroupBlocked,//   封禁账号
    ABGroupSystem,//    系统账号
    ABGroupOrganization//   机构账号
}ABGroup;

#endif



