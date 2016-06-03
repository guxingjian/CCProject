//
//  CCChatController.m
//  QianSen
//
//  Created by Kevin on 16/5/31.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCChatController.h"
#import "CCUIComponentTool.h"
#import "CCContacterDataModel.h"
#import "CCSocketService.h"
#import "UIImageView+WebCache.h"
#import "CCUserInfo.h"
#import "CCAudioCaptureView.h"
#import "CCToastView.h"
#import "CCSystemTool.h"

#import <AVFoundation/AVFoundation.h>

@interface CCChatController ()<UITextFieldDelegate>

@property(nonatomic, weak)UIView* audioView;
@property(nonatomic, strong)AVAudioPlayer* audioPlayer;

@end

@implementation CCChatController
{
    UIScrollView* _messageScView;
    UIView* _messageView;
    UIView* _bottomView;
    NSDictionary* _keyboardInfo;
}

- (void)dealloc
{
    self.cellModel.bIsDisplay = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_RECIEVEDATA_MESSAGE object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.cellModel.username;
    
    self.cellModel.bIsDisplay = YES;
    
    [self createUI];
    
    [self registerNotification];
}

- (void)registerNotification
{
    //添加自己做为观察者，以获取键盘显示时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //添加自己做为观察者，以获取键盘隐藏时的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioViewWasShown:)
                                                 name:CC_AUDIOACPTUREVIEW_WILLSHOW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioViewWasHidden:)
                                                 name:CC_AUDIOACPTUREVIEW_WILLHIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recordAudio:)
                                                 name:CC_CAPTUREAUDIO_FILENAME object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMessage:) name:CC_RECIEVEDATA_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveAudio:) name:CC_RECIEVEDATA_AUDIO object:nil];
}

- (void)recieveAudio:(NSNotification*)notification
{
//    CC_Log(@"recieveAudio notification: %@", notification);
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSString* friendAcc = [userInfo objectForKey:CC_AudioFriendAccountKey];
    NSString* audioPath = [userInfo objectForKey:CC_AudioPathKey];
    NSData* audioData = [userInfo objectForKey:CC_AudioDataKey];
    
    CC_Log(@"recieveAudio friendAcc: %@, audioPath: %@, audioDataLength: %u", friendAcc, audioPath, audioData.length);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *urlStr = [CCSystemTool getSandBoxPathOfAudioWithName:audioPath];
        if(!urlStr)
        {
            CC_Log(@"directory not existed");
            return ;
        }
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:urlStr])
        {
            BOOL bRet = [[NSFileManager defaultManager] createFileAtPath:urlStr contents:audioData attributes:nil];
            if(!bRet)
            {
                CC_Log(@"write audio data error");
                return ;
            }
        }
        else
        {
            NSError* error = nil;
            NSFileHandle* fileHandler = [NSFileHandle fileHandleForWritingToURL:[NSURL URLWithString:urlStr] error:&error];
            if(error)
            {
                CC_Log(@"fileHandleForWritingToURL error: %@", error);
            }
            
            [fileHandler writeData:audioData];
            [fileHandler closeFile];
        }
    });
    
    CCContacterMessage* messageModel = [[CCContacterMessage alloc] init];
    messageModel.text = audioPath;
    messageModel.isRead = YES;
    messageModel.whoseMessage = 0;
    messageModel.nType = 4;
    
    [_cellModel.messages addObject:messageModel];
    
    [self displayMessage:messageModel];
    [self adjustOffsetY];
}

- (void)recordAudio:(NSNotification*)notification
{
    NSString* audioFile = [notification object];
    
    CCContacterMessage* messageModel = [[CCContacterMessage alloc] init];
    messageModel.text = audioFile;
    messageModel.isRead = YES;
    messageModel.whoseMessage = 1;
    messageModel.nType = 4;
    
    if(!_cellModel.messages)
    {
        _cellModel.messages = [NSMutableArray array];
    }
    [_cellModel.messages addObject:messageModel];
    
    [self displayMessage:messageModel];
    [self adjustOffsetY];
    
    [[CCSocketService defaultSocketService] sendAudioWithPath:audioFile friendAcc:_cellModel.account];
}

