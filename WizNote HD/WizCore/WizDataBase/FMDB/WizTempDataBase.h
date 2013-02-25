//
//  WizTempDataBase.h
//  Wiz
//
//  Created by wiz on 12-6-17.
//
//

#import "WizTemporaryDataBaseDelegate.h"
#import "WizDataBase.h"

@interface WizTempDataBase : WizDataBase <WizTemporaryDataBaseDelegate>
- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid;
@end
