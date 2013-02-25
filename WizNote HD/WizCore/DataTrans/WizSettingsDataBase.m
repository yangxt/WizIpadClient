//
//  WizSettingsDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-21.
//
//

#import "WizSettingsDataBase.h"
#import "WizAccountManager.h"
#import "WizObject.h"

#define WizGlobalSetting  @"GLOBAL"
#define WizGlobalAccountUserId  @"WizGlobalAccountUserId"


#define KeyOfSyncVersion               @"SYNC_VERSION"
#define DocumentNameOfSyncVersion      @"DOCUMENT"
#define DeletedGUIDNameOfSyncVersion   @"DELETED_GUID"
#define AttachmentVersion              @"ATTACHMENTVERSION"
#define TagVersion                     @"TAGVERSION"
#define UserTrafficLimit               @"TRAFFICLIMIT"
#define UserTrafficUsage               @"TRAFFUCUSAGE"
#define KeyOfUserInfo                  @"USERINFO"
#define UserLevel                      @"USERLEVEL"
#define UserLevelName                  @"USERLEVELNAME"
#define UserType                       @"USERTYPE"
#define UserPoints                     @"USERPOINTS"
#define MoblieView                     @"MOBLIEVIEW"
#define DurationForDownloadDocument    @"DURATIONFORDOWLOADDOCUMENT"
#define WebFontSize                    @"WEBFONTSIZE"
#define DatabaseVesion                 @"DATABASE"
#define ImageQuality                   @"IMAGEQUALITY"
#define ProtectPssword                 @"PROTECTPASSWORD"
#define FirstLog                       @"UserFirstLog"
#define UserTablelistViewOption        @"UserTablelistViewOption"
#define WizNoteAppVerSion              @"wizNoteAppVerSion"
#define ConnectServerOnlyByWif         @"ConnectServerOnlyByWif"
#define AutomicSync                     @"AutomicSync"
#define LastSynchronizedDate            @"LastSynchronizedDate"
#define EditNoteDefaultFolder            @"EditNoteDefaultFolder"
#define DefaultAccountUserID            @"DefaultAccountUserID"
#define DefaultGroupKbGuid              @"DefaultGroupKbGuid"
#define SettingsTypeOfLastSyncDate      @"SettingsTypeOfLastSyncDate"
#define SettingsTypeOfGroupAutoDownload @"SettingsTypeOfGroupAutoDownload"

@implementation WizSettingsDataBase

