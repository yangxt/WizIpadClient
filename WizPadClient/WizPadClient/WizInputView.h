//
//  WizInputView.h
//  WizIpadPersonalClient
//
//  Created by wiz on 12-12-17.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizInputView : UIView
{
    UIImageView* backgroundView;
    UILabel* nameLabel;
    UITextField* textInputField;
}
@property (nonatomic, retain) UIImageView* backgroundView;
@property (nonatomic, retain) UILabel* nameLable;
@property (nonatomic, retain) UITextField* textInputField;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title placeHoder:(NSString*)placeHoder;
@end
