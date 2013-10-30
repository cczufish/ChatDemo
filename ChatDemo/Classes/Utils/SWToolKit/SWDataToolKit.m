//
//  SWDataToolKit.m
//  SWToolKit
//
//  Created by Wu Stan on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWDataToolKit.h"
#import "SWUIToolKit.h"
#import <CoreText/CoreText.h>
#import "SWMessageCDSO.h"
#import "SWUserCDSO.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AdSupport/AdSupport.h>
#import "SWRichLabel.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation NSString(SWExtensions)


- (CGFloat)heightForPM{
    float h = 0;
    
    CGSize size = [SWRichLabel sizeForContent:self font:kPMFont];
    
    h += size.height;
    
    h += 12;
    
    if (h<37)
        h = 37;
    
    h += 5;
    
    return h;
}

- (NSString *)imageCachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

    NSString *imagesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"images"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    NSString *path = [imagesPath stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)temporaryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)bundlePath{
    NSString *path = [[NSBundle mainBundle] pathForResource:self ofType:nil];
    
    return path;
}

- (NSString *)fileName{
    NSArray *ary = [self componentsSeparatedByString:@"/"];
    NSMutableString *fileName = [NSMutableString string];
    
    for (int i=0;i<[ary count];i++)
        [fileName appendString:[ary objectAtIndex:i]];
    
    return fileName;
}

- (int)indexInString:(NSString *)str{
    int dret = 0;
    NSArray *ary = [str componentsSeparatedByString:@","];
    for (int i=0;i<ary.count;i++){
        if ([self isEqualToString:[ary objectAtIndex:i]])
            dret = i;
    }
    
    return dret;
}

- (NSMutableArray *)indexesInString:(NSString *)str{
    NSArray *ary = [self componentsSeparatedByString:@","];
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<ary.count;i++){
        NSString *substr = [ary objectAtIndex:i];
        
        [mut addObject:[NSNumber numberWithInt:[substr indexInString:str]]];
    }
    
    return mut;
}

- (NSString *)stringByResolvingEmotions{
    NSString *result = self;

    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[[^\\[\\]]+\\]"
                                                                      options:0
                                                                        error:nil];
    NSDictionary *emotionsMap = [NSDictionary dictionaryWithContentsOfFile:[@"SWToolKit.bundle/Emoticons/EmoticonsMap.plist" bundlePath]];
    NSArray *chunks = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    for (int i=chunks.count-1;i>=0;i--){
        NSTextCheckingResult *chunk = [chunks objectAtIndex:i];
        int total = chunk.numberOfRanges;
        for (int j=total-1;j>=0;j--){
            NSRange range = [chunk rangeAtIndex:j];
            
            NSString *mark = [self substringWithRange:range];
            NSString *img = [NSString stringWithFormat:@"<img src=\"SWToolKit.bundle/Emoticons/images/%@.png\">",[[emotionsMap objectForKey:@"name"] objectForKey:mark]];
            result = [result stringByReplacingOccurrencesOfString:mark withString:img];
        }
    }
        
    return result;
}

-(NSString *)URLEncode
{
	NSString *str = nil;
    //	$entities = array('%21', '%2A', '%27', '%28', '%29', '%3B', '%3A', '%40', '%26', '%3D', '%2B', '%24', '%2C', '%2F', '%3F', '%25', '%23', '%5B', '%5D');
    //	$replacements = array('!', '*', "'", "(", ")", ";", ":", "@", "&", "=", "+", "$", ",", "/", "?", "%", "#", "[", "]");
	NSArray *replaceArray = [NSArray arrayWithObjects:@"!",@"*",@"'",@"(",@")",@";",@":",@"@",@"&",@"=",@"+",@"$",@",",@"/",@"?",@"%",@"#",@"[",@"]",@" ",@"\"",nil];
	NSArray *codeArray = [NSArray arrayWithObjects:@"%21",@"%2A",@"%27",@"%28",@"%29",@"%3B",@"%3A",@"%40",@"%26",@"%3D",
						  @"%2B",@"%24",@"%2C",@"%2F",@"%3F",@"%25",@"%23",@"%5B",@"%5D",@"%20",@"%22",nil];
    //	NSLog(@"decoded:%@",self);
	str = [self stringByReplacingOccurrencesOfString:[replaceArray objectAtIndex:15] withString:[codeArray objectAtIndex:15]];
	for(int i=0;i<21;i++)
	{
		if(15!=i)
			str = [str stringByReplacingOccurrencesOfString:[replaceArray objectAtIndex:i] withString:[codeArray objectAtIndex:i]];
	}
    
    //	NSLog(@"encoded:%@",str);
	return str;
}