- (void)recieveMessage:(NSNotification*)notification
{
    CC_Log(@"recieveMessage notification: %@", notification);
    
    id obj = [notification object];
    if(![obj isKindOfClass:[NSString class]])
    {
        return ;
    }
    
    NSString* text = obj;
    CC_Log(@"text: %@", text);
    
    NSArray* array = [text componentsSeparatedByString:@","];
    if(array.count < 3)
    {
        CC_Log(@"recieveMessage: wrong message format");
        return ;
    }
    
    NSString* acc = [array objectAtIndex:0];
    NSString* friendAcc = [array objectAtIndex:1];
    
    if(!_cellModel.messages)
    {
        _cellModel.messages = [NSMutableArray array];
    }
    
    NSString* message = [text substringFromIndex:(acc.length + 1 + friendAcc.length + 1)];
    
    CCContacterMessage* messageModel = [[CCContacterMessage alloc] init];
    messageModel.text = message;
    messageModel.isRead = YES;
    messageModel.whoseMessage = 0;
    messageModel.nType = 3;
    
    [_cellModel.messages addObject:messageModel];
    
    [self displayMessage:messageModel];
    [self adjustOffsetY];
}

- (void)adjustOffsetY
{
    if(_messageView.frame.size.height > _messageScView.frame.size.height)
    {
        [_messageScView setContentOffset:CGPointMake(0, _messageView.frame.size.height - _messageScView.frame.size.height) animated:YES];
    }
}

- (void)audioViewWasShown:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    CC_Log(@"userInfo: %@", userInfo);
    
    NSValue *value = [userInfo objectForKey:CC_AudioCaptureView_Bounds];
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSNumber* numberDuration = [userInfo objectForKey:CC_AudioCaptureView_Duration];
    NSNumber* numberCurve = [userInfo objectForKey:CC_AudioCaptureView_Curve];
    
    [UIView beginAnimations:@"aniamtion" context:nil];
    [UIView setAnimationDuration:[numberDuration floatValue]];
    [UIView setAnimationCurve:[numberCurve unsignedIntegerValue]];
    
    _messageScView.frame = CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 40 - keyboardSize.height - 60);
    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, KSCREEN_HEIGHT - 40 - keyboardSize.height - 60, _bottomView.frame.size.width, _bottomView.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)audioViewWasHidden:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    CC_Log(@"userInfo: %@", userInfo);
    
    NSNumber* numberDuration = [userInfo objectForKey:CC_AudioCaptureView_Duration];
    NSNumber* numberCurve = [userInfo objectForKey:CC_AudioCaptureView_Curve];
    
    [UIView beginAnimations:@"aniamtion" context:nil];
    [UIView setAnimationDuration:[numberDuration floatValue]];
    [UIView setAnimationCurve:[numberCurve unsignedIntegerValue]];
    
    _messageScView.frame = CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 40 - 60);
    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, KSCREEN_HEIGHT - 40 - 60, _bottomView.frame.size.width, _bottomView.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    CC_Log(@"userInfo: %@", userInfo);
    
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSNumber* numberDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber* numberCurve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:@"aniamtion" context:nil];
    [UIView setAnimationDuration:[numberDuration floatValue]];
    [UIView setAnimationCurve:[numberCurve unsignedIntegerValue]];
    
    _messageScView.frame = CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 40 - keyboardSize.height - 60);
    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, KSCREEN_HEIGHT - 40 - keyboardSize.height - 60, _bottomView.frame.size.width, _bottomView.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    NSDictionary* userInfo = [aNotification userInfo];
    CC_Log(@"userInfo: %@", userInfo);
    
    NSNumber* numberDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber* numberCurve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:@"aniamtion" context:nil];
    [UIView setAnimationDuration:[numberDuration floatValue]];
    [UIView setAnimationCurve:[numberCurve unsignedIntegerValue]];
    
    _messageScView.frame = CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 40 - 60);
    _bottomView.frame = CGRectMake(_bottomView.frame.origin.x, KSCREEN_HEIGHT - 40 - 60, _bottomView.frame.size.width, _bottomView.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)tapRecognizer
{
    [_bottomView endEditing:YES];
    [CCAudioCaptureView closeAudioCaptureView];
}

