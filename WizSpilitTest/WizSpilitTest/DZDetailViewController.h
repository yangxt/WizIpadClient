//
//  DZDetailViewController.h
//  WizSpilitTest
//
//  Created by dzpqzb on 13-2-25.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
