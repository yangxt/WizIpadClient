//
//  WizPadAppDelegate.m
//  WizPadClient
//
//  Created by wiz on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadAppDelegate.h"
#import "WizGlobals.h"
#import "WizPadViewController.h"
#import "WizAccountManager.h"
#import "WizSyncCenter.h"

@implementation WizPadAppDelegate


void UncaughtExceptionHandler(NSException *exception)
{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *urlStr = [NSString stringWithFormat:@"错误详情:%@,%@,%@, \n%@\n --------------------------\n%@\n>---------------------\n%@",
                        [[UIDevice currentDevice] systemName]
                        ,[[UIDevice currentDevice] systemVersion]
                        ,[WizGlobals wizNoteVersion], name,reason,[arr componentsJoinedByString:@"\n"]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://mywiz.cn/crash"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[urlStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSError* error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
}

- (void) initRootNavigation
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[WizPadViewController alloc]initWithNibName:@"WizPadViewController" bundle:nil];
    UINavigationController* root = [[UINavigationController alloc]init];
    if ([WizGlobals WizDeviceIsPad]) {
        [root pushViewController:self.viewController animated:NO];
    }
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
//    [[WizAccountManager defaultManager]updateAccount:@"710379419@qq.com" password:@"wzz710379419" personalKbguid:@""];
//    [[WizAccountManager defaultManager]registerActiveAccount:@"710379419@qq.com"];
//    [[WizSyncCenter shareCenter]syncAccount:@"710379419@qq.com" password:@"wzz710379419" isGroup:NO isUploadOnly:NO];
    
    [self initRootNavigation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
