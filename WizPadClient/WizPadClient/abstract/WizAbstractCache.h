//
//  WizAbstractCache.h
//  Wiz
//
//  Created by wiz on 12-8-3.
//
//

#import <Foundation/Foundation.h>

@class WizDocument;
@class WizAbstract;
@interface WizAbstractCache : NSObject
+ (id) shareCache;
- (WizAbstract*)  documentAbstract:(NSString*)documentGuid;
- (void) addDocumentAbstract:(WizDocument*)document   abstract:(WizAbstract*)abstract;
- (void) clearCacheForDocument:(NSString*)documentGuid;
@end
