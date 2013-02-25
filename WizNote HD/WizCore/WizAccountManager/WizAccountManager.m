//
//  WizAccountManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountManager.h"
#import "WizFileManager.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizSettings.h"
#import "WizSettingsDataBase.h"

#import "WizObject.h"

#define KeyOfAccounts               @"accounts"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"

#define KeyOfDefaultUserId          @"defaultUserId"
#define KeyOfProtectPassword        @"protectPassword"
#define KeyOfKbguids                @"KeyOfKbguids"
#import "WizNotificationCenter.h"

//
//
static NSString* const WizSettingAccountsArray = @"WizSettingAccountsArray";

static NSString* const KeyOfWizAccountPassword = @"KeyOfWizAccountPassword";
static NSString* const KeyOfWizAccountUserId = @"KeyOfWizAccountUserId";
static NSString* const KeyOfWizAccountPersonalKbguid = @"KeyOfWizAccountPersonalKbguid";
//
//
#define WGDefaultChineseUserName    @"groupdemo@wiz.cn"
#define WGDefaultChinesePassword    @"kk0x5yaxt1ey6v4n"

//
#define WGDefaultEnglishUserName    @"groupdemo@wiz.cn"
#define WGDefaultEnglishPassword    @"kk0x5yaxt1ey6v4n"
NSString* getDefaultAccountUserId()
{
    if ([WizGlobals isChineseEnviroment]) {
        return WGDefaultChineseUserName;
    }
    else
    {
        return WGDefaultEnglishUserName;
    }
}

NSString* getDefaultAccountPassword()
{
    if ([WizGlobals isChineseEnviroment]) {
        return WGDefaultChinesePassword;
    }
    else
    {
        return WGDefaultEnglishPassword;
    }
}
//
NSString* (^WizSettingsGroupsKey)(NSString*) = ^(NSString* accountUserId)
{
   return [@"WizGroupsLocal" stringByAppendingString:accountUserId];
};
//
@interface WizAccount (WizLocal)
- (NSDictionary*) toLocalModel;
- (void) fromLocalModel:(NSDictionary*)dic;
@end
@implementation WizAccount(WizLocal)
- (NSDictionary*) toLocalModel
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.accountUserId) {
        [dic setObject:self.accountUserId forKey:KeyOfWizAccountUserId];
    }
    if (self.password) {
        [dic setObject:self.password forKey:KeyOfWizAccountPassword];
    }
    if (self.personalKbguid) {
        [dic setObject:self.password forKey:KeyOfWizAccountPersonalKbguid];
    }
    return dic;
}
- (void) fromLocalModel:(NSDictionary *)dic
{
    self.accountUserId = dic[KeyOfWizAccountUserId];
    self.password = dic[KeyOfWizAccountPassword];
    self.personalKbguid = dic[KeyOfWizAccountPersonalKbguid];
}
@end
//
@interface WizAccountManager()



@end

@implementation WizAccountManager

- (void) updateAccounts:(NSArray*)array
{
    if (array == nil) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:WizSettingAccountsArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*) allAccounts
{
    NSArray* accounts = [[NSUserDefaults standardUserDefaults] arrayForKey:WizSettingAccountsArray];
    if (accounts == nil) {
        accounts = [NSArray array];
        [self updateAccounts:accounts];
    }
    return accounts;
}

- (NSInteger) indexOfAccount:(NSString*)userId inArray:(NSArray*)array
{
    for (int i = 0 ; i < [array count] ; i++) {
        NSDictionary* each = [array objectAtIndex:i];
        NSString* accountUserId = each[KeyOfWizAccountUserId];
        if ([accountUserId isEqualToString:userId]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void) updateAccount:(NSString *)userId password:(NSString *)passwrod personalKbguid:(NSString *)kbguid
{
    WizAccount* account = [[WizAccount alloc] init];
    account.accountUserId = userId;
    account.password = passwrod;
    account.personalKbguid = kbguid;
    NSDictionary* accountDic = [account toLocalModel];
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount != NSNotFound) {
        [array removeObjectAtIndex:indexOfAccount];
    }
    [array insertObject:accountDic atIndex:0];
    [self updateAccounts:array];
}


- (void) removeAccount:(NSString *)userId
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount != NSNotFound) {
        [array removeObjectAtIndex:indexOfAccount];
    }
    [self updateAccounts:array];
}