- (void)naviBack
{
    if(_audioView)
    {
        [CCAudioCaptureView closeAudioCaptureView];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapVoice:(UIButton*)btn
{
    CC_Log(@"tapVoice");
    
    [_bottomView endEditing:YES];
    
    if(!_audioView)
    {
        _audioView = [CCAudioCaptureView showAudioCaptureView];
    }
    else
    {
        [CCAudioCaptureView closeAudioCaptureView];
    }
}

- (void)tapVideo:(UIButton*)btn
{
    CC_Log(@"tapVideo");
    
    [_bottomView endEditing:YES];
    [CCAudioCaptureView closeAudioCaptureView];
}

- (void)createUI
{
    self.navigationItem.leftBarButtonItem = [CCUIComponentTool navigationBackBtn:self Sel:@selector(naviBack)];
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 40 - 60)];
    [self.view addSubview:scrollView];
    _messageScView = scrollView;
    scrollView.backgroundColor = [CCUIComponentTool colorWithHexString:@"#f0f0f0"];
    scrollView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer)];
    [scrollView addGestureRecognizer:tap];
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, 0)];
    [scrollView addSubview:contentView];
    _messageView = contentView;
    contentView.backgroundColor = [UIColor clearColor];
    
    UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KSCREEN_HEIGHT - 40 - 60, KSCREEN_WIDTH, 60)];
    bottomView.backgroundColor = [UIColor clearColor];
    _bottomView = bottomView;
    [self.view addSubview:bottomView];
    
    [CCUIComponentTool addButtonWithRect:CGRectMake(5, 15, 30, 30) title:@"语音" titleColor:[CCUIComponentTool colorWithHexString:@"#333333"] titleSize:13 backColor:[CCUIComponentTool colorWithHexString:@"#a0a0a0"] tag:1002 target:self sel:@selector(tapVoice:) superview:bottomView];
    
    [CCUIComponentTool addButtonWithRect:CGRectMake(45, 15, 30, 30) title:@"视频" titleColor:[CCUIComponentTool colorWithHexString:@"#333333"] titleSize:13 backColor:[CCUIComponentTool colorWithHexString:@"#a0a0a0"] tag:1003 target:self sel:@selector(tapVideo:) superview:bottomView];
    
    UITextField* textfield = [CCUIComponentTool addTextFieldWithRect:CGRectMake(80, 15, KSCREEN_WIDTH - 60 - 15, 30) text:@"" placeholder:@"" delegate:self tag:1001 superview:self.view];
    [bottomView addSubview:textfield];
    textfield.backgroundColor = [UIColor clearColor];
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.leftViewMode = UITextFieldViewModeAlways;
    textfield.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 40)];
    textfield.leftView.backgroundColor = [UIColor clearColor];
    
    textfield.rightViewMode = UITextFieldViewModeAlways;
    textfield.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 40)];
    textfield.rightView.backgroundColor = [UIColor clearColor];
    
    textfield.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    textfield.layer.cornerRadius = 5;
    textfield.layer.masksToBounds = YES;
    
    scrollView.contentSize = contentView.bounds.size;
    
    for(CCContacterMessage* messageModel in _cellModel.messages)
    {
        [self displayMessage:messageModel];
    }
    
    [self adjustOffsetY];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (void)displayMessage:(CCContacterMessage*)messageModel
{
    CGFloat fBottom = _messageView.frame.origin.y + _messageView.frame.size.height;
    
    const CGFloat textLen = 100;
    const CGFloat imageLen = 35;
    const CGFloat topDis = 10;
    const CGFloat botDis = 10;
    
    CGFloat fMax = 0;
    
    if(3 == messageModel.nType) // 文字
    {
        CGSize sizeText = [CCUIComponentTool textSize:messageModel.text fontSize:13 constrainedToSize:CGSizeMake(textLen, 1000)];
        
        if(1 == messageModel.whoseMessage)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH - 10 - imageLen, fBottom + topDis, imageLen, imageLen)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[CCUserInfo defaultUserInfo].login_headimage]];
            [_messageView addSubview:imageView];
            
            UILabel* labelText = [CCUIComponentTool addLabelWithRect:CGRectMake(KSCREEN_WIDTH - 10 - imageLen - 5 - sizeText.width, fBottom + topDis, sizeText.width, sizeText.height) text:messageModel.text textColor:[CCUIComponentTool colorWithHexString:@"#333333"] fontSize:13 alignment:NSTextAlignmentLeft superview:_messageView];
            labelText.backgroundColor = [CCUIComponentTool colorWithHexString:@"#ffffff"];
        }
        else if(0 == messageModel.whoseMessage)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, fBottom + topDis, imageLen, imageLen)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:_cellModel.headImageurl]];
            [_messageView addSubview:imageView];
            
            UILabel* labelText = [CCUIComponentTool addLabelWithRect:CGRectMake(10 + imageLen + 5, fBottom + topDis, sizeText.width, sizeText.height) text:messageModel.text textColor:[CCUIComponentTool colorWithHexString:@"#333333"] fontSize:13 alignment:NSTextAlignmentLeft superview:_messageView];
            labelText.backgroundColor = [CCUIComponentTool colorWithHexString:@"#ffffff"];
        }
        
        fMax = imageLen;
        if(sizeText.height > fMax)
            fMax = sizeText.height;
    }
    else if(4 == messageModel.nType) // 语音
    {
        const CGFloat btnW = 50;
        const CGFloat btnH = 25;
        
        NSInteger nIndex = [_cellModel.messages indexOfObject:messageModel];
        
        if(1 == messageModel.whoseMessage)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH - 10 - imageLen, fBottom + topDis, imageLen, imageLen)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[CCUserInfo defaultUserInfo].login_headimage]];
            [_messageView addSubview:imageView];
            
            [CCUIComponentTool addButtonWithRect:CGRectMake(KSCREEN_WIDTH - 10 - imageLen - 5 - btnW, fBottom + topDis, btnW, btnH) title:@"语音" titleColor:[CCUIComponentTool colorWithHexString:@"#fd3131"] titleSize:13 backColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] tag:10000 + nIndex target:self sel:@selector(playAudio:) superview:_messageView];
        }
        else if(0 == messageModel.whoseMessage)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, fBottom + topDis, imageLen, imageLen)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:_cellModel.headImageurl]];
            [_messageView addSubview:imageView];
            
            [CCUIComponentTool addButtonWithRect:CGRectMake(10 + imageLen + 5, fBottom + topDis, btnW, btnH) title:@"语音" titleColor:[CCUIComponentTool colorWithHexString:@"#fd3131"] titleSize:13 backColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] tag:10000 + nIndex target:self sel:@selector(playAudio:) superview:_messageView];
        }
        
        fMax = btnH;
    }
                 
    fMax += (topDis + botDis);
    
    _messageView.frame = CGRectMake(_messageView.frame.origin.x, _messageView.frame.origin.y, _messageView.frame.size.width, _messageView.frame.size.height + fMax);
    _messageScView.contentSize = CGSizeMake(_messageScView.contentSize.width, _messageScView.contentSize.height + fMax);
}

