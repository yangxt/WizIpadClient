//
//  WizDBManager.m
//  WizUIDesign
//
//  Created by dzpqzb on 13-1-13.
//  Copyright (c) 2013年 cn.wiz. All rights reserved.
//

#import "WizDBManager.h"
#import "WizFileManager.h"
#import "WizInfoDb.h"
#import "WizTempDataBase.h"
@implementation WizDBManager
+ (id<WizInfoDatabaseDelegate>) getMetaDataBaseForKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSString* dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:accountUserId kbGuid:kbguid];
    WizInfoDb* db = [[WizInfoDb alloc] initWithPath:dbPath];
    return db;
}

+ (id<WizTemporaryDataBaseDelegate>) temoraryDataBase
{
    NSString* dbPath = [[WizFileManager shareManager]  cacheDbPath];
    WizTempDataBase* temp = [[WizTempDataBase alloc] initWithPath:dbPath modelName:@"WizTempDataBaseModel"];
    return temp;
}
@end
