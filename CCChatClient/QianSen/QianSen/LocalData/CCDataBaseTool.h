//
//  DataBaseTool.h
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCUserInfo;

@interface CCDataBaseTool : NSObject

- (CCUserInfo*)loadUserInfo;
- (BOOL)updateUserInfo;

- (NSArray*)erollHistory;
- (void)addErollRecord;

@end