- (BOOL)isValidEmailAddress{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}


+ (NSString *)UUIDString{
    NSString *UUID = nil;
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(identifierForVendor)])
        UUID = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
    else{
        UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
        if (!UUID){
            CFUUIDRef uuidref = CFUUIDCreate(NULL);
            CFStringRef uuidstr = CFUUIDCreateString(NULL, uuidref);
            UUID = (__bridge_transfer NSString *)uuidstr;
            CFRelease(uuidref);
            [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:@"UUID"];
        }
    }

    return UUID;
}



+(NSString *)MACAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
    
        // Release the buffer memory
        free(msgBuffer);
        
        return macAddressString;
    }
    
    // Error...
    NSLog(@"Get Mac Address Failed:%@",errorFlag);
    return nil;
}

- (NSString *)HMACSHA1StringWithKey:(NSString *)key{
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
    NSData *keydata = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *selfdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, [keydata bytes], [key length], [selfdata bytes], [selfdata length], result);
    
    NSMutableString *str = [NSMutableString string];

    for (int i=0;i<CC_SHA1_DIGEST_LENGTH;i++)
        [str appendFormat:@"%02X",result[i]];
    
    return str;
}

#ifdef InAiBa

+ (NSString *)areaForInfo:(NSDictionary *)info{
    int dProvince = [[info objectForKey:@"province"] intValue];
    int dCity = [[info objectForKey:@"city"] intValue];
    NSDictionary *dicProfilePlist = [SWDataProvider profilePlist];
    NSArray *arycities = [dicProfilePlist objectForKey:@"cities"];
    NSArray *aryprovinces = [dicProfilePlist objectForKey:@"provinces"];
    NSString *strprovince = [aryprovinces objectAtIndex:dProvince];
    NSString *strcity = [arycities objectAtIndex:dCity];
    if (0==dCity || [strprovince isEqualToString:@"北京"] || [strprovince isEqualToString:@"上海"] || [strprovince isEqualToString:@"天津"] || [strprovince isEqualToString:@"重庆"])
        strcity = @"";
    
    return [strprovince stringByAppendingString:strcity];
}

+ (NSString *)stringWithInfo:(NSDictionary *)info{

    
    return [NSString stringWithInfo:info seperator:@" " withGender:NO];
    
}

+ (NSString *)stringWithInfo:(NSDictionary *)info seperator:(NSString *)seperator withGender:(BOOL)with{
    NSMutableArray *ary = [NSMutableArray array];
    
    int dgender = [[info objectForKey:@"gender"] intValue];
    NSString *gender = 1==dgender?@"男":(2==dgender?@"女":nil);
    if (with && gender)
        [ary addObject:gender];
    
    int province = [[info objectForKey:@"province"] intValue];
    if (province>0)
        [ary addObject:[NSString areaForInfo:info]];
    
    int height = [[info objectForKey:@"height"] intValue];
    if (height>0)
        [ary addObject:[NSString stringWithFormat:@"%dcm",height]];
    
    NSDictionary *dicProfile = [SWDataProvider profilePlist];
    int education = [[info objectForKey:@"education"] intValue];
    if (education>0)
        [ary addObject:[[dicProfile objectForKey:@"education"] objectAtIndex:education]];
    
    
    NSMutableString *str = [NSMutableString string];
    for (int i=0;i<ary.count;i++){
        if (0!=i)
            [str appendFormat:@" %@ ",seperator];
        
        [str appendString:[ary objectAtIndex:i]];
    }
    
    return str;

}

