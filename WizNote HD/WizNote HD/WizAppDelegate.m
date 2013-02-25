//
//  WizAppDelegate.m
//  WizNote HD
//
//  Created by dzpqzb on 13-2-22.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import "WizAppDelegate.h"
#import "WizGroupListViewController.h"
@interface ReadViewController : UIViewController

@end

@implementation ReadViewController

@end


@interface WizAppDelegate ()
@property (nonatomic, strong) UINavigationController* rootNavigationController;
@property (nonatomic, strong) UISplitViewController* spilitViewController;
@end
@implementation WizAppDelegate
@synthesize rootNavigationController;
@synthesize spilitViewController;
- (void) didSelectAccountUserId:(NSString*)accountUserId
{
    WizGroupListViewController* groupViewController = [[WizGroupListViewController alloc] init];
    groupViewController.accountID = accountUserId;
    ReadViewController* readController = [[ReadViewController alloc] init];
    [self setSpilitViewControllerMaster:groupViewController detail:readController];
}

- (void) showAccountLogin
{
    
}

- (void) checkDefautlAccount
{
    NSString* userId = @"b@c.d";
    NSString* password = @"e";
    [[WizAccountManager defaultManager] updateAccount:userId password:password personalKbguid:nil];
    [[WizAccountManager defaultManager] registerActiveAccount:userId];
    NSString* defaultAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    if (!defaultAccountUserId || [defaultAccountUserId isEqualToString:@""]) {
        [self showAccountLogin];
   }
    else
    {
        [self didSelectAccountUserId:defaultAccountUserId];
    }
}
- (void) setSpilitViewControllerMaster:(UIViewController*)masterCon detail:(UIViewController*)detailCon
{
    UINavigationController* masterNav = [[UINavigationController alloc] initWithRootViewController:masterCon];
    UINavigationController* detailNav = [[UINavigationController alloc] initWithRootViewController:detailCon];
    self.spilitViewController.viewControllers = @[masterNav, detailNav];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.spilitViewController = [[UISplitViewController alloc] init];
    self.window.rootViewController = self.spilitViewController;
    [self.window makeKeyAndVisible];
    [self checkDefautlAccount];
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
