//
//  QianSenToastView.h
//  QianSen
//
//  Created by Kevin on 16/2/2.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOAST_RECT CGRectMake((KSCREEN_WIDTH - 200)/2, [UIApplication sharedApplication].keyWindow.frame.size.height - KSCREEN_HEIGHT + KSOUFUN_NAV_HEIGHT + (KSCREEN_HEIGHT - 200)/2, 200, 50)

@interface CCToastView : NSObject

+ (void) showToastViewContent:(NSString *)content andRect:(CGRect)rect andTime:(float)time;

@end
