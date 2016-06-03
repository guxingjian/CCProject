//
//  CCAudioCaptureView.h
//  QianSen
//
//  Created by Kevin on 16/6/1.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAudioCaptureView : UIView

// 录制的音频文件以好友账号加录制开始时间为文件名
+ (UIView*)showAudioCaptureView;
+ (void)closeAudioCaptureView;

@end

// 录制结束后发出通知, 通知对象为音频文件的URL
CC_EXTERN NSString* const CC_CAPTUREAUDIO_FILENAME;

// 模仿键盘弹出操作
CC_EXTERN NSString* const CC_AUDIOACPTUREVIEW_WILLSHOW;
CC_EXTERN NSString* const CC_AUDIOACPTUREVIEW_WILLHIDE;

// 通知的userInfo 的key
CC_EXTERN NSString* const CC_AudioCaptureView_Curve; // NSNumber of NSUInteger
CC_EXTERN NSString* const CC_AudioCaptureView_Duration; // NSNumber of CGFloat
CC_EXTERN NSString* const CC_AudioCaptureView_Bounds; // NSValue of CGRect
//

