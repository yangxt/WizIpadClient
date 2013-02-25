//
//  WizDownloadThread.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizDownloadThread.h"
#import "WizWorkQueue.h"
#import "WizSyncKb.h"
#import "WizXmlAccountServer.h"
#import "WizGlobals.h"
#import "WizFileManager.h"
#import "WizNotificationCenter.h"
#import "WizTokenManger.h"
#import "WizGlocalError.h"
@implementation WizDownloadThread
@synthesize sourceType;
- (BOOL) download:(WizDownloadWorkObject*)obj
{
    @autoreleasepool {
        NSError* error = nil;
        WizTokenAndKapiurl* tokenAndUrl = [[WizTokenManger shareInstance] tokenUrlForAccountUserId:obj.accountUserId kbguid:obj.kbguid error:&error];
        if (tokenAndUrl == nil) {
            [WizNotificationCenter OnSyncErrorStatue:obj.objGuid messageType:WizXmlSyncEventMessageTypeDownload error:error];
            return NO;
        }
        WizSyncKb* syncKb = [[WizSyncKb alloc] initWithUrl:[NSURL URLWithString:tokenAndUrl.kApiUrl] token:tokenAndUrl.token kbguid:obj.kbguid accountUserId:obj.accountUserId dbPath:obj.dbPath isUploadOnly:NO userPrivilige:0 isPersonal:NO];
        if ([obj.objType isEqualToString:WizObjectTypeDocument]) {
            if (![syncKb downloadDocument:obj.objGuid filePath:obj.downloadFilePath]) {
                [WizNotificationCenter OnSyncErrorStatue:obj.objGuid messageType:WizXmlSyncEventMessageTypeDownload error:syncKb.kbServer.lastError];
                return NO;
            }
        }
        else if ([obj.objType isEqualToString:WizObjectTypeAttachment])
        {
            if (![syncKb downloadAttachment:obj.objGuid filePath:obj.downloadFilePath]) {
                [WizNotificationCenter OnSyncErrorStatue:obj.objGuid messageType:WizXmlSyncEventMessageTypeDownload error:syncKb.kbServer.lastError];
                return NO;
            }
        }
        return YES;
    }
 
}

- (void) main
{
    while (true) {
        @autoreleasepool {
            BOOL fromMain = NO;
        WizDownloadWorkObject* obj = [[WizWorkQueue downloadWorkQueueMain] workObject];
            fromMain = YES;
        if (sourceType == WizDownloadSourceTypeAll) {
            if (!obj) {
                obj = [[WizWorkQueue downloadWorkQueueBackgroud] workObject];
                fromMain = NO;
            }
        }
        if (obj) {
            if (obj.objGuid == nil) {
                [[WizWorkQueue downloadWorkQueueMain] removeWorkObject:obj];
                break;
            }
            [WizNotificationCenter OnSyncState:obj.objGuid event:WizXmlSyncStateStart messageType:WizXmlSyncEventMessageTypeDownload process:0.0];
            if (![self download:obj]) {
            }
            else
            {
               [WizNotificationCenter OnSyncState:obj.objGuid event:WizXmlSyncStateEnd messageType:WizXmlSyncEventMessageTypeDownload process:1.0];
            }
            if (fromMain) {
               [[WizWorkQueue downloadWorkQueueMain] removeWorkObject:obj];
            }
            else
            {
                [[WizWorkQueue downloadWorkQueueBackgroud] removeWorkObject:obj];
            }

        }
        else
        {
            [NSThread sleepForTimeInterval:0.5];
        }
    }
    }
}
@end
