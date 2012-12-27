//
//  WizPadFoldersViewController.m
//  WizPadClient
//
//  Created by wiz on 12-12-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizPadFoldersViewController.h"
#import "WizUiTypeIndex.h"
#import "WizObject.h"
#import "WizXmlKbServer.h"
#import "WizInfoDb.h"
#import "WizFileManager.h"

@interface WizPadFoldersViewController ()

@end

@implementation WizPadFoldersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) willReloadFolderTable
{
    [self reloadAllData];
}

- (NSArray*) catelogDataSourceArray
{
//    WizInfoDb* dataBase = [[WizInfoDb alloc]initWithPath:[[WizFileManager shareManager]cacheDbPath]];
//    WizServerDocumentsArray* documentsArray = [[WizServerDocumentsArray alloc]init];
//    WizXmlKbServer* server = [[WizXmlKbServer alloc]initWithUrl:[WizGlobals wizServerUrl]];
//    [server getDocumentsList:documentsArray first:[dataBase currentVersion] count:50];
//    return documentsArray;
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
