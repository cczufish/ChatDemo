//
//  ABWebAgent.m
//  AiBa
//
//  Created by Dream on 11-7-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ABWebAgent.h"
#import <CommonCrypto/CommonDigest.h>
#import <sqlite3.h>

@implementation ABWebAgent

- (id)init{
    self = [super init];
    if (self){
        dicInfo = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apiList" ofType:@"plist"]];
    }
    
    return self;
}

- (id)cacheForAPI:(NSString *)api parameters:(NSString *)parameters{
    NSString *content = [self sqlContentWithCommand:[NSString stringWithFormat:@"select content from cache where api=`%@` and parameters=`%@`",api,parameters]];
    NSDictionary *dict = nil;
    if (content!=nil){
        NSError *error = nil;
        dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[parameters dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:0
                                                                 error:&error];
        if (error)
            NSLog(@"Json Parser Error By SQL:%@",error);
    }
    
    return dict;
}

- (void)cacheData:(id)data forAPI:(NSString *)api parameters:(NSString *)parameters{
    NSString *strdata = [NSString stringWithCString:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil].bytes encoding:NSUTF8StringEncoding];
    
    
    if (strdata){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *updatetime = [formatter stringFromDate:[NSDate date]];
        
        NSString *content = [self sqlContentWithCommand:[NSString stringWithFormat:@"select content from cache where api=`%@` and parameters=`%@`",api,parameters]];
        if (content)
            [self sqlContentWithCommand:[NSString stringWithFormat:@"update cache set content = `%@`,updatetime=%@ where api=`%@` and parameters=`%@`",strdata,updatetime,api,parameters]];
        else
            [self sqlContentWithCommand:[NSString stringWithFormat:@"insert into cache (api,parameters,updatetime,content) values (%@,%@,%@,%@)",api,parameters,updatetime,strdata]];
    }
}

- (id)sqlContentWithCommand:(NSString *)sqlcmd{
    NSString *path = [@"aiba.sqlite" temporaryPath];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle]
                                                        pathForResource:@"aiba"
                                                        ofType:@"sqlite"]
                                                toPath:path
                                                 error:&error];
    //    if (error)
    //        [self performSelector:@selector(crash)];
    
    id ret = nil;
    NSMutableArray *ary = [NSMutableArray array];
    
    sqlite3 *db;
    sqlite3_stmt *stat;
    
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *ckey = (char *)sqlite3_column_name(stat, i);
                    char *cvalue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    
                    if (ckey)
                        strKey = [NSString stringWithUTF8String:ckey];
                    if (cvalue)
                        strValue = [NSString stringWithUTF8String:cvalue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
            sqlite3_finalize(stat);
        }
        
        sqlite3_close(db);
    }
    
    
    if ([ary count]==1){
        NSDictionary *dict = [ary objectAtIndex:0];
        if (1==[dict count])
            ret = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
        else if ([dict count]>1)
            ret = dict;
    }else if ([ary count]>1)
        ret = ary;
    
    
    return ret;
}

- (NSString *)baseUrl:(NSString *)api{
    return [NSString stringWithFormat:@"%@%@",[dicInfo objectForKey:@"baseUrl"],[dicInfo objectForKey:api]];
}

- (NSString *)paramString:(NSArray *)args{
    NSMutableString *strMut = [NSMutableString string];
    
    int count = [args count];
    for (int i=0;i<count;i++){
        [strMut appendString:@"&"];
        [strMut appendString:[args objectAtIndex:i]];
    }
    
    return strMut;
}

- (NSString *)serverUrl:(NSString *)api args:(NSArray *)args{
    NSString *strServer = [dicInfo objectForKey:@"baseUrl"];
    NSString *strAPI = [dicInfo objectForKey:api];
    
    NSMutableString *strMut = [NSMutableString string];
    [strMut appendString:strServer];
    [strMut appendString:strAPI];
    
    int count = [args count];
    for (int i=0;i<count;i++){
        [strMut appendString:@"&"];
        [strMut appendString:[args objectAtIndex:i]];
    }
    
    return strMut;
}

- (NSDictionary *)getData:(NSString *)api args:(NSArray *)args{
    if ([NSThread isMainThread]){
        //  在主线程调用时，取缓存数据
        NSDictionary *dict = (NSDictionary *)[self cacheForAPI:api parameters:[self paramString:args]];
        
        return dict;
    }else{
        //  在后台线程调用时，取实时数据
        NSString *strUrl = nil;
        NSString *strParam = nil;
        NSDictionary *dict = nil;
        NSError *error = nil;
        NSMutableURLRequest *request = nil;
        NSHTTPURLResponse *response = nil;
        NSData *serviceData = nil;
        //   NSDictionary *dicError = nil;
        NSString *strJson = nil;
        @try {
            strUrl = [self baseUrl:api];
            
            
            
            
            
            strParam = [self paramString:args];
            
            
            
            NSURL *url = [NSURL URLWithString:strUrl];
            
            request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            [request setHTTPBody:[NSData dataWithBytes:[strParam UTF8String] length:strlen([strParam UTF8String])]];
            
            // retreive the data using timeout
            serviceData = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
            // 1001 is the error code for a connection timeout
            if (error && [error code] == 1001 ) {
                NSLog( @"Server timeout!" );
            }
            else{
                if (serviceData){
                    strJson = [[NSString alloc] initWithData:serviceData encoding:NSUTF8StringEncoding];
                    dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:serviceData options:0 error:&error];
                }
            }
            
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"parse JSON error:%@",exception);
        }
        @finally {
            
        }
        
        if (dict){
            dict = [NSDictionary dictionaryWithObject:dict forKey:@"data"];
            [self cacheData:dict forAPI:api parameters:[self paramString:args]];
        }
        else if (!dict && strJson){
            dict = [NSDictionary dictionaryWithObject:strJson forKey:@"error"];
        }
        
        
        return dict;
    }
}


@end
