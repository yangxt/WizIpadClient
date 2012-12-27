//
//  WizPadDocmentMainViewController.m
//  WizPadClient
//
//  Created by wiz on 12-12-25.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadDocmentMainViewController.h"
#import "WizPadListTableControllerBase.h"
#import "WizPadViewDocumentDelegate.h"
#import "WizPadDocumentReadViewController.h"
#import "WizAccountManager.h"
#import "WizPadFoldersViewController.h"
#import "WizPadTagsViewController.h"
#import "WizPadAllNotesViewController.h"

@interface WizPadDocmentMainViewController ()<UISearchBarDelegate,WizPadViewDocumentDelegate>

@end

@implementation WizPadDocmentMainViewController

- (UIInterfaceOrientation) currentOrientation
{
    return self.interfaceOrientation;
}

- (id)init
{
    WizPadListTableControllerBase* base = [[WizPadListTableControllerBase alloc]init];
    WizPadFoldersViewController* folders = [[WizPadFoldersViewController alloc]init];
    WizPadTagsViewController* tags = [[WizPadTagsViewController alloc]init];
    WizPadAllNotesViewController* tree = [[WizPadAllNotesViewController alloc]init];
    
    NSArray* array = [NSArray arrayWithObjects:base, folders, tags, tree, nil];
    NSArray* titles = @[WizStrRecentNotes,NSLocalizedString(@"All Notes", nil),WizStrFolders,WizStrTags ];
    self = [super initWithViewControllers:array titles:titles];
    if (self) {
        base.checkDocumentDelegate = self;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) buildToolBar
{
    UIBarButtonItem* flexSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* newNoteItem = [[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];
    
    NSArray* arr = [NSArray arrayWithObjects:newNoteItem,flexSpaceItem, nil];
    
    [self setToolbarItems:arr];
    
    NSLog(@"self.toolbar %@",self.navigationController.toolbar);
}


- (void) buildNavigationItems
{
    UIBarButtonItem* settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting1"] style:UIBarButtonItemStyleBordered target:self action:@selector(setAccountSettings:)];
    self.navigationItem.leftBarButtonItem = settingItem;
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 44)];
    searchBar.showsCancelButton = YES;
    UIBarButtonItem* searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    searchBar.delegate = self;
    self.navigationItem.rightBarButtonItem = searchItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self buildNavigationItems];
    [self buildToolBar];
    NSLog(@"%@",[[WizAccountManager defaultManager]activeAccountUserId]);
	// Do any additional setup after loading the view.
}

- (void)setAccountSettings:(id)sender
{
    
}

- (void)newNote
{
    
}

- (void)checkDocument:(NSInteger)type keyWords:(NSString *)keyWords selectedDocument:(WizDocument *)document
{
    WizPadDocumentReadViewController* check = [[WizPadDocumentReadViewController alloc] init];
    check.listType = type;
    check.documentListKey = keyWords;
    check.aDocument = document;
    [self.navigationController pushViewController:check animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self buildToolBar];
    [self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
