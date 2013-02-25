//
//  WizDetailViewController.h
//  WizNote HD
//
//  Created by dzpqzb on 13-2-22.
//  Copyright (c) 2013年 wiz.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
