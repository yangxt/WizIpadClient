//
//  WizWorkQueue.m
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import "WizWorkQueue.h"
#import "WizGlobalData.h"
static NSString* const WizKbSyncWokingQueque = @"WizKbSyncWokingQueque";
static NSString* const WizDownloadWokingQueueMain = @"WizDownloadWokingQueueMain";
static NSString* const WizGenerateAbstractWorkingQueue  = @"WizGenerateAbstractWorkingQueue";
static NSString* const WizDownloadWorkingQueueBackgroud = @"WizDownloadWorkingQueueBackgroud";
@implementation WizWorkOjbect
@synthesize key;
@end

@implementation WizSyncKbWorkObject
@synthesize accountUserId;
@synthesize kbguid;
@synthesize isUploadOnly;
@synthesize kApiUrl;
@synthesize token;
@synthesize userPrivilige;
@synthesize dbPath;
@synthesize isPersonal;
@end

@implementation WizDownloadWorkObject
@synthesize downloadFilePath;
@synthesize accountPassword;
@synthesize accountUserId;
@synthesize kbguid;
@synthesize objGuid;
@synthesize objType;
@synthesize dbPath;
@end

@implementation WizGenAbstractWorkObject
@synthesize docGuid;
@synthesize type;
@synthesize accountUserId;
@end

@interface WizWorkQueue ()
{
    NSMutableArray* waitArray;
    NSMutableArray* workingArray;
    NSInteger totalWorkObject;
    NSInteger finishedWorkObject;
}
@end

@implementation WizWorkQueue
+ (WizWorkQueue*) kbSyncWorkQueue
{
    @synchronized(WizKbSyncWokingQueque)
    {
       return [WizGlobalData shareInstanceFor:[WizWorkQueue class] category:WizKbSyncWokingQueque]; 
    }
}

+ (WizWorkQueue*) downloadWorkQueueMain
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizWorkQueue class] category:WizDownloadWokingQueueMain];
    }
}

+ (WizWorkQueue*) downloadWorkQueueBackgroud
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizWorkQueue class] category:WizDownloadWorkingQueueBackgroud];
    }
}

+ (WizWorkQueue*) genAbstractQueue
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizWorkQueue class] category:WizGenerateAbstractWorkingQueue];
    }
}


- (id) init
{
    self = [super init];
    if (self) {
        waitArray = [[NSMutableArray alloc] init];
        workingArray = [[NSMutableArray alloc] init];
        totalWorkObject = 0;
        finishedWorkObject = 0;
    }
    return self;
}
- (NSInteger) indexInWaitingQueue:(WizWorkOjbect*)obj
{
    int i = 0;
    for (; i < [waitArray count]; i++) {
        if ([obj.key isEqualToString:[[waitArray objectAtIndex:i] key]]) {
            return i;
        }
    }
    return NSNotFound;
}
- (NSInteger) indexInWorkingQueue:(WizWorkOjbect*)obj
{
    int i = 0;
    for (; i < [workingArray  count]; i++) {
        if ([obj.key isEqualToString:[[workingArray objectAtIndex:i] key]]) {
            return i;
        }
    }
    return NSNotFound;
}
- (BOOL) hasWorkObjectByKey:(NSString *)key
{
    @synchronized(self)
    {
        for (WizWorkOjbect* each in waitArray) {
            if ([each.key isEqualToString:key])
            {
                return YES;
            }
        }
        for (WizWorkOjbect* each in workingArray) {
            if ([each.key isEqualToString:key]) {
                return YES;
            }
        }
        return NO;
    }

}

- (void) addWorkObject:(WizWorkOjbect*)obj
{
    @synchronized(self)
    {
        int indexOfWait = [self indexInWaitingQueue:obj];
        if (indexOfWait == NSNotFound) {
            if ([self indexInWaitingQueue:obj] == NSNotFound) {
                [waitArray addObject:obj];
                totalWorkObject++;
            }
        }
        else
        {
            id obj = [waitArray objectAtIndex:indexOfWait];
            [waitArray removeObject:obj];
            [waitArray addObject:obj];
        }
    }
}

- (void) addWorkObjects:(NSArray*)array useingCompareBlock:(WizCompareBlock)block
{
    @synchronized(self)
    {
        NSMutableArray* works = [NSMutableArray arrayWithArray:array];
        [works sortUsingComparator:block];
        [waitArray addObjectsFromArray:works];
        totalWorkObject = [waitArray count];
        finishedWorkObject = 0;
    }
}

- (BOOL) hasMoreWorkObject
{
    @synchronized(self)
    {
        if ([waitArray count]) {
            return YES;
        }
        if ([workingArray count]) {
            return YES;
        }
        return NO;
    }
}

- (id) workObject
{
    @synchronized(self)
    {
        if (![waitArray count]) {
            return nil;
        }
        id workObj = [waitArray lastObject];
        [workingArray addObject:workObj];
        [waitArray removeObject:workObj];
        return workObj;
    }
}
- (void) removeAllWorkObject
{
    @synchronized(self)
    {
        [waitArray removeAllObjects];
        [workingArray removeAllObjects];
        finishedWorkObject = 0;
        totalWorkObject = 0;
    }
}
- (void) removeWorkObject:(WizWorkOjbect*)obj
{
    @synchronized(self)
    {
        BOOL hasObject = NO;
        for (id each in workingArray) {
            if ([each  isEqual:obj]) {
                hasObject = YES;
                break;
            }
        }
        if (hasObject) {
            [workingArray removeObject:obj];
            finishedWorkObject++;
            if (finishedWorkObject == totalWorkObject) {
                finishedWorkObject = 0;
                totalWorkObject = 0;
            }
        }
    }
}

- (NSInteger) totalWorkObjectCount
{
    @synchronized(self)
    {
        return totalWorkObject;
    }
}

- (NSInteger) finishedWorkObjectCount
{
    @synchronized(self)
    {
        return finishedWorkObject;
    }
}

- (NSInteger) workingObjectCount
{
    @synchronized(self)
    {
        return [workingArray count] + [waitArray count];
    }
}

@end
