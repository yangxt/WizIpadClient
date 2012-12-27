//
//  WizPadListTableControllerBase.m
//  WizPadClient
//
//  Created by wiz on 12-12-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadListTableControllerBase.h"
#import "WizNotificationCenter.h"
#import "WizAccountManager.h"
#import "WizInfoDb.h"
#import "WizFileManager.h"
#import "WizPadListCell.h"

@interface WizPadListTableControllerBase ()<WizPadCellSelectedDocumentDelegate>
{
    UILabel* userRemindLabel;
    UIActivityIndicatorView* syncIndicator;
    BOOL isFirstLogin;
}
@end

@implementation WizPadListTableControllerBase
@synthesize isLandscape;
@synthesize kOrderIndex;
@synthesize tableArray;
@synthesize checkDocumentDelegate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [[WizNotificationCenter shareCenter]addObserver:self selector:@selector(updateDocument:) name:@"UpdateDocumetn" object:nil];
//        [[WizNotificationCenter shareCenter]addObserver:self selector:@selector(onDeleteDocument:) name:@"DeleteDocument" object:nil];
//        [[WizNotificationCenter shareCenter]addObserver:self selector:@selector(reloadAllData) name:@"ChangeOrder" object:nil];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
        self.tableArray = [NSMutableArray array];
        [self.tableArray addObject:arr];
        kOrderIndex = -1;
        self.tableArray = [NSMutableArray array];
        userRemindLabel = [[UILabel alloc] init];
        syncIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30, 30)];
        userRemindLabel.backgroundColor = [UIColor clearColor];;
        userRemindLabel.textAlignment = UITextAlignmentCenter;
        userRemindLabel.userInteractionEnabled = NO;
        userRemindLabel.numberOfLines = 0;
        
        userRemindLabel.textColor = [UIColor lightTextColor];
        userRemindLabel.font= [UIFont systemFontOfSize:35];
        
        isFirstLogin = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] orientation] != self.interfaceOrientation) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadAllData];
    
    [self.tableView reloadData];
    if (isFirstLogin) {
    //    [[WizSyncManager shareManager] syn];
        isFirstLogin = NO;
    }
}
- (NSArray*) reloadDocuments
{
    NSString* path =  [WizFileManager personalInfoDataBasePath:[[WizAccountManager defaultManager]activeAccountUserId]];
    WizInfoDb* database = [[WizInfoDb alloc]initWithPath:path];
    return [database recentDocuments];
}

- (void) didChangedSyncDescription:(NSString *)description
{
    userRemindLabel.text = WizStrLoading;
    if (description == nil || [description  isBlock]) {
        userRemindLabel.text = NSLocalizedString(@"You don't have any notes.\n Tap new note to get started!", nil);
    }
    else {
        if ([self.tableArray count] > 0) {
            if ([[self.tableArray objectAtIndex:0] count] >0) {
                self.tableView.backgroundView = nil;
            }
        }
    }
}

- (void) reloadAllData
{
    NSArray* documents = [self reloadDocuments];
    if (![documents count]) {
        UIView* back =  [[UIView alloc] initWithFrame:self.view.frame];
        NSLog(@"size is %f %f",back.frame.size.width,back.frame.size.height);
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            userRemindLabel.frame = CGRectMake(312, 184, 400, 400);
        }
        else {
            userRemindLabel.frame = CGRectMake(184, 312, 400, 400);
        }
        userRemindLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [back addSubview:userRemindLabel];
        userRemindLabel.text = NSLocalizedString(@"You don't have any notes.\n Tap new note to get started!", nil);
        self.tableView.backgroundView = back;
//        [[WizSyncManager shareManager] setDisplayDelegate:self];
    }
    else
    {
        self.tableView.backgroundView = nil;
        [self.tableArray removeAllObjects];
        [self.tableArray addObject:[NSMutableArray arrayWithArray:documents]];
//        NSInteger order = [[WizSettings defaultSettings] userTablelistViewOption];
//        [self.tableArray sortDocumentByOrder:order];
        [self.tableView reloadData];
//        self.kOrderIndex = order;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES ];
    NSLog(@"interface is %d",self.interfaceOrientation);
    
}
- (void) didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.tableView reloadData];
    [super didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
}

- (void)didPadCellDidSelectedDocument:(WizDocument *)doc
{
    [self didSelectedDocument:doc];
}

- (void)didSelectedDocument:(WizDocument *)doc
{
    [self.checkDocumentDelegate checkDocument:WizPadCheckDocumentSourceTypeOfRecent keyWords:doc.guid selectedDocument:doc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0; 
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        count = 4;
    }
    else
    {
        count = 3;
    }
    
    if ([[self.tableArray objectAtIndex:section] count]%count>0) {
        return  [[self.tableArray objectAtIndex:section] count]/count+1;
    }
    else {
        return [[self.tableArray objectAtIndex:section] count]/count  ;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WizPadAbstractCell";
    WizPadListCell *cell = (WizPadListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        CGSize detailSize = CGSizeMake(205, 300);
        cell = [[WizPadListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier detailViewSize:detailSize];
        cell.selectedDelegate = self;
    }
    NSUInteger documentsCount=0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        documentsCount = 4;
    }
    else
    {
        documentsCount = 3;
    }
    NSUInteger needLength = documentsCount*(indexPath.row+1);
    NSArray* sectionArray = [self.tableArray objectAtIndex:indexPath.section];
    NSArray* cellArray=nil;
    NSRange docRange;
    if ([sectionArray count] < needLength) {
        docRange =  NSMakeRange(documentsCount*indexPath.row, (NSInteger)[sectionArray count]-documentsCount*indexPath.row);
    }
    else {
        docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
    }
    cellArray = [sectionArray subarrayWithRange:docRange];
    cell.documents = cellArray;
    [cell updateDoc];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PADLISTTABLECELLHEIGHT;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
