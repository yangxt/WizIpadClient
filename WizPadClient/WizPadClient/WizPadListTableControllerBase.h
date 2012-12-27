//
//  WizPadListTableControllerBase.h
//  WizPadClient
//
//  Created by wiz on 12-12-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizPadListCell.h"
#import "WizPadViewDocumentDelegate.h"

@interface WizPadListTableControllerBase : UITableViewController{
    NSMutableArray* tableArray;
    BOOL isLandscape;
    int kOrderIndex;
    id <WizPadViewDocumentDelegate> checkDocumentDelegate;
}
@property (nonatomic, strong) id <WizPadViewDocumentDelegate> checkDocumentDelegate;
@property (nonatomic, strong) NSMutableArray* tableArray;
@property int kOrderIndex;
@property (assign) BOOL isLandscape;
- (void) didSelectedDocument:(WizDocument*)doc;
- (void) reloadAllData;
- (NSArray*) reloadDocuments;
@end
