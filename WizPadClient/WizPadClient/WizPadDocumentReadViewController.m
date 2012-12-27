//
//  WizPadDocumentReadViewController.m
//  WizPadClient
//
//  Created by wiz on 12-12-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadDocumentReadViewController.h"
#import "WizObject.h"
#import "WizFileManager.h"
#import "WizAccountManager.h"
#import "WizInfoDb.h"
#import "DocumentListViewCell.h"
#import "WizSyncCenter.h"
#import "WizNotificationCenter.h"

#define EditTag 1000
#define NOSUPPOURTALERT 1201
#define TableLandscapeFrame CGRectMake(0.0, 0.0, 320, 660)
#define WebViewLandscapeFrame CGRectMake(320, 45, 704, 620)
#define HeadViewLandScapeFrame CGRectMake(320, 0.0, 704, 45)
//
#define TablePortraitFrame   CGRectMake(0.0, 0.0, 0.0, 0.0)
#define HeadViewPortraitFrame     CGRectMake(0.0, 0.0, 768, 45)
#define WebViewPortraitFrame     CGRectMake(0.0, 45, 768, 936)

#define HeadViewLandScapeZoomFrame CGRectMake(0.0, 0.0, 1024, 44)
#define WebViewLandScapeZoomFrame CGRectMake(0.0, 45, 1024, 616)

//
#define WizAlertTagDeletedCurrentDocumentPad    6021

@interface WizPadDocumentReadViewController ()<WizSyncDownloadDelegate>
{
    UIWebView* webView;
    UIView* headerView;
    UITableView* documentListTableView;
    UITableView* portraitTableView;
    
    WizDocument* selectedDocument;
    
    UILabel* documentNameLabel;
    UIButton* zoomOrShrinkButton;
    //
    NSInteger readWidth;
    //
    UIBarButtonItem* editItem;
    UIBarButtonItem* newNoteItem;
    UIBarButtonItem* detailItem;
    UIBarButtonItem* attachmentsItem;
    UIBarButtonItem* shareItem;
    UIBarButtonItem* deletedItem;
}
@property NSInteger readWidth;
@property (nonatomic, retain) WizDocument* selectedDocument;
@property (nonatomic, retain)  UIPopoverController* currentPopoverController;
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@end

@implementation WizPadDocumentReadViewController
@synthesize listType;
@synthesize documentListKey;
@synthesize documentsArray;
@synthesize selectedDocument;
@synthesize currentPopoverController;
@synthesize readWidth;
@synthesize aDocument;
@synthesize lastIndexPath;

- (void) dealloc
{
    [[WizNotificationCenter shareCenter]removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.documentsArray = [NSMutableArray array];
        [[WizNotificationCenter shareCenter]addDownloadDelegate:self];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self buildDocumentTable];
    [self buildHeaderView];
    [self buildWebView];
    [self buildToolBar];
}

- (void)didDownloadEnd:(NSString *)guid
{
    [self downloadDocumentDone:guid];
}

- (void) buildWebView
{
    webView = [[UIWebView alloc] init];
    webView.userInteractionEnabled = YES;
    webView.multipleTouchEnabled = YES;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeAll;
    webView.delegate = self;
    [self.view addSubview:webView];
    [WizGlobals decorateViewWithShadowAndBorder:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self loadReadJs];
}

- (void)loadReadJs
{
    [webView loadReadJavaScript];
    NSString* url = self.selectedDocument.url;
    NSString* type = self.selectedDocument.type;
    NSString* width = [NSString stringWithFormat:@"%dpx",self.readWidth];

    [webView setCurrentPageWidth:width];
    if ((url == nil || [url isEqualToString:@""])  || ((type == nil || [type isEqualToString:@""]) && url.length>4) ||(([[url substringToIndex:4] compare:@"http" options:NSCaseInsensitiveSearch] != 0) && ([type compare:@"webnote" options:NSCaseInsensitiveSearch] != 0))) {
        [webView setCurrentPageWidth:width];
    }
}

