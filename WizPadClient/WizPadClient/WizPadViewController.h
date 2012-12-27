//
//  WizPadViewController.h
//  WizPadClient
//
//  Created by wiz on 12-12-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizPadViewController : UIViewController<UIAlertViewDelegate>
{
    UIButton* loginButton;
    UIImageView* backgroudView;
    UIButton* registerButton;
    UILabel* CripytLabel;
    BOOL firstLoad;
}
@property (nonatomic, strong) UIButton* loginButton;
@property (nonatomic, strong) UIImageView* backgroudView;
@property (nonatomic, strong) UIButton* registerButton;
@property (nonatomic, strong) UILabel* CripytLabel;
- (void)loginViewAppear:(id)sender;
- (void)registerViewApper:(id)sender;
@end