- (BOOL) canFindAccount:(NSString *)userId
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self allAccounts]];
    NSInteger indexOfAccount = [self indexOfAccount:userId inArray:array];
    if (indexOfAccount == NSNotFound) {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (WizAccount*) accountFromUserId:(NSString*)userID
{
    NSArray* array = [self allAccounts];
    for (NSDictionary* each in array) {
        if ([each[KeyOfWizAccountUserId] isEqualToString:userID]) {
            WizAccount* account = [[WizAccount alloc] init];
            [account fromLocalModel:each];
            return account;
        }
    }
    return nil;
}

- (NSString*) accountPasswordByUserId:(NSString *)userID
{
    userID = [userID lowercaseString];
    WizAccount* account = [self accountFromUserId:userID];
    return account.password;
}

- (NSArray*)allAccountUserIds
{
    NSArray* array = [self allAccounts];
    NSMutableArray* accountsIDs = [NSMutableArray array];
    for (NSDictionary* each in array) {
        NSString* userID = each[KeyOfWizAccountUserId];
        [accountsIDs addObject:userID];
    }
    return accountsIDs;
}

- (NSInteger) indexOfGroup:(NSString*)kbguid inArray:(NSArray*)array
{
    for (int i = 0; i < [array count]; ++i) {
        NSDictionary* groupModel = [array objectAtIndex:i];
        if ([groupModel[KeyOfKbKbguid] isEqualToString:kbguid]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void) updateGroups:(NSArray*)array accountUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:WizSettingsGroupsKey(userId)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*) groupsLocalForAccount:(NSString *)userId
{
    NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:WizSettingsGroupsKey(userId)];
    if (array == nil) {
        array = [NSArray array];
        [self updateGroups:array accountUserId:userId];
    }
    return array;
}

- (NSArray*) groupsForAccount:(NSString *)userId
{
    NSArray* array = [self groupsLocalForAccount:userId];
    NSMutableArray* groups = [NSMutableArray array];
    for (NSDictionary* each in array) {
        WizGroup* group = [[WizGroup alloc] init];
        [group fromWizServerObject:each];
        group.accountUserId = userId;
        [groups addObject:group];
    }
    return groups;
}

- (WizGroup*) groupFroKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    if (kbguid == nil) {
        WizGroup* group = [[WizGroup alloc] init];
        group.title = NSLocalizedString(@"My Knowlaghe", nil);
        group.userGroup = 0;
        group.guid = nil;
        group.accountUserId = accountUserId;
        return group;
    }
    NSArray* allGroups = [self groupsForAccount:accountUserId];
    for (WizGroup* group in allGroups) {
        if ([group.guid isEqualToString:kbguid]) {
            return group;
        }
    }
    return nil;
}

- (void) updateGroup:(WizGroup *)group froAccount:(NSString *)userId
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self groupsLocalForAccount:userId]];
    NSInteger index = [self indexOfGroup:group.guid inArray:array];
    if (index != NSNotFound) {
        [array removeObjectAtIndex:index];
    }
    [array insertObject:[group toWizServerObject] atIndex:0];
    [self updateGroups:array accountUserId:userId];
}
////
- (void) updateGroups:(NSArray *)groups forAccount:(NSString *)accountUserId
{
    NSMutableArray* array = [NSMutableArray array];
    for (WizGroup* group in groups) {
        NSDictionary* dic = [group toWizServerObject];
        [array addObject:dic];
    }
    [self updateGroups:array accountUserId:accountUserId];
}

- (id) init
{
    self = [super init];
    if (self) {
//        [self updateAccount:WGDefaultChineseUserName password:WGDefaultChinesePassword];
//        [self updateAccount:WGDefaultEnglishUserName password:WGDefaultEnglishPassword];
        [self upgradeAccountSettings];
    }
    return self;
}
+ (id) defaultManager;
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizAccountManager class]];
    }
}

- (NSString*) personalKbguidByUSerId:(NSString *)userId
{
    return [self accountFromUserId:userId].personalKbguid;
}
- (void) updateActiveAccontUserId:(NSString*)userId
{
    return [[WizSettings defaultSettings] updateActiveAccountUserID:userId];
}

- (NSString*) activeAccountUserId
{
    NSString* activeUserId = [[WizSettings defaultSettings] activeAccountUserId];
//    if (activeUserId == nil) {
//        return WGDefaultAccountUserId;
//    }
    return activeUserId;
}
- (void) resignAccount
{
    NSMutableDictionary* activeAccountUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString* preUserId = [self activeAccountUserId];
    if (preUserId) {
       [activeAccountUserInfo setObject:preUserId forKey:@"userId"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resignActiveAccount" object:nil userInfo:activeAccountUserInfo];
    [self updateActiveAccontUserId:WGDefaultAccountUserId];
    //
}
- (void) registerActiveAccount:(NSString *)userId
{
    [self resignAccount];
    [self updateActiveAccontUserId:userId];
    //
    NSMutableDictionary* activeUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    if (userId) {
        [activeUserInfo setObject:userId forKey:@"userId"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerActiveAccount" object:nil userInfo:activeUserInfo];
    
    
}
- (void) upgradeAccountSettings
{
    NSString* dbPath = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"accounts.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {        
        id<WizSettingsDbDelegate> dataBase = [[WizSettingsDataBase alloc]initWithPath:dbPath modelName:@"WizSettingsDataBaseModel"];
        NSArray* accounts = [dataBase allAccounts];
        for (WizAccount* each in accounts) {
            [self updateAccount:each.accountUserId password:each.password personalKbguid:nil];
        }
        NSString* defatultUserId = [dataBase defaultAccountUserId];
        [self updateActiveAccontUserId:defatultUserId];
    }
    [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
}
@end
