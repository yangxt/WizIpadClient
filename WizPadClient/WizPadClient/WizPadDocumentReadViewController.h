//
//  WizPadDocumentReadViewController.h
//  WizPadClient
//
//  Created by wiz on 12-12-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizDocument;
@interface WizPadDocumentReadViewController : UIViewController<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSUInteger listType;
    NSString* documentListKey;
    NSMutableArray* documentsArray;
    WizDocument* initDocument;
}
@property  NSUInteger listType;
@property (nonatomic, strong) NSString* documentListKey;
@property (nonatomic, strong) NSMutableArray* documentsArray;
@property (nonatomic, strong) WizDocument* aDocument;
- (void) shrinkDocumentWebView;
- (void) zoomDocumentWebView;
@end
