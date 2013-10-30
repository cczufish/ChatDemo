//
//  User.h
//  AiBa
//
//  Created by Stan Wu on 13-2-2.
//
//

#import <CoreData/CoreData.h>

typedef enum {
    ABUserGroupDefault,
    ABUserGroupFakeUser,
    ABUserGroupBanned,
    ABUserGroupSystem
}ABUserGroup;

@class SWMessageCDSO;
@class SWRequirementsCDSO;
@interface SWUserCDSO : NSManagedObject
    
@property (nonatomic) NSString *avatar,*nickname,*username,*school;
@property (nonatomic) NSNumber *bloodtype,*disturb,*education,*followees,*followers;
@property (nonatomic) NSNumber *gender,*group,*height,*house,*level,*ma_flag,*nation,*newnum,*native_city,*native_province,*work;
@property (nonatomic) NSNumber *ph_num,*pm_privacy,*province,*city,*quiet,*salary,*uid,*view_num,*wedlock;
@property (nonatomic) NSDate *birthday,*lastvisit,*lastcontact;

@property (nonatomic) SWRequirementsCDSO *requirements;
@property (nonatomic) NSArray *photolist;
@property (nonatomic) NSDictionary *snsInfo;

@property int unread;
@property BOOL isVIP;

- (NSArray *)allMessages;
- (SWMessageCDSO *)lastMessage;
- (void)updateProfile:(NSDictionary *)profile;
+ (SWUserCDSO *)userWithProfile:(NSDictionary *)info;

@end

/*
 animal = 4;
 avatar = "http://www.aiba.com/attach/avatar/000/25/53/63_avatar_big.jpg#rand=366";
 birthday = 593013895;
 bloodtype = 0;
 city = 0;
 constellation = 9;
 distance = "-1";
 disturb = 0;
 education = 3;
 followees = 0;
 followers = 8;
 gender = 2;
 height = 165;
 hot = "\U70ed\U5ea6\U4f4e,\U4f18\U79c0\U6f5c\U529b\U80a1";
 house = 1;
 "info_fill" = 80;
 lastvisit = 1359688878;
 level = 0;
 "ma_flag" = 1;
 "mate_info" =     {
 baby = 0;
 body = 0;
 car = 0;
 child = 0;
 city = 0;
 education = 3;
 house = 2;
 level = 0;
 maxage = 40;
 maxheight = 235;
 minage = 26;
 minheight = 175;
 "native_city" = 0;
 "native_province" = 2;
 photo = 0;
 province = 2;
 salary = 0;
 smoke = 0;
 wedlock = 0;
 wine = 0;
 };
 mblogs = 1;
 nation = 1;
 "native_city" = 0;
 "native_province" = 2;
 nickname = "\U5c0f\U5154\U5b5088";
 personal = 0;
 "ph_num" = 1;
 photolist =     (
 {
 dateline = 1359554820;
 id = 209982;
 pic = "http://www.aiba.com/attach/photo/000/255/363/255363_1359554820Y5nN.jpg";
 "pic_m" = "http://www.aiba.com/attach/photo/000/255/363/255363_1359554820tMb2.jpg";
 "pic_s" = "http://www.aiba.com/attach/photo/000/255/363/255363_1359554820UYiI.jpg";
 sflag = 1;
 title = "255363_1359554820fpOi";
 uid = 255363;
 }
 );
 "pm_privacy" = 1;
 prompts = 0;
 province = 2;
 quiet = 1;
 salary = 3;
 specialty = 0;
 uid = 255363;
 username = "\U5c0f\U5154\U5b5088";
 "view_num" = 70;
 wedlock = 1;
 work = 2;
 year = 1988;

*/