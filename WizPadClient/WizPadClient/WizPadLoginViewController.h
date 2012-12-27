//
//  WizPadLoginViewController.h
//  WizPadClient
//
//  Created by wiz on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSyncCenter.h"

@class WizInputView;
@interface WizPadLoginViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    WizInputView* nameInput;
    WizInputView* passwordInput;
    UITableView* existAccountsTable;
    UIAlertView* waitAlertView;
    NSMutableArray* fitAccounts;
}
@property (nonatomic,retain) WizInputView* nameInput;
@property (nonatomic,retain) WizInputView* passwordInput;
@property (nonatomic,retain) UIAlertView* waitAlertView;
@property (nonatomic,retain) UITableView* existAccountsTable;
@property (nonatomic,retain) NSMutableArray* fitAccounts;
@property (nonatomic, assign)id <WizVerifyAccountDelegate> verifyDelegate;
@end
