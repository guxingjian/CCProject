//
//  CCAudioCaptureView.m
//  QianSen
//
//  Created by Kevin on 16/6/1.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCAudioCaptureView.h"
#import "CCUIComponentTool.h"
#import "CCToastView.h"
#import "CCSystemTool.h"
#import "CCUserInfo.h"

#import <AVFoundation/AVFoundation.h>

NSString* const CC_CAPTUREAUDIO_FILENAME = @"CC_CAPTUREAUDIO_FILENAME";

NSString* const CC_AUDIOACPTUREVIEW_WILLSHOW = @"CC_AUDIOACPTUREVIEW_WILLSHOW";
NSString* const CC_AUDIOACPTUREVIEW_WILLHIDE = @"CC_AUDIOACPTUREVIEW_WILLHIDE";
NSString* const CC_AudioCaptureView_Curve = @"CC_AudioCaptureView_Curve";
NSString* const CC_AudioCaptureView_Duration = @"CC_AudioCaptureView_Duration";
NSString* const CC_AudioCaptureView_Bounds = @"CC_AudioCaptureView_Bounds";

static CCAudioCaptureView* global_audioView = nil;

@interface CCAudioCaptureView()<AVAudioRecorderDelegate>

@property(nonatomic, strong)AVAudioRecorder* audioRecorder;

@end

@implementation CCAudioCaptureView
{
    NSString* _currentFileName;
    NSDate* _recordDate;
}

+ (UIView*)showAudioCaptureView
{
    if(global_audioView)
        return global_audioView;
    
    UIWindow* window = nil;
    NSArray* arrayWindos = [UIApplication sharedApplication].windows;
    for(NSInteger i = arrayWindos.count - 1; i >= 0; -- i)
    {
        UIWindow* tempWd = [arrayWindos objectAtIndex:i];
        if(tempWd.frame.size.height > 300)
        {
            window = tempWd;
            break;
        }
    }
    
    if(!window)
        return nil;
    
    const CGFloat fHeight = 220;
    
    CCAudioCaptureView* audioView = [[self alloc] initWithFrame:CGRectMake(0, window.frame.size.height, KSCREEN_WIDTH, fHeight)];
    global_audioView = audioView;
    
    [window addSubview:audioView];
    
    [audioView showAnimation];
    
    return global_audioView;
}

+ (void)closeAudioCaptureView
{
    if(global_audioView)
    {
        [global_audioView closeAnimation];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [CCUIComponentTool colorWithHexString:@"#fafafa"];
        
//        [self setAudioSession];
        [self decorateAudioView];
    }
    
    return self;
}

- (void)decorateAudioView
{
    [CCUIComponentTool addLabelWithRect:CGRectMake(self.bounds.size.width/2 - 60/2, 10, 60, 20) text:@"按住说话" textColor:[CCUIComponentTool colorWithHexString:@"#333333"] fontSize:13 alignment:NSTextAlignmentCenter superview:self];
    
    const CGFloat butLen = 80;
    UIButton* btnRecord = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - butLen/2, self.bounds.size.height/2 - butLen/2, butLen, butLen)];
    [btnRecord setTitle:@"录音" forState:UIControlStateNormal];
    [btnRecord setTitleColor:[CCUIComponentTool colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    btnRecord.titleLabel.font = [UIFont systemFontOfSize:15];
    btnRecord.backgroundColor = [CCUIComponentTool colorWithHexString:@"#3131fa"];
    
//    UIButton* btnRecord = [CCUIComponentTool addSpecialButtonWithRect:CGRectMake(self.bounds.size.width/2 - butLen/2, self.bounds.size.height/2 - butLen/2, butLen, butLen) title:@"录音" titleColor:[CCUIComponentTool colorWithHexString:@"#333333"] titleSize:15 backColor:[CCUIComponentTool colorWithHexString:@"#3131fa"] tag:10010 target:nil sel:0 superview:self];
    
    btnRecord.layer.cornerRadius = 40;
    btnRecord.layer.masksToBounds = YES;
    
    [self addSubview:btnRecord];
    
    [btnRecord addTarget:self action:@selector(recordAudio:) forControlEvents:UIControlEventTouchDown];
    [btnRecord addTarget:self action:@selector(pauseAudio:) forControlEvents:UIControlEventTouchUpInside];
}

/**
    转自:http://www.cnblogs.com/kenshincui/p/4186022.html#audioRecord
    // ***********************end***********************
 */
//
//- (BOOL)canRecord
//{
//    __block BOOL bCanRecord = YES;
//    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
//            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
//                if (granted) {
//                    bCanRecord = YES;
//                } else {
//                    bCanRecord = NO;
//                }
//            }];
//        }
//    }
//    return bCanRecord;
//}
//
//-(void)setAudioSession{
//    if(![self canRecord])
//    {
//        CC_Log(@"没有录音权限");
//        return ;
//    }
//    
//    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
//    //设置为播放和录音状态，以便可以在录制完之后播放录音
//    
//    NSError* error = nil;
//    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
////    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
//    if(error)
//    {
//        CC_Log(@"setCategory:AVAudioSessionCategoryRecord error: %@", error);
//        return ;
//    }
//    [audioSession setActive:YES error:&error];
//    if(error)
//    {
//        CC_Log(@"setActive:YES error: %@", error);
//        return ;
//    }
//}

-(NSURL *)getSavePathURL
{
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-dd_hh:mm:ss"];
    
    NSString* strDate = [dateFormatter stringFromDate:date];
    CC_Log(@"strDate: %@", strDate);

    NSString* fileName = [NSString stringWithFormat:@"%@_%@.caf", [CCUserInfo defaultUserInfo].login_account, strDate];
    CC_Log(@"urlStr: %@", fileName);
    _currentFileName = fileName;
    
    NSString* strTemp = [CCSystemTool getSandBoxPathOfAudioWithName:fileName];
    
    NSURL *url=[NSURL fileURLWithPath:strTemp];
    return url;
}
 
-(NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(44100) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(2) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
     return dicM;
}

-(AVAudioRecorder *)audioRecorderWithUrl:(NSURL*)url
{
    //创建录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    //创建录音机
    NSError *error=nil;
    
    AVAudioRecorder* recorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }
    
    [recorder recordForDuration:20];
    recorder.delegate=self;
    recorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    return recorder;
}