//- (BOOL) isGroupExist:(NSString*)kbguid accountUserId:(NSString*)accountId
//{
//    __block BOOL succeed = NO;
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet* set = [db executeQuery:@"select * from WizGroup where KB_GUID = ? and KB_ACCOUNT_USERID=?",kbguid,accountId];
//        if ([set next]) {
//            succeed = YES;
//        }
//        [set close];
//    }];
//    return succeed;
//}
//
//- (BOOL) updateGroup:(NSDictionary*)dic  accountUserId:(NSString*)account
//{
//    NSString* guid = [dic valueForKey:KeyOfKbKbguid];
//    NSDate* dateCreated = [dic valueForKey:KeyOfKbDateCreated];
//    NSDate* dateModified = [dic valueForKey:KeyOfKbDateModified];
//    NSDate* dateRoleCreated = [dic valueForKey:KeyOfKbDateRoleCreated];
//    NSString* kbName = [dic valueForKey:KeyOfKbName];
//    NSNumber* userGroup = [dic valueForKey:KeyOfKbRight];
//    NSString* kbNote = [dic valueForKey:KeyOfKbNote];
//    NSNumber* orderIndex = [dic valueForKey:KeyOfKbOrderIndex];
//    NSString* kbType = [dic valueForKey:KeyOfKbType];
//    NSString* ownerName = [dic valueForKey:KeyOfKbOwnerName];
//    if (!guid || [guid isBlock]) {
//        return NO;
//    }
//    if (!userGroup) {
//        userGroup = [NSNumber numberWithInt:WizGroupUserRightAll];
//    }
//    if (!kbName) {
//        kbName = @"Private Knowledge Base";
//    }
//    if (!KeyOfKbType) {
//        kbType = KeyOfKbTypePrivate;
//    }
//    __block BOOL ret;
//    if ([self isGroupExist:guid accountUserId:account]) {
//        [queue inDatabase:^(FMDatabase *db) {
//            ret= [db executeUpdate:@"update WizGroup set KB_NOTE=?, KB_NAME=?, KB_ORDER_INDEX=?, KB_USER_GROUP=?,  KB_TYPE=?, KB_OWNER_NAME=?,  KB_DATE_ROLE_CREATED=?, KB_DATE_CREATED=?,KB_DATE_MODIFIED=? where KB_GUID=? and  KB_ACCOUNT_USERID=? ",kbNote,kbName,orderIndex, userGroup, kbType, ownerName, [dateRoleCreated stringSql], [dateCreated stringSql], [dateModified stringSql], guid, account];
//        }];
//    }
//    else
//    {
//        [queue inDatabase:^(FMDatabase *db) {
//            ret = [db executeUpdate:@"insert into WizGroup ( KB_NOTE, KB_NAME, KB_ORDER_INDEX, KB_USER_GROUP, KB_ACCOUNT_USERID, KB_GUID, KB_TYPE, KB_OWNER_NAME,  KB_DATE_ROLE_CREATED, KB_DATE_CREATED,KB_DATE_MODIFIED) values(?,?,?,?,?,?,?,?,?,?,?)",kbNote,kbName,orderIndex,userGroup, account, guid, kbType, ownerName, [dateRoleCreated stringSql], [dateCreated stringSql], [dateModified stringSql]];
//        }];
//    }
//    return ret;
//}
//
//- (BOOL) updatePrivateGroup:(NSString*)guid accountUserId:(NSString*)userId
//{
//    __block BOOL ret = NO;
//    if ([self isGroupExist:guid accountUserId:userId])
//    {
//        NSLog(@"update");
//        [queue inDatabase:^(FMDatabase *db) {
//            ret = [db executeUpdate:@"update WizGroup set KB_NAME=?, KB_TYPE=?, KB_USER_GROUP=? where KB_GUID=?  and  KB_ACCOUNT_USERID=?",@"Private Knowledge Base", KeyOfKbTypePrivate,[NSNumber numberWithInt:WizGroupUserRightAll],guid,userId];
//        }];
//    }
//    else
//    {
//        [queue inDatabase:^(FMDatabase *db) {
//            ret = [db executeUpdate:@"insert into WizGroup (KB_GUID,KB_NAME,KB_USER_GROUP,KB_TYPE,KB_ACCOUNT_USERID) values(?,?,?,?,?)",guid, @"Private Knowledge Base", [NSNumber numberWithInt:WizGroupUserRightAll],KeyOfKbTypePrivate,userId];
//        }];
//    }
//    return ret;
//}
//
//- (BOOL) updateGroups:(NSArray*)groupsData accountUserId:(NSString*)userId
//{
//    for (NSDictionary* each in groupsData) {
//        if (![self updateGroup:each accountUserId:userId]) {
//            return NO;
//        }
//    }
//    return YES;
//}
//- (NSArray*) groupsWithWhereFiled:(NSString*)whereField args:(NSArray*)args
//{
//    NSString* sql = [NSString stringWithFormat:@"select KB_NOTE, KB_OWNER_NAME, KB_ORDER_INDEX, KB_USER_GROUP, KB_ACCOUNT_USERID, KB_GUID, KB_TYPE,  KB_DATE_ROLE_CREATED, KB_DATE_CREATED,KB_DATE_MODIFIED,KB_NAME from WizGroup %@",whereField];
//    __block NSMutableArray* array = [NSMutableArray array];
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet* result = [db executeQuery:sql withArgumentsInArray:args];
//        while ([result next]) {
//            WizGroup* group = [[WizGroup alloc] init];
//            group.kbNote = [result stringForColumnIndex:0];
//            group.ownerName = [result stringForColumnIndex:1];
//            group.orderIndex = [result intForColumnIndex:2];
//            group.userGroup = [result intForColumnIndex:3];
//            group.accountUserId = [result stringForColumnIndex:4];
//            group.kbguid = [result stringForColumnIndex:5];
//            group.kbType = [result stringForColumnIndex:6];
//            group.dateRoleCreated = [[result stringForColumnIndex:7] dateFromSqlTimeString];
//            group.dateCreated = [[result stringForColumnIndex:8] dateFromSqlTimeString];
//            group.dateModified = [[result stringForColumnIndex:9] dateFromSqlTimeString];
//            group.kbName = [result stringForColumnIndex:10];
//            [array addObject:group];
//            [group release];
//        }
//        [result close];
//    }];
//    return array;
//}
//
//- (WizGroup*) groupFromGuid:(NSString*)kbguid  accountUserId:(NSString*)userId
//{
//    return [[self groupsWithWhereFiled:@"where KB_GUID =? and KB_ACCOUNT_USERID=?" args:[NSArray arrayWithObjects:kbguid,userId, nil]] lastObject];
//}
//- (NSArray*) groupsByAccountUserId:(NSString*)userId
//{
//    return [self groupsWithWhereFiled:@"where KB_ACCOUNT_USERID=?" args:[NSArray arrayWithObject:userId]];
//}
//
//- (BOOL) deleteAccountGroups:(NSString*)userId
//{
//    __block BOOL ret;
//    [queue inDatabase:^(FMDatabase *db) {
//        ret = [db executeUpdate:@"delete from WizGroup where KB_ACCOUNT_USERID=? and KB_TYPE=?",userId,KeyOfKbTypeGroup];
//    }];
//    return ret;
//}

