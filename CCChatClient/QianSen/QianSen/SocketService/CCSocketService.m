//
//  CCSocketService.m
//  QianSen
//
//  Created by Kevin on 16/5/30.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCSocketService.h"
#import "CCUserInfo.h"
#import "CCToastView.h"
#import "CCSystemTool.h"

// 消息类型
typedef NS_ENUM(unsigned int, MESSAGE_TYPE)
{
    TYPE_LOGIN = 0x01,
    TYPE_QUIT = 0x02,
    TYPE_MESSAGE = 0x03,
    TYPE_AUDIO = 0x04,
    TYPE_VIDEO = 0x05,
    TYPE_FILE = 0x06
};

// 协议头为8个字节, 其中前四个字节为消息类型, 后四个
// 字节为消息总长度


// 文字消息协议
/**
    0-3     消息类型
    4-7     消息长度
    8-...   消息内容
            消息内容由 好友账号, 己方账号和消息内容构成, 中间以"," 分隔
 */

// login status
NSString* const CC_LOGINSERVICE_SUCCESSFULLY = @"CC_LOGINSERVICE_SUCCESSFULLY";
NSString* const CC_LOGINSERVICE_FAILED = @"CC_LOGINSERVICE_FAILED";

NSString* const CC_RECIEVEDATA_MESSAGE = @"CC_RECIEVEDATA_MESSAGE";

NSString* const CC_RECIEVEDATA_AUDIO = @"CC_RECIEVEDATA_AUDIO";
NSString* const CC_AudioFriendAccountKey = @"CC_AudioFriendAccountKey";
NSString* const CC_AudioPathKey = @"CC_AudioPathKey";
NSString* const CC_AudioDataKey = @"CC_AudioDataKey";

static CCSocketService* service = nil;

@interface CCSocketService ()<NSStreamDelegate>

@end

@implementation CCSocketService
{
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    
    NSMutableData *_readBuffer;
    NSUInteger _readBufferOffset;
    
    NSMutableData *_outputBuffer;
    NSUInteger _outputBufferOffset;
    
    dispatch_queue_t _taskQueue;
    
    BOOL _bHaveLogin;
}

+ (instancetype)defaultSocketService
{
    if(!service)
    {
        service = [[self alloc] initWithHost:@"192.168.214.215" port:4832];
    }
    
    return service;
}

- (instancetype)initWithHost:(NSString*)host port:(NSUInteger)nPort
{
    if(self == [super init])
    {
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, (unsigned int)nPort, &readStream, &writeStream);
        
        _outputStream = CFBridgingRelease(writeStream);
        _inputStream = CFBridgingRelease(readStream);
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        _inputStream.delegate = self;
        _outputStream.delegate = self;
        
        [_outputStream open];
        [_inputStream open];
        
        _readBuffer = [[NSMutableData alloc] init];
        _outputBuffer = [[NSMutableData alloc] init];
        
        _taskQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if ((eventCode == NSStreamEventHasBytesAvailable || eventCode == NSStreamEventHasSpaceAvailable)) {
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (eventCode) {
            case NSStreamEventOpenCompleted: {
                
                NSLog(@"NSStreamEventOpenCompleted");
                
                break;
            }
            
            case NSStreamEventErrorOccurred: {
                
                NSLog(@"NSStreamEventErrorOccurred");
                //                /// TODO specify error better!
                //                [self _failWithError:aStream.streamError];
                //                _readBufferOffset = 0;
                //                [_readBuffer setLength:0];
                break;
                
            }
            
            case NSStreamEventEndEncountered: {
                
                if(aStream == _outputStream)
                {
                    NSLog(@"write completely");
                }
                else if(aStream == _inputStream)
                {
                    NSLog(@"read completely");
                }
                else
                {
                    NSLog(@"unknown NSStreamEventEndEncountered");
                }
                
                break;
            }
            
            case NSStreamEventHasBytesAvailable: {
                
                // 读出全部缓冲区中的全部数据
                const int bufferSize = 8;
                uint8_t buffer[bufferSize] = {};
                
                while (_inputStream.hasBytesAvailable) {
                    NSInteger bytes_read = [_inputStream read:buffer maxLength:bufferSize];
                    
                    if (bytes_read > 0) {
                        [_readBuffer appendBytes:buffer length:bytes_read];
                    } else if (bytes_read < 0) {
                        //                        [self _failWithError:_inputStream.streamError];
                        NSLog(@"read data faild!");
                        break;
                    }
                };
                
                [self analyzeDataBuffer];
                
                break;
            }
            
            case NSStreamEventHasSpaceAvailable: {
                [self sendData];
                
                break;
            }
            
            default:
            //                SRFastLog(@"(default)  %@", aStream);
            break;
        }
    });
}

