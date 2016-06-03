//
//  CCSocketService.h
//  QianSen
//
//  Created by Kevin on 16/5/30.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCSocketService : NSObject

+ (instancetype)defaultSocketService;

- (void)loginService;
- (void)quitService;
- (void)sendMessage:(NSString*)message friendAccount:(NSString*)acc;
- (void)sendAudioWithPath:(NSString*)url friendAcc:(NSString*)acc;

@end


CC_EXTERN NSString* const CC_LOGINSERVICE_SUCCESSFULLY;
CC_EXTERN NSString* const CC_LOGINSERVICE_FAILED;

CC_EXTERN NSString* const CC_RECIEVEDATA_MESSAGE;

// 音频文件
CC_EXTERN NSString* const CC_RECIEVEDATA_AUDIO;
CC_EXTERN NSString* const CC_AudioFriendAccountKey; // NSString
CC_EXTERN NSString* const CC_AudioPathKey; // NSString
CC_EXTERN NSString* const CC_AudioDataKey; // NSData

