//
//  DocumentListViewCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "DocumentListViewCell.h"
#import "WizGlobalData.h"
#import "WizNotificationCenter.h"
#import "WizTemporaryDataBaseDelegate.h"
#import "WizTempDataBase.h"
#import "WizAbstractCache.h"
#import "WizFileManager.h"
#import "WizObject.h"

//#define CellWithImageFrame CGRectMake(8,8,225,74)
//#define CellWithoutImageFrame CGRectMake(8,8,300,74)
int CELLHEIGHTWITHABSTRACT = 90;
int CELLHEIGHTWITHOUTABSTRACT = 50;

#define AbstractImageWidth  75
@interface DocumentListViewCell()
{
    UIImageView* abstractImageView;
    UILabel* nameLabel;
    UILabel* timeLabel;
    UILabel* detailLabel;
    UIImageView* downloadIndicator;
}
@end
@implementation DocumentListViewCell
@synthesize guid;
@synthesize doc;
@synthesize showDownloadIndicator;
+ (UIImage*) documentNoDataImage
{
    static UIImage* placeHoderImage;
    @synchronized (placeHoderImage)
    {
        if (nil == placeHoderImage) {
            placeHoderImage = [UIImage imageNamed:@"documentWithoutData"];
        }
    }
    return placeHoderImage;
}

- (CGRect) getRectWithImage
{
    return CGRectMake(8, 8, self.contentView.frame.size.width-20-75, 74);
}

- (CGRect) getRectWithoutImage
{
    return CGRectMake(8, 8, self.contentView.frame.size.width-20, 74);
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView* breakView = [[UIView alloc] initWithFrame:CGRectMake(0, CELLHEIGHTWITHABSTRACT -1, self.contentView.frame.size.width, 1)];
        breakView.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:0.6];
        breakView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:breakView];
        
        CALayer* contentLayer = breakView.layer;
        contentLayer.shadowColor = [UIColor blackColor].CGColor;
        contentLayer.shadowOffset = CGSizeMake(self.contentView.frame.size.width, 1);
                
        CALayer* selfLayer = [self.selectedBackgroundView layer];
        selfLayer.borderColor = [UIColor grayColor].CGColor;
        selfLayer.borderWidth = 0.5f;
        
        abstractImageView = [[UIImageView alloc] init];
        CGRect imageRect = CGRectMake(self.contentView.frame.size.width-80, 7, 75, 75);
        abstractImageView.frame = imageRect;
        [self.contentView addSubview:abstractImageView];
        
        CALayer* layer =  abstractImageView.layer;
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 0.9;
        
        //

        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        //
        nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        //
        detailLabel = [[UILabel alloc] init];
        detailLabel.font = [UIFont systemFontOfSize:13];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.numberOfLines = 0;
        //
        [self.contentView addSubview:timeLabel];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:detailLabel];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:0.5];
        
        //
        downloadIndicator = [[UIImageView alloc] init ];
        NSMutableArray* images = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 5; i++) {
            UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"downloadIndicator%d",i]];
            if (nil == image) {
                continue;
            }
            [images addObject:image];
        }
        downloadIndicator.animationImages = images;
        downloadIndicator.animationDuration = 0.8;
        [self.contentView addSubview:downloadIndicator];
    
        //
        
    }
    return self;
}

- (void) fixAllSubViewsFrame:(CGFloat)leftSpace showImage:(BOOL)isShowImage
{
     NSInteger rightBreakWidth = 90;
    if (!isShowImage) {
        rightBreakWidth = 20;
    }
    nameLabel.frame = CGRectMake(leftSpace, 8, self.frame.size.width-rightBreakWidth, 20);
    timeLabel.frame = CGRectMake(leftSpace, 30, self.frame.size.width-rightBreakWidth, 12);
    detailLabel.frame = CGRectMake(leftSpace, 42, self.frame.size.width-rightBreakWidth, 40);
    abstractImageView.frame = CGRectMake(self.frame.size.width-80, 10, 70, 70);
    abstractImageView.hidden = !isShowImage;
    
}

- (void) drawRect:(CGRect)rect
{
    //
    downloadIndicator.frame = CGRectMake(self.frame.size.width-30, 60, 20, 20);

    nameLabel.text = self.doc.title;
    timeLabel.text = [self.doc.dateModified stringSql];
    detailLabel.text = nil;
    abstractImageView.image = nil;
    [self fixAllSubViewsFrame:10 showImage:NO];
    
    void (^showAbstract)(WizAbstract* abstract) = ^(WizAbstract* abstract)
    {
        detailLabel.text = abstract.text;
        abstractImageView.image = abstract.image;
        if (!abstract.image) {
            [self fixAllSubViewsFrame:10 showImage:NO];
        }
        else
        {
            [self fixAllSubViewsFrame:10 showImage:YES];
        }
    };


    void (^generateAbstract)() = ^()
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString* cachePath = [[WizFileManager shareManager]cacheDbPath];
            id<WizTemporaryDataBaseDelegate> abstractDataBase = [[WizTempDataBase alloc]initWithPath:cachePath modelName:@"WizTempDataBaseModel"];
            WizAbstract* abstract = [abstractDataBase abstractOfDocument:self.doc.guid];
            if (self.doc.serverChanged ==0 && !abstract) {
                [abstractDataBase extractSummary:self.doc.guid kbGuid:@""];
                abstract = [abstractDataBase abstractOfDocument:self.doc.guid];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WizAbstractCache shareCache] addDocumentAbstract:self.doc abstract:abstract];
                WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstract:self.doc.guid];
                showAbstract(abstract);
            });
        });
    };
    
    WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstract:self.doc.guid];
    if (abstract) {
        showAbstract(abstract);
        if (self.doc.serverChanged == 0) {
            generateAbstract();
        }
    }
    else
    {
        generateAbstract();
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    if ([[WizSyncManager shareManager] isDownloadingWizobject:self.doc]) {
//        [downloadIndicator startAnimating];
//    }
//    else
//    {
//        [downloadIndicator stopAnimating];
//    }
}
@end