- (void) buildDocumentTable
{
    documentListTableView = [[UITableView alloc] init];
    [self.view addSubview:documentListTableView];
    documentListTableView.dataSource = self;
    documentListTableView.delegate = self;
    
    portraitTableView = [[UITableView alloc] init];
    portraitTableView.dataSource = self;
    portraitTableView.delegate = self;
    
    [WizGlobals decorateViewWithShadowAndBorder:documentListTableView];
}

- (void) setViewsFrame
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        documentListTableView.frame = TableLandscapeFrame;
        webView.frame = WebViewLandscapeFrame;
        headerView.frame = HeadViewLandScapeFrame;
        documentNameLabel.frame = CGRectMake(44, 0.0, 680, 44);
        zoomOrShrinkButton.hidden = NO;
    }
    else
    {
        documentNameLabel.frame = CGRectMake(5.0, 0.0, 768, 44);
        zoomOrShrinkButton.hidden = YES;
        documentListTableView.frame = TablePortraitFrame;
        webView.frame = WebViewPortraitFrame;
        headerView.frame = HeadViewPortraitFrame;
    }
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        UIBarButtonItem* listItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", nil) style:UIBarButtonItemStyleDone target:self action:@selector(popTheDocumentList)];
        self.navigationItem.rightBarButtonItem = listItem;
    }
}

- (void) buildHeaderView
{
    headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    //
    zoomOrShrinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomOrShrinkButton.frame = CGRectMake(0.0, 0.0, 44, 44);
    [headerView addSubview:zoomOrShrinkButton];
    [zoomOrShrinkButton addTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [zoomOrShrinkButton setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    documentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0.0, 680, 44)];
    [headerView addSubview:documentNameLabel];
    //
    [WizGlobals decorateViewWithShadowAndBorder:headerView];
}


- (void) buildToolBar
{
    UIBarButtonItem* edit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_gray"] style:UIBarButtonItemStyleBordered target:self action:@selector(editCurrentDocument:)];
    
    UIBarButtonItem* attachment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNoteAttach_gray"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkAttachment)];
    
    UIBarButtonItem* detail = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detail_gray"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkDocumentDtail)];
    
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareCurrentDocument)];
    
    UIBarButtonItem* newNote =[[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];
    
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flex.width = 344;
    
    UIBarButtonItem* flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flex2.width = 40;
    
    UIBarButtonItem* delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCurrentDocument)];
    delete.style = UIBarButtonItemStyleBordered;
    
    NSArray* items = [NSArray arrayWithObjects:newNote, flex,flex, edit,flex2, attachment,flex2, detail,flex2, share,flex,delete,flex,nil];
    
    [self setToolbarItems:items];

    newNoteItem = newNote;
    editItem = edit;
    attachmentsItem = attachment;
    detailItem = detail;
    shareItem = share;
    deletedItem = delete;
}

- (void) viewWillAppear:(BOOL)animated
{    
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    [self setViewsFrame];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.readWidth = 704;
    }
    else {
        self.readWidth = 768;
    }

}

