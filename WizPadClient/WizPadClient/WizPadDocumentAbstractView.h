//
//  WizPadDocumentAbstractView.h
//  WizPadClient
//
//  Created by wiz on 12-12-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizDocument;
@protocol WizPadListTableAbstractViewSelectedDelegate <NSObject>
- (void) didSelectedDocument:(WizDocument*)doc;
@end

@interface WizPadDocumentAbstractView : UIView
{
    WizDocument* doc;
    id <WizPadListTableAbstractViewSelectedDelegate> selectedDelegate;
}
@property (strong) id <WizPadListTableAbstractViewSelectedDelegate> selectedDelegate;
@property (nonatomic, strong) WizDocument* doc;
- (void) updateView;
@end