#endif

@end



@implementation NSArray(SWExtensions)

- (BOOL)shouldLoadMore{
    return [self shouldLoadMoreByPageLimit:20];
}

- (BOOL)shouldLoadMoreByPageLimit:(NSUInteger)pageLimit{
    return (self.count>0 && 0==self.count%pageLimit);
}

@end


@implementation NSDictionary (NSDictionary_Extensions)

- (CGFloat)heightForStatus{
    float len = 245;
    
    CGSize size;
    
    NSString *strContent = [self objectForKey:@"content"];
    size = [strContent sizeWithFont:kContentFont constrainedToSize:CGSizeMake(len, 1000)];
    
    
    float h = size.height+55;
    
    
    NSString *strPicture = [self objectForKey:@"picture"];
    if (strPicture && [strPicture length]>0)
        h += 90;
    
    if (![self objectForKey:@"platform"] && ![self objectForKey:@"comment_count"] && ![self objectForKey:@"distributions"]){
        h -= 20;
    }
    
    if ([[self objectForKey:@"comment_count"] intValue]>0)
        h += 53;
    
    if (h<=56)
        h = 56;
    
    return h;
}

- (CGFloat)heightForCommentMe{
    BOOL hasImage = ([self objectForKey:@"origin_picture"] && [[self objectForKey:@"origin_picture"] length]>0);
    float len = 254;
    float lines;
    CGSize size;
    
    NSString *strContent = [self objectForKey:@"content"];
    size = [strContent sizeWithFont:kContentFont];
    lines = floorf(size.width/len+0.5f)+1;
    
    float h = size.height*lines+50;
    
    
    NSString *retweet = nil;
    if (hasImage)
        retweet = [NSString stringWithFormat:@"@%@:%@...",[self objectForKey:@"origin_nickname"],[self objectForKey:@"origin_content"]];
    else
        retweet = [NSString stringWithFormat:@"@%@:%@",[self objectForKey:@"origin_nickname"],[self objectForKey:@"origin_content"]];
    
    size = [retweet sizeWithFont:kContentFont];
    lines = floorf(size.width/(len-18)+0.5f)+1;
    //        h += 5;
    h += lines*size.height + 14;
    
    //    h += 5;
    
    h -= 20;
    
    
    if (h<=56)
        h = 56;
    
    return h;
}

- (CGFloat)heightForPM{
    float h = 0;
    
    NSString *content = [self objectForKey:@"content"];
    CGSize size = [SWRichLabel sizeForContent:content font:kPMFont];
    
    h += size.height;
    
    h += 12;
    
    if (h<40)
        h = 40;
    
    h += 5;
    
    return h;
}


- (NSString *)addUrl:(NSString *)strText{
    NSString *result = strText;
    
    //    NSArray *ary = [strText componentsSeparatedByString:@"@"];
    
    NSString *substring = strText;
    
    NSRange range;
    
    while ([substring rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location!=NSNotFound) {
        range = [substring rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
        if (range.location<[strText length]-7){
            substring = [substring substringFromIndex:range.location+7];
            NSString *strUrl = [[substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" （）。，：():,[]{}'\"“”"]] objectAtIndex:0];
            
            int cnindex = 0;
            for (int i=0;i<[strUrl length];i++){
                if ([strUrl characterAtIndex:i]>128){
                    cnindex = i;
                    break;
                }
            }
            
            if (cnindex!=0)
                strUrl = [strUrl substringToIndex:cnindex];
            
            
            
            result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://%@",strUrl] withString:@"shoturl" options:NSCaseInsensitiveSearch range:NSRangeFromString([NSString stringWithFormat:@"{0,%d}",[result length]])];
            result = [result stringByReplacingOccurrencesOfString:@"shoturl"  withString:[NSString stringWithFormat:@"<a href='web://%@'>http://%@</a>",[strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],strUrl]];
        }
        else
            break;
    }
    
    substring = result;
    while ([substring rangeOfString:@"@"].location!=NSNotFound) {
        range = [substring rangeOfString:@"@"];
        if (range.location<[strText length]-1){
            substring = [substring substringFromIndex:range.location+1];
            NSString *strAt = [[substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" （）。，：():,[]{}'\"“”"]] objectAtIndex:0];
            result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",strAt] withString:@"atsomeone"];
            result = [result stringByReplacingOccurrencesOfString:@"atsomeone"  withString:[NSString stringWithFormat:@"<a href='profile://aiba.com/%@'>@%@</a>",[strAt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],strAt]];
        }else
            break;
    }
    
    return result;
}

