//
//  AppDelegate.m
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "AppDelegate.h"
#import "CCLoginViewController.h"
#import "CCDataBaseTool.h"
#import "CCUserInfo.h"
#import "CCTabViewController.h"
#import "CCSystemTool.h"
#import "CCSocketService.h"
#import "CCUserInfo.h"

#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    return bCanRecord;
}

-(void)setAudioSession{
    if(![self canRecord])
    {
        CC_Log(@"没有录音权限");
        return ;
    }
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    
    NSError* error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    //    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if(error)
    {
        CC_Log(@"setCategory:AVAudioSessionCategoryRecord error: %@", error);
        return ;
    }
    [audioSession setActive:YES error:&error];
    if(error)
    {
        CC_Log(@"setActive:YES error: %@", error);
        return ;
    }
    
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* audioPath = [documentPath stringByAppendingPathComponent:@"ChatAudioRecord"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:audioPath])
    {
        NSError* error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error)
        {
            CC_Log(@"create audio record drectory error: %@", error);
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

//    CCDataBaseTool* tool = [[CCDataBaseTool alloc] init];
//    CCUserInfo* userInfo = [tool loadUserInfo];
    
    [self registerRemoteNotifications];
    [self setAudioSession];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
//    if([userInfo.login_Always isEqualToString:@"1"])
//    {
//        self.window.rootViewController = [[CCTabViewController alloc] init];
//    }
//    else
//    {
        UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:[[CCLoginViewController alloc] init]];
        navi.navigationBar.backgroundColor = [UIColor blackColor];
        navi.navigationBar.translucent = NO;
        navi.navigationBar.barTintColor = K_NAVI_COLOR;
        self.window.rootViewController = navi;
//    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)registerRemoteNotifications
{
    if ([CCSystemTool systemVersion].floatValue >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge)categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[CCSocketService defaultSocketService] quitService];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if([[CCUserInfo defaultUserInfo].login_status isEqualToString:@"1"])
    {
        [[CCSocketService defaultSocketService] loginService];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    CCDataBaseTool* tool = [[CCDataBaseTool alloc] init];
    [tool updateUserInfo];
    
    [[CCSocketService defaultSocketService] quitService];
}

@end
