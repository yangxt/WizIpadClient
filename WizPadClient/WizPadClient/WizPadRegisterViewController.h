//
//  WizPadRegisterViewController.h
//  WizPadClient
//
//  Created by wiz on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSyncCenter.h"

@class WizInputView;
@interface WizPadRegisterViewController : UIViewController
{
    WizInputView* accountEmail;
    WizInputView* accountPassword;
    WizInputView* accountPasswordConfirm;
    UIAlertView* waitAlertView;
}
@property (nonatomic, retain) WizInputView* accountEmail;
@property (nonatomic, retain) WizInputView* accountPassword;
@property (nonatomic, retain) WizInputView* accountPasswordConfirm;
@property (nonatomic,retain) UIAlertView* waitAlertView;
@property (nonatomic, assign)id<WizCreateAccountDelegate> createDelegate;
@end
