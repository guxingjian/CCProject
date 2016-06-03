//
//  QianSenUserInfo_ManagedObject.h
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <CoreData/CoreData.h>

@class QianSenUserInfo;

@interface CCUserInfo_Entity : NSManagedObject

@property(nonatomic, strong) NSString* loginStatus;
@property(nonatomic, strong) NSString* loginUserName;
@property(nonatomic, strong) NSString* loginUserID;
@property(nonatomic, strong) NSString* loginAlways;
@property(nonatomic, strong) NSString* loginHeadImage;
@property(nonatomic, strong) NSString* loginAccount;

+ (QianSenUserInfo*)loadUserInfo:(NSManagedObjectContext*)context;
+ (BOOL)updateUserInfo:(NSManagedObjectContext*)context;

@end
