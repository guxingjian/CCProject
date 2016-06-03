//
//  QianSenSystemTool.m
//  QianSen
//
//  Created by Kevin on 16/1/12.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCSystemTool.h"
#import <objc/runtime.h>

@implementation CCSystemTool

+ (NSString*)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (CGRect)applicationFrame
{
    CGRect appFrame = CGRectZero;
    
    if([[CCSystemTool systemVersion] floatValue] <= 9.0)
    {
        appFrame = [UIScreen mainScreen].applicationFrame;
    }
    else
    {
        appFrame = [UIScreen mainScreen].bounds;
    }
    
    return appFrame;
}

+ (CCDeviceType)deviceType
{
    CGRect frame = [CCSystemTool applicationFrame];
    if(frame.size.height < 500)
    {
        return CCDeviceTypeIphone4;
    }
    
    if(([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO))
    {
        return CCDeviceTypeIphone5;
    }
    
    if([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)
    {
        return CCDeviceTypeIphone6;
    }
    
    if([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
    {
        return CCDeviceTypeIphone6p;
    }
    
    return CCDeviceTypeNone;
}

+ (NSString*)getUrlWithParams:(NSDictionary *)dic
{
    NSString* strUrl = HTTP_ENTRANCE;
    
    NSArray* keys = [dic allKeys];
    for(NSInteger i = 0; i < keys.count; ++ i)
    {
        id key = [keys objectAtIndex:i];
        if(![key isKindOfClass:[NSString class]])
            return nil;
        
        id value = [dic objectForKey:key];
        if(![value isKindOfClass:[NSString class]])
            return nil;
        
        NSString* tempStr = [NSString stringWithFormat:@"%@=%@", key, value];
        if(i != keys.count - 1)
        {
            tempStr = [tempStr stringByAppendingString:@"&"];
        }
        
        strUrl = [strUrl stringByAppendingString:tempStr];
    }
    
    return strUrl;
}

+ (NSString*)getSandBoxPathOfAudioWithName:(NSString*)audioFileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"ChatAudioRecord"]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        return [path stringByAppendingPathComponent:audioFileName];
    }
    
    return nil;
}

@end


@implementation NSObject(heqz_description)

- (NSString*)heqz_description
{
    //    id LenderClass = objc_getClass("Lender");
    id LenderClass = [self class];
    
    unsigned int outCount, i;
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(LenderClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        
        NSString* propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        [dic setObject:[self valueForKeyPath:propertyName] forKey:propertyName];
    }
    
    return [NSString stringWithFormat:@"<%@, %p, %@",
            [self class],
            self,
            dic
            ];
}

@end
