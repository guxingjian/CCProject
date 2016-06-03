//
//  QianSenUIComponentTool.h
//  QianSen
//
//  Created by Kevin on 16/1/12.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCUIComponentTool : NSObject

+ (UILabel*)addLabelWithRect:(CGRect)rect text:(NSString*)text textColor:(UIColor*)color fontSize:(NSInteger)size alignment:(NSTextAlignment)alignment superview:(UIView*)superview;
+ (UILabel*)addLabelWithRect:(CGRect)rect text:(NSString*)text textColor:(UIColor*)color fontSize:(NSInteger)size alignment:(NSTextAlignment)alignment tag:(NSInteger)tag superview:(UIView*)superview;

+ (UIButton*)addButtonWithRect:(CGRect)rect title:(NSString*)title titleColor:(UIColor*)color titleSize:(NSInteger)fontsize backColor:(UIColor*)backColor target:(id)target sel:(SEL)sel superview:(UIView*)superView;
+ (UIButton*)addButtonWithRect:(CGRect)rect title:(NSString*)title titleColor:(UIColor*)color titleSize:(NSInteger)fontsize backColor:(UIColor*)backColor tag:(NSInteger)tag target:(id)target sel:(SEL)sel superview:(UIView*)superView;

// 点击按钮时界面会停止响应0.5秒, 0.5秒后恢复
+ (UIButton*)addSpecialButtonWithRect:(CGRect)rect title:(NSString*)title titleColor:(UIColor*)color titleSize:(NSInteger)fontsize backColor:(UIColor*)backColor tag:(NSInteger)tag target:(id)target sel:(SEL)sel superview:(UIView*)superView;

+ (UITextField*)addTextFieldWithRect:(CGRect)rect text:(NSString*)text placeholder:(NSString*)pholder delegate:(id)del tag:(NSInteger)tag superview:(UIView*)superview;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (CGSize) textSize:(NSString*)text fontSize:(NSInteger)fontSize constrainedToSize:(CGSize)size;

+ (UIBarButtonItem*)navigationBackBtn:(NSObject*)target Sel:(SEL)sel;
+ (NSData*)compressImage:(UIImage *)image;



@end
