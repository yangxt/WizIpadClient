//
//  WizPadViewController.m
//  WizPadClient
//
//  Created by wiz on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadViewController.h"
#import "WizNotificationCenter.h"
#import "WizPadLoginViewController.h"
#import "WizPadRegisterViewController.h"
#import "WizPadDocmentMainViewController.h"
#import "WizAccountManager.h"
#import "WizSyncCenter.h"
#import "WizFileManager.h"


@interface WizPadViewController ()<WizSyncAccountDelegate,WizCreateAccountDelegate,WizVerifyAccountDelegate>

@end

@implementation WizPadViewController
@synthesize loginButton;
@synthesize backgroudView;
@synthesize registerButton;
@synthesize CripytLabel;

- (void) dealloc
{
    [[WizNotificationCenter shareCenter]removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroudView = [[UIImageView alloc]init];
    [self.view addSubview:backgroudView];
    
    self.CripytLabel = [[UILabel alloc]init];
    self.CripytLabel.text = @"Copyright(c) 2012 wiz.cn";
    [CripytLabel setFont:[UIFont systemFontOfSize:14.0]];
    [CripytLabel setBackgroundColor:[UIColor clearColor]];
    self.CripytLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:CripytLabel];
    
    self.loginButton = [[UIButton alloc]init];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.loginButton setTitle:WizStrSignIn forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginViewAppear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    self.registerButton = [[UIButton alloc]init];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.registerButton setTitle:WizStrCreateAccount forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerViewApper:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setFrames:self.interfaceOrientation];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES];
    if (firstLoad) {
   //     [self selecteDefaultAccount];
        firstLoad = NO;
    }
    else {
        [self loginViewAppear:nil];
    }
    
}
- (void) setFrames:(UIInterfaceOrientation)interface
{
    if (UIInterfaceOrientationIsLandscape(interface)) {
        self.backgroudView.frame = CGRectMake(0.0, 0.0, 1024, 768);
        self.backgroudView.image = [UIImage imageNamed:@"Default-Landscape~ipad"];
        self.loginButton.frame = CGRectMake(292, 660, 220, 40);
        self.registerButton.frame = CGRectMake(522, 660, 220, 40);
        self.CripytLabel.frame = CGRectMake(412, 724, 200, 21);
    }
    else
    {
        self.backgroudView.frame = CGRectMake(0.0, 0.0, 768, 1024);
        self.backgroudView.image = [UIImage imageNamed:@"Default-Portrait~ipad"];
        self.loginButton.frame = CGRectMake(160, 875, 220, 40);
        self.registerButton.frame = CGRectMake(390, 875, 220, 40);
        self.CripytLabel.frame = CGRectMake(284, 972, 200, 21);
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        firstLoad = YES;
        [[WizNotificationCenter shareCenter]addSyncAccountObserver:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        firstLoad = YES;
    }
    return self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didSyncAccountSucceed:(NSString *)accountUserId
{
    WizPadDocmentMainViewController* pad = [[WizPadDocmentMainViewController alloc] init];
    
    NSLog(@"pad is %@",pad);
    
    [self.navigationController pushViewController:pad animated:YES];
}

- (void) didSelectedAccount:(NSString*)accountUserId
{
    [[WizAccountManager defaultManager] registerActiveAccount:accountUserId];
//    [[WizFileManager shareManager] accountPathFor:accountUserId];
    [[WizSyncCenter shareCenter]syncAccount:accountUserId password:[[WizAccountManager defaultManager]accountPasswordByUserId:accountUserId] isGroup:NO isUploadOnly:NO];
}

- (void) selecteDefaultAccount
{
    NSString* defaultUserId = [[WizAccountManager defaultManager]activeAccountUserId];
    if (defaultUserId == nil || [defaultUserId isEqualToString:@""]) {
        return;
    }
    [self didSelectedAccount:defaultUserId];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)didVerifyAccountSucceed:(NSString *)userId password:(NSString *)password kbguid:(NSString *)kbguid
{
    [[WizAccountManager defaultManager]updateAccount:userId password:password personalKbguid:nil];
    [[WizAccountManager defaultManager]registerActiveAccount:userId];
    [self didSelectedAccount:userId];
}

- (void) didCreateAccountSucceed:(NSString *)userId password:(NSString *)password
{
    [[WizAccountManager defaultManager]updateAccount:userId password:password personalKbguid:nil];
    [[WizAccountManager defaultManager]registerActiveAccount:userId];
    [self didSelectedAccount:userId];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setFrames:toInterfaceOrientation];
}

- (void)loginViewAppear:(id)sender
{
    WizPadLoginViewController* wizLogin = [[WizPadLoginViewController alloc] init];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:wizLogin];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    wizLogin.verifyDelegate = self;
    [self presentViewController:controller animated:NO completion:^{}];
}
- (void)registerViewApper:(id)sender
{
    WizPadRegisterViewController* wizRegister = [[WizPadRegisterViewController alloc] init];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:wizRegister];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    wizRegister.createDelegate = self;
    [self presentViewController:controller animated:NO completion:^{}];
}

@end