- (void)analyzeDataBuffer
{
    while(_readBuffer.length > 8)
    {
        uint8_t* buffer = _readBuffer.mutableBytes;
        
        MESSAGE_TYPE nType = *((unsigned int*)buffer);
        unsigned int nMessageLen = *((unsigned int*)(buffer + sizeof(unsigned int)));
        
        if(_readBuffer.length < nMessageLen)
        {
            return ;
        }
        
        if(TYPE_MESSAGE == nType)
        {
            NSString* text = [[NSString alloc] initWithBytes:buffer + 2*sizeof(unsigned int) length:nMessageLen - 2*sizeof(unsigned int) encoding:NSUTF8StringEncoding];
            CC_Log(@"recieve message text: %@", text);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_RECIEVEDATA_MESSAGE object:text];
        }
        else if(TYPE_AUDIO == nType)
        {
            unsigned int strLen = *((unsigned int*)(buffer + sizeof(unsigned int)*2));
            NSString* text = [[NSString alloc] initWithBytes:buffer + 3*sizeof(unsigned int) length:strLen encoding:NSUTF8StringEncoding];
            CC_Log(@"recieve message text: %@", text);
            
            NSArray* arrayText = [text componentsSeparatedByString:@","];
            if(arrayText.count < 3)
                return ;
            
            NSString* friendAcc = [arrayText objectAtIndex:1];
            NSString* audioPath = [arrayText objectAtIndex:2];
            NSData* audioData = [NSData dataWithBytes:buffer + 3*sizeof(unsigned int) + strLen length:nMessageLen - (3*sizeof(unsigned int) + strLen)];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_RECIEVEDATA_AUDIO object:nil userInfo:@{CC_AudioFriendAccountKey:friendAcc, CC_AudioPathKey:audioPath, CC_AudioDataKey:audioData}];
        }
        
        _readBuffer = [NSMutableData dataWithBytes:buffer + nMessageLen length:_readBuffer.length - nMessageLen];
    }
}

- (NSData*)messageHeadWithType:(MESSAGE_TYPE)tp length:(unsigned int)nLen
{
    NSMutableData* mD = [NSMutableData data];
    [mD appendBytes:&tp length:sizeof(unsigned int)];
    [mD appendBytes:&nLen length:sizeof(unsigned int)];
    
    return mD;
}

- (NSData*)messageBodyWithText:(NSString*)text
{
    return [text dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)quitService
{
    if(!_bHaveLogin)
        return ;
    
    NSData* bodyData = [self messageBodyWithText:[CCUserInfo defaultUserInfo].login_account];
    
    [_outputBuffer appendData:[self messageHeadWithType:TYPE_QUIT length:(unsigned int)8 + (unsigned int)bodyData.length]];
    [_outputBuffer appendData:bodyData];
    
    [self sendData];
    
    [_inputStream close];
    [_outputStream close];
    
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    service = nil;
}

- (void)loginService
{
    _bHaveLogin = YES;
    
    dispatch_async(_taskQueue, ^{
        NSData* bodyData = [self messageBodyWithText:[CCUserInfo defaultUserInfo].login_account];
        
        [_outputBuffer appendData:[self messageHeadWithType:TYPE_LOGIN length:(unsigned int)8 + (unsigned int)bodyData.length]];
        [_outputBuffer appendData:bodyData];
        
        [self sendData];
    });
}

- (void)sendMessage:(NSString *)message friendAccount:(NSString *)acc
{
    dispatch_async(_taskQueue, ^{
        
        NSString* strBody = [NSString stringWithFormat:@"%@,%@,%@", acc, [CCUserInfo defaultUserInfo].login_account, message];

        NSData* bodyData = [self messageBodyWithText:strBody];
        NSData* headData = [self messageHeadWithType:TYPE_MESSAGE length:8 + (unsigned int)bodyData.length];
        [_outputBuffer appendData:headData];
        [_outputBuffer appendData:bodyData];
        
        [self sendData];
    });
}

- (void)sendAudioWithPath:(NSString *)url friendAcc:(NSString*)acc
{
    dispatch_async(_taskQueue, ^{
        
        NSMutableData* bodyData = [NSMutableData data];
        
        NSString* strBody = [NSString stringWithFormat:@"%@,%@,%@", acc, [CCUserInfo defaultUserInfo].login_account, url];
        NSData* accData = [self messageBodyWithText:strBody];
        
        unsigned int strLen = (unsigned int)accData.length;
        
        [bodyData appendBytes:&strLen length:sizeof(unsigned int)];
        [bodyData appendData:accData];
        
        NSData* fileData = [NSData dataWithContentsOfFile:[CCSystemTool getSandBoxPathOfAudioWithName:url]];
        
        [bodyData appendData:fileData];
        
        NSData* headData = [self messageHeadWithType:TYPE_AUDIO length:8 + (unsigned int)bodyData.length];
        
        [_outputBuffer appendData:headData];
        [_outputBuffer appendData:bodyData];
        
        [self sendData];
    });
}

- (void)sendData
{
    NSUInteger dataLength = _outputBuffer.length;

    if (dataLength - _outputBufferOffset > 0 && _outputStream.hasSpaceAvailable) {
        NSInteger bytesWritten = [_outputStream write:_outputBuffer.bytes + _outputBufferOffset maxLength:dataLength - _outputBufferOffset];
        if (bytesWritten == -1) {
            NSLog(@"write faild!");
            return;
        }
        
        _outputBufferOffset += bytesWritten;
        
        CC_Log(@"write bytes: %lu", _outputBufferOffset);
        
        if (_outputBufferOffset > 4096) {
            _outputBuffer = [[NSMutableData alloc] initWithBytes:(unsigned char*)_outputBuffer.bytes + _outputBufferOffset length:_outputBuffer.length - _outputBufferOffset];
            _outputBufferOffset = 0;
        }
        
        if(_outputBufferOffset >= dataLength)
        {
            [_outputBuffer setLength:0];
            _outputBufferOffset = 0;
        }
    }
}


@end
