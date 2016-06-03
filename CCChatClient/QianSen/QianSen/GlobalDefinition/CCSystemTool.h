//
//  QianSenSystemTool.h
//  QianSen
//
//  Created by Kevin on 16/1/12.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CCDeviceType
{
    CCDeviceTypeNone,
    CCDeviceTypeIphone4,
    CCDeviceTypeIphone5,
    CCDeviceTypeIphone6,
    CCDeviceTypeIphone6p
}CCDeviceType;

@interface CCSystemTool : NSObject

+ (NSString*)systemVersion;
+ (CGRect)applicationFrame;
+ (CCDeviceType)deviceType;

+ (NSString*)getUrlWithParams:(NSDictionary*)dic;
+ (NSString*)getSandBoxPathOfAudioWithName:(NSString*)audioFileName;

@end

@interface NSObject(heqz_description)

- (NSString*) heqz_description;

@end