// ***********************end***********************

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    if(error)
    {
        CC_Log(@"录制失败 error: %@", error);
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if(!flag)
    {
        CC_Log(@"录制失败");
        return ;
    }
    
    NSDate* sendDate = [NSDate date];
    
    if([sendDate timeIntervalSinceDate:_recordDate] < 1)
    {
        [CCToastView showToastViewContent:@"按住了" andRect:TOAST_RECT andTime:2.0f];
        
        [[NSFileManager defaultManager] removeItemAtPath:_currentFileName error:nil];
        
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_CAPTUREAUDIO_FILENAME object:[_currentFileName copy]];
    
    _audioRecorder = nil;
}

- (void)recordAudio:(UIButton*)btn
{
    btn.backgroundColor = [CCUIComponentTool colorWithHexString:@"#fa3131"];
    
    _recordDate = [NSDate date];
    self.audioRecorder = [self audioRecorderWithUrl:[self getSavePathURL]];
    if([self.audioRecorder prepareToRecord])
    {
        if(![self.audioRecorder record])
        {
            CC_Log(@"can't record, averagePowerForChannel: %f, peakPowerForChannel%f",[self.audioRecorder averagePowerForChannel:0], [self.audioRecorder peakPowerForChannel:0]);
        }
    }
    else
    {
        CC_Log(@"can't record");
    }
}

- (void)pauseAudio:(UIButton*)btn
{
    btn.backgroundColor = [CCUIComponentTool colorWithHexString:@"#3131fa"];
    
    [self.audioRecorder stop];
}

- (void)showAnimation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_AUDIOACPTUREVIEW_WILLSHOW object:nil userInfo:@{CC_AudioCaptureView_Curve:@7, CC_AudioCaptureView_Duration:@0.25,CC_AudioCaptureView_Bounds:[NSValue valueWithCGRect:self.bounds]}];
    
    [UIView beginAnimations:@"showAudioCaptureView_showAnimation" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    
    self.frame = CGRectMake(0, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)closeAnimationDidStop
{
    [self removeFromSuperview];
    global_audioView = nil;
}

- (void)closeAnimation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_AUDIOACPTUREVIEW_WILLHIDE object:nil userInfo:@{CC_AudioCaptureView_Curve:@7, CC_AudioCaptureView_Duration:@0.25,CC_AudioCaptureView_Bounds:[NSValue valueWithCGRect:self.bounds]}];
    
    [UIView beginAnimations:@"showAudioCaptureView_closeAnimation" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(closeAnimationDidStop)];
    
    self.frame = CGRectMake(0, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
    
    [UIView commitAnimations];
}

- (BOOL)endEditing:(BOOL)force
{
    if(force)
    {
        [self closeAnimation];
    }
    
    return [super endEditing:force];
}

@end
