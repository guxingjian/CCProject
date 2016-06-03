//
//  QianSenUserInfo.m
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCUserInfo.h"

static CCUserInfo* userInfo = nil;

@implementation CCUserInfo

@synthesize login_status;
@synthesize login_userName;
@synthesize login_ID;
@synthesize login_Always;
@synthesize login_headimage;
@synthesize login_account;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        userInfo = [super allocWithZone:zone];
        userInfo.login_status = @"0";
        userInfo.login_userName = @"";
        userInfo.login_ID = @"";
        userInfo.login_Always = @"0";
        userInfo.login_headimage = @"";
        userInfo.login_account = @"";
    });
    
    return userInfo;
}

+ (CCUserInfo*)defaultUserInfo
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        userInfo = [[CCUserInfo alloc] init];
    });
    
    return userInfo;
}

- (id)copyWithZone:(NSZone *)zone
{
    return userInfo;
}

@end
