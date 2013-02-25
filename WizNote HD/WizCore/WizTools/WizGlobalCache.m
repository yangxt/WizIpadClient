//
//  WizGlobalCache.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizGlobalCache.h"
#import "WizWorkQueue.h"
#import "WizFileManager.h"
#import "WizTempDataBase.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizNotificationCenter.h"
#import <QuickLook/QuickLook.h>
@interface WizGlobalCache()
- (void) addAbstract:(WizAbstract*)abstract  forKey:(NSString*)key;
- (void) clearCacheForDocument:(NSString *)guid;
@end

@interface WizGlobalCacheGenDocumentAbstractThread : NSThread
{
    WizTempDataBase* db;
}
@end

@implementation WizGlobalCacheGenDocumentAbstractThread

- (id) init
{
    self = [super init];
    if (self) {
        NSString* dbPath = [[WizFileManager shareManager] cacheDbPath];
        db = [[WizTempDataBase alloc] initWithPath:dbPath modelName:@"WizTempDataBaseModel"];
    }
    return self;
}

- (WizAbstract*) generateAbstract:(NSString*)documentGuid accountUserId:(NSString*)accountUserId
{
    if (![[WizFileManager shareManager] prepareReadingEnviroment:documentGuid accountUserId:accountUserId])
    {
        return nil;
    }
    NSString* sourceFilePath = [[WizFileManager shareManager] documentIndexFilePath:documentGuid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return nil;
    }
    NSString* abstractText = nil;
    if ([WizGlobals fileLength:sourceFilePath] < 1024*1024) {

        NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath
                                                    usedEncoding:nil
                                                           error:nil];
        if (sourceStr.length > 1024*50) {
            sourceStr = [sourceStr substringToIndex:1024*50];
        }
        NSString* destStr = [sourceStr htmlToText:200];
        destStr = [destStr stringReplaceUseRegular:@"&(.*?);|\\s|/\n" withString:@""];
        if (destStr == nil || [destStr isEqualToString:@""]) {
            destStr = @"";
        }
        if (WizDeviceIsPad) {
            NSRange range = NSMakeRange(0, 100);
            if (destStr.length <= 100) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
        else
        {
            NSRange range = NSMakeRange(0, 70);
            if (destStr.length <= 70) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
    }
    else
    {
        NSLog(@"the file name is %@",sourceFilePath);
    }
    NSString* sourceImagePath = [[WizFileManager shareManager] documentIndexFilesPath:documentGuid];
    NSArray* imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceImagePath  error:nil];
    NSString* maxImageFilePath = nil;
    int maxImageSize = 0;
    for (NSString* each in imageFiles) {
        NSArray* typeArry = [each componentsSeparatedByString:@"."];
        if ([WizGlobals checkAttachmentTypeIsImage:[typeArry lastObject]]) {
            NSString* sourceImageFilePath = [sourceImagePath stringByAppendingPathComponent:each];
            int fileSize = [WizGlobals fileLength:sourceFilePath];
            if (fileSize > maxImageSize && fileSize < 1024*1024) {
                maxImageFilePath = sourceImageFilePath;
            }
        }
    }
    UIImage* compassImage = nil;
    //
    if (nil != maxImageFilePath) {
        float compassWidth=140;
        float compassHeight = 140;
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:maxImageFilePath];

        if (nil != image)
        {
            if (image.size.height >= compassHeight && image.size.width >= compassWidth) {
                compassImage = [image wizCompressedImageWidth:compassWidth height:compassHeight];
            }
        }
    }

    NSData* imageData = nil;
    if (nil != compassImage) {
        imageData = [compassImage compressedData];
    }
    if (abstractText == nil) {
        abstractText = @"";
    }
    WizAbstract* abstract = [[WizAbstract alloc] init];
    abstract.text = abstractText;
    abstract.image = compassImage;
    return abstract;
}

- (void) main
{
    @autoreleasepool {
        while (true)
        {
            WizGenAbstractWorkObject* workObject = [[WizWorkQueue genAbstractQueue] workObject];
            if (workObject != nil) {
                @autoreleasepool {
                    if (workObject.type == WizGenerateAbstractTypeDelete) {
                        [db deleteAbstractByGUID:workObject.docGuid];
                        [[WizGlobalCache shareInstance] clearCacheForDocument:workObject.docGuid];
                    }
                    else
                    {
                        WizAbstract* abstract = [db abstractOfDocument:workObject.docGuid];
                        if (abstract == nil) {
                            abstract = [self generateAbstract:workObject.docGuid accountUserId:workObject.accountUserId];
                            if (abstract != nil) {
                                [db updateAbstract:abstract.text imageData:[abstract.image compressedData] guid:workObject.docGuid type:@"" kbguid:@""];
                            }
                        }
                        if (abstract != nil) {
                            [[WizGlobalCache shareInstance] addAbstract:abstract forKey:workObject.docGuid];
                        }
                    }
                    
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



//
//
//
//
static NSInteger WizMaxGeneraterAbstractThreadCount = 1;

@implementation WizGlobalCache
- (id) init
{
    self = [super init];
    if (self) {
        for (int i  = 0; i < WizMaxGeneraterAbstractThreadCount; i++) {
            WizGlobalCacheGenDocumentAbstractThread* thread = [[WizGlobalCacheGenDocumentAbstractThread alloc] init];
            [thread start];
        }
    }
    return self;
}
+ (id) shareInstance
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizGlobalCache class]];
    }
}
- (void) addAbstract:(WizAbstract*)abstract  forKey:(NSString*)key
{
    @synchronized(self)
    {
        [self setObject:abstract forKey:key];
    }
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:key forKey:@"guid"];
    [[NSNotificationCenter defaultCenter] postNotificationName:WizGeneraterAbstractMessage object:nil userInfo:userInfo];
}

- (WizAbstract*) abstractForDoc:(NSString*)docGuid accountUserId:(NSString*)accountUserId
{
    WizAbstract* abstract = [self objectForKey:docGuid];
    if (abstract == nil) {
        WizGenAbstractWorkObject* obj = [[WizGenAbstractWorkObject alloc] init];
        obj.docGuid = docGuid;
        obj.accountUserId = accountUserId;
        obj.type = WizGenerateAbstractTypeReload;
        [[WizWorkQueue genAbstractQueue] addWorkObject:obj];
    }
    return abstract;
}
- (void) clearCacheForDocument:(NSString *)guid
{

    @synchronized(self)
    {
        [self removeObjectForKey:guid];
    }
}

@end