- (void)playAudio:(UIButton*)btn
{
    NSInteger nIndex = btn.tag - 10000;
    CCContacterMessage* messageModel = [_cellModel.messages objectAtIndex:nIndex];
    
    NSError *error=nil;
    
    AVAudioPlayer* player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[CCSystemTool  getSandBoxPathOfAudioWithName:messageModel.text]] error:&error];
    if (error) {
        CC_Log(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        [CCToastView showToastViewContent:@"播放失败" andRect:TOAST_RECT andTime:1.5f];
    }
    
    
    player.numberOfLoops=0;
    if([player prepareToPlay])
    {
        [player play];
        _audioPlayer = player;
    }
    else
    {
        CC_Log(@"can't play");
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [CCAudioCaptureView closeAudioCaptureView];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isEqualToString:@""])
        return YES;
    
    [[CCSocketService defaultSocketService] sendMessage:textField.text friendAccount:_cellModel.account];
    
    if(!_cellModel.messages)
    {
        self.cellModel.messages = [NSMutableArray array];
    }
    
    CCContacterMessage* messageModel = [[CCContacterMessage alloc] init];
    messageModel.text = textField.text;
    messageModel.isRead = YES;
    messageModel.whoseMessage = 1;
    messageModel.nType = 3;
    [self.cellModel.messages addObject:messageModel];
    
    [self displayMessage:messageModel];
    [self adjustOffsetY];
    
    textField.text = @"";
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
