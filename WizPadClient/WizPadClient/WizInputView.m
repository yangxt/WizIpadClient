//
//  WizInputView.m
//  WizIpadPersonalClient
//
//  Created by wiz on 12-12-17.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizInputView.h"

@implementation WizInputView
@synthesize backgroundView;
@synthesize nameLable;
@synthesize textInputField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320, frame.size.height)];
        [self addSubview:imageView];
        self.backgroundView = imageView;
        self.backgroundView.image = [UIImage imageNamed:@"inputBackground"];
        UILabel* nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 75, frame.size.height)];
        nameLabel_.font = [UIFont systemFontOfSize:13];
        self.nameLable = nameLabel_;
        self.nameLable.adjustsFontSizeToFitWidth = YES;
        self.nameLable.textAlignment = NSTextAlignmentCenter;
        self.nameLable.backgroundColor = [UIColor clearColor];
        
        UITextField* textInputField_ = [[UITextField alloc] initWithFrame:CGRectMake(10, 0.0, 300, frame.size.height)];
        [self addSubview:textInputField_];
        textInputField_.autocorrectionType = UITextAutocorrectionTypeNo;
        textInputField_.leftViewMode = UITextFieldViewModeAlways;
        textInputField_.leftView = self.nameLable;
        textInputField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textInputField = textInputField_;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame title:(NSString*)title placeHoder:(NSString*)placeHoder
{
    self = [self initWithFrame:frame];
    self.nameLable.text = NSLocalizedString(title, nil);
    self.textInputField.placeholder = NSLocalizedString(placeHoder, nil);
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
