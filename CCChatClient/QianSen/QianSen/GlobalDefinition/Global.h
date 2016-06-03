//
//  Global.h
//  QianSen
//
//  Created by Kevin on 16/1/12.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#define HTTP_ENTRANCE @"http://192.168.214.215:8088/operation"
#define HTTP_UPLOADFILE @"http://192.168.214.215:8088/upload"

#ifdef __cplusplus
#define CC_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define CC_EXTERN     extern __attribute__((visibility ("default")))
#endif

#define HeqzDebug
#ifdef HeqzDebug
#define CC_Log(fmt, ...) NSLog((@"%s," fmt) , __FUNCTION__, ##__VA_ARGS__);
#else
#define CC_Log(fmt, ...)

#endif

#define macro

#define CHECK_STR(str)str==nil?@"":str

#define KSCREENSIZE ([UIScreen mainScreen].applicationFrame.size)  //屏幕尺寸
#define KSCREEN_WIDTH ([UIScreen mainScreen].applicationFrame.size.width)
#define KSCREEN_HEIGHT ([UIScreen mainScreen].applicationFrame.size.height)

#define KSINGLELINE_WIDTH  1.0f/([UIScreen mainScreen].scale)//1像素线宽的宏。

#define KSOUFUN_NAV_HEIGHT  44

/*
 循环中使用@autoreleasepool的优化问题
 可以提高效率, 但是不能在循环过程中添加额外的逻辑
 @prarm  NSInteger originalValue   循环的初始值
 @prarm  NSInteger limitValue      循环的结束值
 @param  BOOL      bDec            YES为降循环, NO为升循环
 @param  block(NSInteger nIndex)         要执行的代码 nIndex 为循环过程中的索引值
 */

#define HeqzForAutoRelease(originalValue, limitValue, bDec, nInterval, block) \
if(bDec)\
{\
    NSInteger nTempInterval = nInterval;\
    if(nTempInterval > originalValue - limitValue)\
        nTempInterval = originalValue - limitValue;\
    \
    NSInteger nCount = (originalValue - limitValue)/nTempInterval + 1;\
    \
    for(NSInteger i = 0; i < nCount; ++ i)\
    {\
        NSInteger nStartValue = originalValue - i*nTempInterval;\
        if(nStartValue == limitValue)\
            break;\
        \
        @autoreleasepool {\
            for(NSInteger j = nStartValue; j > nStartValue - nTempInterval; -- j)\
            {\
                block(j);\
            }\
        }\
    }\
}\
else\
{\
    NSInteger nTempInterval = nInterval;\
    if(nTempInterval > limitValue - originalValue)\
        nTempInterval = limitValue - originalValue;\
    NSInteger nCount = (limitValue - originalValue)/nTempInterval + 1;\
    for(NSInteger i = 0; i < nCount; ++ i)\
    {\
        NSInteger nStartValue = originalValue + i*nTempInterval;\
        if(nStartValue == limitValue)\
            break;\
        @autoreleasepool {\
            for(NSInteger j = nStartValue; j < nStartValue + nTempInterval; ++ j)\
            {\
                block(j);\
            }\
        }\
    }\
}

#define K_NAVI_COLOR [UIColor colorWithRed:0.3 green:0.3 blue:0.8 alpha:1.0]

#define K_VISIBLE_HEIGHT KSCREEN_HEIGHT - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height

