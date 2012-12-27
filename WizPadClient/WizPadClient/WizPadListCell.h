//
//  WizPadListCell.h
//  WizPadClient
//
//  Created by wiz on 12-12-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizPadDocumentAbstractView.h"

#define PADLISTTABLECELLHEIGHT 300

@class WizDocument;
@protocol WizPadCellSelectedDocumentDelegate<NSObject>
- (void) didPadCellDidSelectedDocument:(WizDocument*)doc;
@end

@interface WizPadListCell : UITableViewCell<WizPadListTableAbstractViewSelectedDelegate>
{
    NSArray* documents;
    id <WizPadCellSelectedDocumentDelegate> selectedDelegate;
}
@property (strong) id <WizPadCellSelectedDocumentDelegate> selectedDelegate;
@property (nonatomic, strong) NSArray* documents;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  detailViewSize:(CGSize)detailSize;
- (void) updateDoc;
@end
