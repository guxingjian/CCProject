//
//  QianSenUserInfo_ManagedObject.m
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCUserInfo_Entity.h"
#import "CCUserInfo.h"
#import "Global.h"

@implementation CCUserInfo_Entity

@synthesize loginStatus;
@synthesize loginUserName;
@synthesize loginUserID;
@synthesize loginAlways;
@synthesize loginHeadImage;
@synthesize loginAccount;

+ (NSArray*)arrayRecord:(NSManagedObjectContext*)context
{
    NSFetchRequest* fetch = [[NSFetchRequest alloc] initWithEntityName:@"Entity_UserInfo"];
    
    NSError* error = nil;
    NSArray* array = [context executeFetchRequest:fetch error:&error];
    if(error)
    {
        CC_Log(@"executeFetchRequest error: %@", error);
        return nil;
    }
    
    return array;
}

+ (CCUserInfo*)loadUserInfo:(NSManagedObjectContext*)context
{
    if(!context)
        return nil;
    
    NSArray* records = [self arrayRecord:context];
    if(records.count > 0)
    {
        CCUserInfo_Entity* userInfoObject = [records objectAtIndex:0];
        
        CCUserInfo* userInfo = [CCUserInfo defaultUserInfo];
        userInfo.login_status = userInfoObject.loginStatus;
        userInfo.login_userName = userInfoObject.loginUserName;
        userInfo.login_ID = userInfoObject.loginUserID;
        userInfo.login_Always = userInfoObject.loginAlways;
        userInfo.login_headimage = userInfoObject.loginHeadImage;
        userInfo.login_account = userInfoObject.loginAccount;
        
        return userInfo;
    }
    
    return nil;
}

+ (BOOL)updateUserInfo:(NSManagedObjectContext *)context
{
    NSArray* records = [self arrayRecord:context];
    if(0 == records.count)
        return NO;
    
    CCUserInfo_Entity* userInfoObject = [records objectAtIndex:0];
    CCUserInfo* userInfo = [CCUserInfo defaultUserInfo];
    
    userInfoObject.loginStatus = userInfo.login_status;
    userInfoObject.loginUserName = userInfo.login_userName;
    userInfoObject.loginUserID = userInfo.login_ID;
    userInfoObject.loginAlways = userInfo.login_Always;
    userInfoObject.loginHeadImage = userInfo.login_headimage;
    userInfoObject.loginAccount = userInfo.login_account;
    
    NSError* error = nil;
    [context save:&error];
    if(error)
    {
        CC_Log(@"updateUserInfo error: %@", error);
        return NO;
    }
    
    return YES;
}

@end