- (NSArray*) accountsWithWhereField:(NSString*)whereField args:(NSArray*)args
{
    NSString* sql = [NSString stringWithFormat:@"select ACCOUNT_PASSWORD, ACCOUNT_USERID from WizAccount %@",whereField];
    __block NSMutableArray* array = [NSMutableArray array];
     FMResultSet* result =[dataBase executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizAccount* account = [[WizAccount alloc] init];
            account.password = [result stringForColumnIndex:0];
            account.accountUserId= [result stringForColumnIndex:1];
            [array addObject:account];
        }
        [result close];
    return array;
}

- (WizAccount*) accountFromUserId:(NSString*)userId
{
    return [[self accountsWithWhereField:@" where ACCOUNT_USERID=?" args:[NSArray arrayWithObject:userId]] lastObject];
}

- (NSArray*) allAccounts
{
    return [self accountsWithWhereField:@"" args:nil];
}



- (NSString*) settingWithWhereField:(NSString*)whereField  args:(NSArray*)args
{
    __block NSString* ret = [NSString string];
        NSString* sql = [NSString stringWithFormat:@"select SETTING_VALUE from WizSetting %@",whereField];
        FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
        if ([result next]) {
            ret = [result stringForColumnIndex:0];
        }
        else
        {
            ret = nil;
        }
        [result close];
    return ret;
}
- (NSString*) settingByKey:(NSString*)userId kbguid:(NSString*)kbguid key:(NSString*)key
{
    NSString* whereFiled = [NSString stringWithFormat:@"where SETTING_USERID = ? and SETTING_KEY = ? and SETTING_KBGUID = ?"];
    return [self settingWithWhereField:whereFiled args:[NSArray arrayWithObjects:userId,key,kbguid, nil]];
}

- (NSString*) userInfo:(NSString*)key
{
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    return [self settingByKey:userId kbguid:WizGlobalSetting key:key];
}

- (int64_t) imageQualityValue
{
    NSString* str = [self userInfo:ImageQuality];
    if(!str)
    {
        [self setImageQualityValue:WizImageQualityOrigin];
        return WizImageQualityOrigin;
    }
    else
        return [str longLongValue];
}

- (BOOL) connectOnlyViaWifi
{
    NSString* wifiStr = [self userInfo:ConnectServerOnlyByWif];
    if (wifiStr == nil) {
        [self setConnectOnlyViaWifi:NO];
        return NO;
    }
    BOOL ret = [wifiStr intValue] == 1? YES: NO;
    return ret;
}

- (NSDate*) lastSynchronizedDate
{
    NSString* dataStr = [self userInfo:LastSynchronizedDate];
    if (nil == dataStr || [dataStr isBlock]) {
        return [NSDate date];
    }
    return [dataStr dateFromSqlTimeString];
}


- (NSString*) globalSetting:(NSString*)key
{
    return [self settingByKey:WizGlobalAccountUserId kbguid:WizGlobalSetting key:key];
}
//
- (NSString*) defaultAccountUserId
{
    NSString* userId = [self globalSetting:DefaultAccountUserID];
    if (userId == nil || [userId isBlock]) {
        return @"";
    }
    return userId;
}

//- (NSString*) defaultGroupKbGuid
//{
//    NSString* group = [self globalSetting:DefaultGroupKbGuid];
//    if (group == nil || [group isBlock]) {
//        return [self privateGroup].kbguid;
//    }
//    return group;
//}
//
//- (BOOL) setDefaultGroupKbGuid:(NSString*)groupGuid
//{
//    if (groupGuid == nil || [groupGuid isBlock]) {
//        return NO;
//    }
//    return [self setUserInfo:DefaultGroupKbGuid info:groupGuid];
//}
@end
