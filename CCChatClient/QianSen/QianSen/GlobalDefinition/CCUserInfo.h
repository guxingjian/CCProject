//
//  QianSenUserInfo.h
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCUserInfo : NSObject<NSCopying>

+ (CCUserInfo*)defaultUserInfo;

@property(nonatomic, strong) NSString* login_status;
@property(nonatomic, strong) NSString* login_userName;
@property(nonatomic, strong) NSString* login_ID;
@property(nonatomic, strong) NSString* login_Always;
@property(nonatomic, strong) NSString* login_headimage;
@property(nonatomic, strong) NSString* login_account;

@end