- (void) viewDidAppear:(BOOL)animated
{
    NSString* path =  [WizFileManager personalInfoDataBasePath:[[WizAccountManager defaultManager]activeAccountUserId]];
    WizInfoDb* database = [[WizInfoDb alloc]initWithPath:path];
    [self.documentsArray addObject:[database recentDocuments]];
    [documentListTableView reloadData];
    
    if (self.aDocument != nil) {
        NSIndexPath* indexPath = [self document:self.aDocument inArray:self.documentsArray];
        [self tableView:documentListTableView didSelectRowAtIndexPath:indexPath];
    }else{
        [self tableView:documentListTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    
}

- (NSIndexPath*)document:(WizDocument*)doc inArray:(NSMutableArray*)array
{
    int section = 0;
    int row = 0;
    for (section = 0; section<[array count]; section++) {
        NSArray* anArray = [array objectAtIndex:section];
        for (row = 0; row<[anArray count]; row++) {
            WizDocument* aDoc = [anArray objectAtIndex:row];
            if ([doc.guid isEqualToString:aDoc.guid]) {
                return [NSIndexPath indexPathForItem:row inSection:section];
            }
        }
    }
    return [NSIndexPath indexPathForItem:NSNotFound inSection:NSNotFound];
}

- (void)didSelectedDocument:(WizDocument*)doc
{
    self.selectedDocument = doc;
    
    if (doc.bProtected) {
        [self  displayEncryInfo];
        return;
    }
    documentNameLabel.text = doc.title;
    [webView loadHTMLString:@"" baseURL:nil];
    
//    [self showDocumentAttachmentCount:doc.attachmentCount];
    if (doc.serverChanged) {
        [self downloadDocument:doc];        
    }
    else {
        [self checkDocument:doc];
    }
}

- (void) displayEncryInfo
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning
                                                    message:WizStrThisversionofWizNotdoesnotsupportdecryption
                                                   delegate:self
                                          cancelButtonTitle:WizStrOK
                                          otherButtonTitles:nil];
    alert.tag = NOSUPPOURTALERT;
    [alert show];
    return;
}
- (void)downloadDocumentDone:(NSString*)docGuid
{
    NSString* path =  [WizFileManager personalInfoDataBasePath:[[WizAccountManager defaultManager]activeAccountUserId]];
    WizInfoDb* database = [[WizInfoDb alloc]initWithPath:path];
    WizDocument* document = [database documentFromGUID:docGuid];
    if (nil == document) {
        return ;
    }
    document.serverChanged = NO;
    [database updateDocument:document];
    NSIndexPath* index = [self document:document inArray:self.documentsArray];
    if (nil != index && index.section != NSNotFound) {
        [documentListTableView beginUpdates];
        [documentListTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
        [documentListTableView endUpdates];
    }else{
        return ;
    }
    if ([docGuid isEqualToString:self.selectedDocument.guid]) {
        [self checkDocument:document];
    }
}

- (void)downloadDocument:(WizDocument*)doc
{
    [[WizSyncCenter shareCenter]downloadDocument:doc.guid kbguid:nil accountUserId:[[WizAccountManager defaultManager]activeAccountUserId]];
    [webView loadRequest:nil];
}

- (void)checkDocument:(WizDocument*)doc
{
    NSString* documentFileName = [self documentWillLoadFile:doc];
    if (![[WizFileManager shareManager] fileExistsAtPath:documentFileName])
    {
        static int i = 0;
        i++;
        if (i %2 != 0) {
            [self downloadDocument:doc];
            return ;
        }
    }
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:req];
}

- (NSString*)documentWillLoadFile:(WizDocument*)doc
{
    WizFileManager* fm = [WizFileManager shareManager];
    if ([fm prepareReadingEnviroment:doc.guid accountUserId:[[WizAccountManager defaultManager]activeAccountUserId]]) {
        NSString* documentIndexFile = [fm documentIndexFilePath:doc.guid];
        NSString* documentMobileFile = [fm documentMobildeFilePath:doc.guid];
        if ([fm fileExistsAtPath:documentMobileFile]) {
            return documentMobileFile;
        }
        return documentIndexFile;
    }
    return nil;
}

- (void)editCurrentDocument:(id)sender
{
    
}
- (void)checkAttachment
{
    
}
- (void)checkDocumentDtail
{
    
}
- (void)shareCurrentDocument
{
    
}
- (void)newNote
{
    
}
- (void)deleteCurrentDocument
{
    
}

#pragma tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.documentsArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* array = [self.documentsArray objectAtIndex:section];
    return [array count];
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"myNote";
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"DocumentCell";
    DocumentListViewCell* cell = (DocumentListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DocumentListViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView* sectionView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 20)];
    sectionView.image = [UIImage imageNamed:@"tableSectionHeader"];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 4.0, 320, 15)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [sectionView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:documentListTableView titleForHeaderInSection:section];
    return sectionView;
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DocumentListViewCell* docCell = (DocumentListViewCell*)cell;
    docCell.guid = doc.guid;
    docCell.doc = doc;
    [docCell setNeedsDisplay];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.lastIndexPath != indexPath) {
        self.lastIndexPath = indexPath;
        WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self didSelectedDocument:doc];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