- (NSString *)dateString{
    NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[[self objectForKey:@"dateline"] doubleValue]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:created_date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date1 = [formatter stringFromDate:created_date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"HH:mm"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:created_date];
        if (timeInterval<0)
            timeInterval = 0;
        if (timeInterval>3600){
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",@"今天",strDate];
        }
        else{
            strDate = [NSString stringWithFormat:@"%d分钟前",(int)(timeInterval/60)];
        }
    }else {
        [formatter setDateFormat:@"yyyy-MM-dd 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:created_date]<3600*24){
            [formatter setDateFormat:@"HH:mm"];
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",@"昨天",strDate];
        }else{
            [formatter setDateFormat:@"yyyy"];
            date1 = [formatter stringFromDate:created_date];
            date2 = [formatter stringFromDate:[NSDate date]];
            
            if ([date1 isEqualToString:date2]){
                [formatter setDateFormat:@"MM-dd HH:mm"];
                strDate = [formatter stringFromDate:created_date];
            }
        }
    }
    
    
    return strDate;
}

- (NSString *)htmlString{
    NSDictionary *origin = self;
    
    BOOL bRetweet = (BOOL)[self objectForKey:@"origin"];
    NSDictionary *retweet = nil;
    //    bRetweet = NO;
    if (bRetweet){
        //        NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
        //        for (NSString *key in self.allKeys){
        //            if ([key rangeOfString:@"origin"].location!=NSNotFound){
        //                NSString *newkey = [key stringByReplacingOccurrencesOfString:@"origin" withString:@""];
        //                newkey = [newkey stringByReplacingOccurrencesOfString:@"_" withString:@""];
        //                [mutdict setObject:[self objectForKey:key] forKey:newkey];
        //            }
        //        }
        //        if ([mutdict.allKeys count]>0)
        //            retweet = [NSDictionary dictionaryWithDictionary:mutdict];
        retweet = [self objectForKey:@"origin"];
    }
    
    NSString *strSource = [[self objectForKey:@"platform"] intValue]<=1?@"来自网页版":([[self objectForKey:@"platform"] intValue]==2?@"来自iPhone客户端":@"来自Android客户端");
    NSMutableString *strMut = [NSMutableString string];
    if (retweet){
        //original text
        [strMut appendFormat:@"<div class=\"content_text\">%@</div>",[self addUrl:[origin objectForKey:@"content"]]];
        [strMut appendString:@"<div class=\"pop_top\"></div><div class=\"pop_middle\">"];
        //retweet text
        [strMut appendString:[self addUrl:[NSString stringWithFormat:@"@%@:%@",[retweet objectForKey:@"nickname"],[retweet objectForKey:@"content"]]]];
        //retweet image
        if ([retweet objectForKey:@"picture"] && [[retweet objectForKey:@"picture"] length]>0)
            [strMut appendFormat:@"<div id=\"content_pic\"><img id=\"img_loading\" src =\"pic_loading.gif\" width=\"72\" height=\"69\"/><a href=\"pic://%@\"><span id=\"contant_pic\"> <img id=\"img_weibo\" style=\"display:none\" onload='javascript:document.getElementById(\"img_loading\").style.display=\"none\";document.getElementById(\"img_weibo\").style.display=\"block\";' onerror='javascript:document.getElementById(\"img_loading\").style.display=\"none\";' src=\"%@\" /></span></a></div>",[[retweet objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[retweet objectForKey:@"picture"]];
        [strMut appendString:@"</div><div class=\"pop_bottom\"></div><p>&nbsp; </p>"];
        
        
        [strMut appendFormat:@"<p>%@<span>%@</span></p>",[self dateString],strSource];
    }else{
        [strMut appendString:[self addUrl:[origin objectForKey:@"content"]]];
        if ([origin objectForKey:@"picture"] && [[origin objectForKey:@"picture"] length]>0)
            [strMut appendFormat:@"<div id=\"content_pic\"><img id=\"img_loading\" src =\"pic_loading.gif\" width=\"72\" height=\"69\"/><a href=\"pic://%@\"><span id=\"contant_pic\"><img id=\"img_weibo\" style=\"display:none\" onload='javascript:document.getElementById(\"img_loading\").style.display=\"none\";document.getElementById(\"img_weibo\").style.display=\"block\";' onerror='javascript:document.getElementById(\"img_loading\").style.display=\"none\";'  src=\"%@\" /></span></a></div>",[[origin objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[origin objectForKey:@"picture"]];
        [strMut appendString:@"<p>&nbsp; </p>"];
        
        
        [strMut appendFormat:@"<p>%@<span>%@</span></p>",[self dateString],strSource];
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"detail.html" ofType:nil];
    NSString *strDetail = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *ret = [NSString stringWithFormat:strDetail,strMut];
    
    return ret;
    
}



- (NSString *)fileId{
    NSString *fileid = [self objectForKey:@"fileid"];
    if (fileid && fileid.length>0)
        return fileid;
    else
        return nil;
}


@end


@implementation NSDate(SWExtensions)

- (NSString *)dateString{
    NSDate *created_date = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:created_date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date1 = [formatter stringFromDate:created_date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"HH:mm"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self];
        if (timeInterval<0)
            timeInterval = 0;
        if (timeInterval>3600){
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",@"今天",strDate];
        }
        else{
            strDate = [NSString stringWithFormat:@"%d分钟前",(int)(timeInterval/60)];
        }
    }else {
        [formatter setDateFormat:@"yyyy-MM-dd 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:created_date]<3600*24){
            [formatter setDateFormat:@"HH:mm"];
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",@"昨天",strDate];
        }else{
            [formatter setDateFormat:@"yyyy"];
            date1 = [formatter stringFromDate:created_date];
            date2 = [formatter stringFromDate:[NSDate date]];
            
            if ([date1 isEqualToString:date2]){
                [formatter setDateFormat:@"MM-dd HH:mm"];
                strDate = [formatter stringFromDate:created_date];
            }
        }
    }
    
    
    return strDate;
}

- (NSString *)animalString{
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];

    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static int wCurYear,wCurMonth,wCurDay;
    static int nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    
    return szShuXiang;
}

-(NSString *)LunarForSolar:(NSDate *)solarDate{
    //天干名称
    NSArray *cTianGan = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸", nil];
    
    //地支名称
    NSArray *cDiZhi = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
    
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
    
    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                         @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                         @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    
    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static int wCurYear,wCurMonth,wCurDay;
    static int nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:solarDate];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    NSString *szNongli = [NSString stringWithFormat:@"%@(%@%@)年",szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) % 12]];
    
    //生成农历月、日
    NSString *szNongliDay;
    if (wCurMonth < 1){
        szNongliDay = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]];
    }
    else{
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth];
    }
    
    NSString *lunarDate = [NSString stringWithFormat:@"%@ %@月 %@",szNongli,szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];
    
    return lunarDate;
}


@end



@implementation NSData(SWExtensions)

- (NSString *)SHA1String{
    if (!self)
        return nil;
    
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1([self bytes], self.length, result);
    
    NSMutableString *str = [NSMutableString string];
    
    for (int i=0;i<CC_SHA1_DIGEST_LENGTH;i++)
        [str appendFormat:@"%02X",result[i]];
    
    return str;
}

- (NSString *)MD5String{
    if (!self)
        return nil;
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5([self bytes], self.length, result);
    
    NSMutableString *str = [NSMutableString string];
    
    for (int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
        [str appendFormat:@"%02X",result[i]];
    
    return str;
}



@end