//
//  WizPadRegisterViewController.m
//  WizPadClient
//
//  Created by wiz on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadRegisterViewController.h"
#import "WizInputView.h"
#import "WizXmlAccountServer.h"
#import "WizSyncCenter.h"
#import "WizAccountManager.h"

@interface WizPadRegisterViewController ()<WizCreateAccountDelegate>
@end

@implementation WizPadRegisterViewController
@synthesize accountEmail;
@synthesize accountPassword;
@synthesize accountPasswordConfirm;
@synthesize waitAlertView;
@synthesize createDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (WizInputView*) addSubviewByPointY:(float)y
{
    WizInputView* input = [[WizInputView alloc] initWithFrame:CGRectMake(100, y, 320, 40)];
    [self.view addSubview:input];
    return input;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountEmail = [self addSubviewByPointY:40];
    self.accountEmail.textInputField.placeholder = @"example@email.com";
    self.accountEmail.nameLable.text = WizStrEmail;
    self.accountEmail.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountEmail.textInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.accountPassword = [self addSubviewByPointY:120];
    self.accountPassword.textInputField.placeholder = @"password";
    self.accountPassword.textInputField.secureTextEntry = YES;
    self.accountPassword.nameLable.text = WizStrPassword;
    
    self.accountPasswordConfirm = [self addSubviewByPointY:200];
    self.accountPasswordConfirm.textInputField.placeholder = @"password";
    self.accountPasswordConfirm.textInputField.secureTextEntry = YES;
    self.accountPasswordConfirm.nameLable.text = WizStrConfirm;
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 280, 300, 40)];
    
    [registerButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [registerButton setTitle:WizStrRegister forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
}

- (void) cancel
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void) registerAccount
{
    NSString* error = WizStrError;
    NSString* emailString = self.accountEmail.textInputField.text;
    NSString* passwordString = self.accountPassword.textInputField.text;
    NSString* passwordConfirmString = self.accountPasswordConfirm.textInputField.text;
	if (emailString == nil|| [emailString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenteuserid delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		return;
	}
	if (passwordString == nil || [passwordString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterpassword delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		return;
	}
	if (passwordConfirmString == nil || [passwordConfirmString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterthepasswordagain delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		return;
	}
	if (![passwordConfirmString isEqualToString:passwordString])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrThePasswordDontMatch  delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		return;
	}
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:WizStrCreateAccount message:WizStrPleasewaitwhilecreattingaccount delegate:self retView:&alert];
	[alert show];
	//
	self.waitAlertView = alert;
  
    WizXmlAccountServer* accountServer = [[WizXmlAccountServer alloc]initWithUrl:[WizGlobals wizServerUrl]];
    if ([accountServer createAccount:emailString passwrod:passwordString])
    {
        if (self.waitAlertView)
        {
            [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
            self.waitAlertView = nil;
        }
        [self.createDelegate didCreateAccountSucceed:emailString password:passwordString];
        [self dismissModalViewControllerAnimated:NO];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
