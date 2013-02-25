//
//  WizDownloadThread.h
//  WizIos
//
//  Created by dzpqzb on 12-12-20.
//  Copyright (c) 2012年 wiz.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
//download source type. 
enum WizDownloadSourceType {
    //all download queue
    WizDownloadSourceTypeAll = 0,
    //user download queue
    WizDownloadSourceTypeUser = 1
};
/**The download thread.
 When the app luanch , the thread start too. and the thread check the queue, if there are documents or attachments to be downloaded. It will work to download its. If not, thre thread will sleep 0.5 seconds.
 */
@interface WizDownloadThread : NSThread
@property (nonatomic, assign) enum WizDownloadSourceType sourceType;
@end
