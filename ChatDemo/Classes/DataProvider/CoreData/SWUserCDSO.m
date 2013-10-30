//
//  User.m
//  AiBa
//
//  Created by Stan Wu on 13-2-2.
//
//

#import "SWUserCDSO.h"
#import "SWMessageCDSO.h"
#import "SWDataProvider.h"

@interface SWUserCDSO()

@property (nonatomic) NSData *photos;
@property (nonatomic) NSSet *messages;
@property (nonatomic) NSData *sns;
@end

@implementation SWUserCDSO

@dynamic avatar,nickname,uid,level,birthday,bloodtype,disturb,education,followees,followers,gender,group,height,house,lastvisit,ma_flag,nation,native_city,native_province,newnum,ph_num,pm_privacy,province,city,quiet,salary,username,view_num,wedlock,work,school;
@dynamic lastcontact;

@dynamic messages,photos,sns,requirements;

@dynamic photolist;
@dynamic snsInfo;

- (NSArray *)allMessages{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message"
	                                          inManagedObjectContext:self.managedObjectContext];
	
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user==%@", self];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateline" ascending:YES];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
    NSError *error = nil;
    
	NSArray *ary = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	
	if (error)
    {
		NSLog(@"Error getting unread count: %@, %@", error, [error userInfo]);
	}
    
    
    
	return ary;
}

- (SWMessageCDSO *)lastMessage{
    return nil;//[SWDataProvider messageWithDate:[self lastcontact] ofUser:self];
}

- (int)unread{
    return self.newnum.intValue;
}

- (void)setUnread:(int)unreadnum{
    self.newnum = [NSNumber numberWithInt:unreadnum];
}

- (BOOL)isVIP{
    return self.level.boolValue;
}

- (void)setIsVIP:(BOOL)vip{
    self.level = [NSNumber numberWithInt:vip?1:0];
}

+ (SWUserCDSO *)userWithProfile:(NSDictionary *)info{
    SWUserCDSO *user = [SWDataProvider userofUID:[[info objectForKey:@"uid"] intValue]];
    
    if (!user)
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[SWDataProvider managedObjectContext]];
    
    [user updateProfile:info];
    
    [[SWDataProvider managedObjectContext] save:nil];
    
    return user;
}

- (void)updateProfile:(NSDictionary *)profile{
    self.uid = [NSNumber numberWithInt:[[profile objectForKey:@"uid"] intValue]];
    
    self.avatar = [profile objectForKey:@"avatar"];
    self.nickname = [profile objectForKey:@"nickname"];
    self.school = [profile objectForKey:@"school"];
    
    self.bloodtype = [NSNumber numberWithInt:[[profile objectForKey:@"bloodtype"] intValue]];
    self.disturb = [NSNumber numberWithInt:[[profile objectForKey:@"disturb"] intValue]];
    self.education = [NSNumber numberWithInt:[[profile objectForKey:@"education"] intValue]];
    self.followees = [NSNumber numberWithInt:[[profile objectForKey:@"followees"] intValue]];
    self.followers = [NSNumber numberWithInt:[[profile objectForKey:@"followers"] intValue]];
    
    self.gender = [NSNumber numberWithInt:[[profile objectForKey:@"gender"] intValue]];
    self.group = [NSNumber numberWithInt:[[profile objectForKey:@"group"] intValue]];
    self.height = [NSNumber numberWithInt:[[profile objectForKey:@"height"] intValue]];
    self.house = [NSNumber numberWithInt:[[profile objectForKey:@"house"] intValue]];
    self.isVIP = [[[profile objectForKey:@"vip"]objectForKey:@"valid"] boolValue];
    self.ma_flag = [NSNumber numberWithInt:[[profile objectForKey:@"ma_flag"] intValue]];
    self.nation = [NSNumber numberWithInt:[[profile objectForKey:@"nation"] intValue]];
    self.native_province = [NSNumber numberWithInt:[[profile objectForKey:@"native_province"] intValue]];
    self.native_city = [NSNumber numberWithInt:[[profile objectForKey:@"native_city"] intValue]];
    self.work = [NSNumber numberWithInt:[[profile objectForKey:@"work"] intValue]];
    
    self.ph_num = [NSNumber numberWithInt:[[profile objectForKey:@"ph_num"] intValue]];
    self.pm_privacy = [NSNumber numberWithInt:[[profile objectForKey:@"pm_privacy"] intValue]];
    self.province = [NSNumber numberWithInt:[[profile objectForKey:@"province"] intValue]];
    self.city = [NSNumber numberWithInt:[[profile objectForKey:@"city"] intValue]];
    self.quiet = [NSNumber numberWithInt:[[profile objectForKey:@"quiet"] intValue]];
    self.salary = [NSNumber numberWithInt:[[profile objectForKey:@"salary"] intValue]];
    self.view_num = [NSNumber numberWithInt:[[profile objectForKey:@"view_num"] intValue]];
    self.wedlock = [NSNumber numberWithInt:[[profile objectForKey:@"wedlock"] intValue]];
    
    self.photolist = [profile objectForKey:@"photolist"];
    self.snsInfo = [profile objectForKey:@"sns"];
    
    self.birthday = [NSDate dateWithTimeIntervalSince1970:[[profile objectForKey:@"birthday"] doubleValue]];
    self.lastvisit = [NSDate dateWithTimeIntervalSince1970:[[profile objectForKey:@"lastvisit"] doubleValue]];
    
//    self.requirements = [SWRequirementsCDSO requirementsWithMateInfo:[profile objectForKey:@"mate_info"] user:self];
    
    
    [[SWDataProvider managedObjectContext] save:nil];
}


- (NSArray *)photolist{
    NSArray *list = self.photos?[NSKeyedUnarchiver unarchiveObjectWithData:self.photos]:nil;
    
    return list;
}

- (void)setPhotolist:(NSArray *)list{
    self.photos = list.count>0?[NSKeyedArchiver archivedDataWithRootObject:list]:nil;
}

- (NSDictionary *)snsInfo{
    NSDictionary *dict = self.sns?[NSKeyedUnarchiver unarchiveObjectWithData:self.sns]:nil;
    
    return dict;
}

- (void)setSnsInfo:(NSDictionary *)dict{
    self.sns = dict?[NSKeyedArchiver archivedDataWithRootObject:dict]:nil;
}

@end
