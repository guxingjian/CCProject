//
//  QianSenUIComponentTool.m
//  QianSen
//
//  Created by Kevin on 16/1/12.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCToastView.h"
#import "CCUIComponentTool.h"

// 防止页面加载时同时点击多个button
@interface CCSpecialButton : UIButton

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@implementation CCSpecialButton

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    //    self.userInteractionEnabled = NO;
    //
    //    [self performSelector:@selector(setUserInteractionEnabled:)  withObject:[NSNumber  numberWithBool:YES]  afterDelay:0.5];
    //
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [[UIApplication sharedApplication] performSelector:@selector(endIgnoringInteractionEvents)  withObject:nil  afterDelay:0.5];
}

@end

@implementation CCUIComponentTool

+ (UILabel*)addLabelWithRect:(CGRect)rect text:(NSString *)text textColor:(UIColor *)color fontSize:(NSInteger)fontsize alignment:(NSTextAlignment)alignment superview:(UIView *)superview
{
    UILabel* label = [[UILabel alloc] initWithFrame:rect];
    [superview addSubview:label];
    
    label.text = text;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:fontsize];
    label.textAlignment = alignment;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    
    return label;
}

+ (UILabel*)addLabelWithRect:(CGRect)rect text:(NSString*)text textColor:(UIColor*)color fontSize:(NSInteger)fontsize alignment:(NSTextAlignment)alignment tag:(NSInteger)tag superview:(UIView*)superview
{
    UILabel* label = nil;
    if(![superview viewWithTag:tag])
    {
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = tag;
        [superview addSubview:label];
        
        label.text = text;
        label.textColor = color;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:fontsize];
        label.textAlignment = alignment;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    else
    {
        label = [superview viewWithTag:tag];
        label.text = text;
    }
    
    return label;
}

+ (UIButton *)addButtonWithRect:(CGRect)rect title:(NSString *)title titleColor:(UIColor *)color titleSize:(NSInteger)fontsize backColor:(UIColor*)backColor target:(id)target sel:(SEL)sel superview:(UIView *)superView
{
    UIButton* btn = [[UIButton alloc] initWithFrame:rect];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
    
    [btn setBackgroundColor:backColor];
    
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:btn];
    
    return btn;
}

+ (UIButton *)addButtonWithRect:(CGRect)rect title:(NSString *)title titleColor:(UIColor *)color titleSize:(NSInteger)fontsize backColor:(UIColor*)backColor tag:(NSInteger)tag target:(id)target sel:(SEL)sel superview:(UIView *)superView
{
    UIButton* btn = nil;
    if(![superView viewWithTag:tag])
    {
        btn = [[UIButton alloc] initWithFrame:rect];
        btn.tag = tag;
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
        
        [btn setBackgroundColor:backColor];
        
        [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
        [superView addSubview:btn];
    }
    else
    {
        btn = [superView viewWithTag:tag];
    }
    
    return btn;
}

+ (UIButton *)addSpecialButtonWithRect:(CGRect)rect title:(NSString *)title titleColor:(UIColor *)color titleSize:(NSInteger)fontsize backColor:(UIColor*)backColor tag:(NSInteger)tag target:(id)target sel:(SEL)sel superview:(UIView *)superView
{
    CCSpecialButton* btn = nil;
    if(![superView viewWithTag:tag])
    {
        btn = [[CCSpecialButton alloc] initWithFrame:rect];
        btn.tag = tag;
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
        
        [btn setBackgroundColor:backColor];
        
        if(target)
        {
            [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
        }
        
        [superView addSubview:btn];
    }
    else
    {
        btn = [superView viewWithTag:tag];
    }
    
    return btn;
}

+ (UITextField*)addTextFieldWithRect:(CGRect)rect text:(NSString *)text placeholder:(NSString *)pholder delegate:(id)del tag:(NSInteger)tag superview:(UIView *)superview
{
    UITextField* textfield = [[UITextField alloc] initWithFrame:rect];
    [superview addSubview:textfield];
    textfield.delegate = del;
    textfield.tag = tag;
    textfield.backgroundColor = [UIColor clearColor];
    textfield.text = text;
    textfield.font = [UIFont systemFontOfSize:13];
    textfield.textColor = [self colorWithHexString:@"#333333"];
    textfield.leftViewMode = UITextFieldViewModeAlways;
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, rect.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    textfield.leftView = leftView;
    
    textfield.placeholder = pholder;
    [textfield setValue:[self colorWithHexString:@"888888"] forKeyPath:@"_placeholderLabel.textColor"];
    
    textfield.keyboardType = UIKeyboardTypeDefault;
    
    return textfield;
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    //if ([cString length] < 6) return DEFAULT_VOID_COLOR;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    //if ([cString length] != 6) return DEFAULT_VOID_COLOR;
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1];
}

+ (CGSize) textSize:(NSString*)text fontSize:(NSInteger)fontSize constrainedToSize:(CGSize)size
{
    CGSize sizeText = CGSizeZero;
    
    if(size.width == 0 && size.height == 0)
    {
        sizeText = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    }
    else
    {
        CGRect rt = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
        sizeText = rt.size;
    }
    
    return sizeText;
}

+ (UIBarButtonItem *)navigationBackBtn:(NSObject *)target Sel:(SEL)sel
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 31)];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];

    [btn setImage:[UIImage imageNamed:@"common_back_btn_n_ios7.png"] forState:UIControlStateNormal];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 77);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -130, 0, 0);
    btn.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return barItem;
}

//图片处理
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    
    UIGraphicsBeginImageContext(newSize);
    //　　UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSData*)compressImage:(UIImage *)image {
    @autoreleasepool {
        
        ///////////////////////////
        float  scales = image.size.height / image.size.width;
        //    NSData * picData = UIImagePNGRepresentation(img);
        //    SL_Log(@"原始图片的大小  %d",picData.length);
        UIImage * normalImg;
        NSData *newData;
        if (image.size.width >600 || image.size.height > 600) {
            if (scales > 1) {
                normalImg = [self imageWithImageSimple:image scaledToSize:CGSizeMake(600 / scales, 600)];
                CC_Log(@"%f  %f",image.size.width,image.size.height);
                CC_Log(@" %f   %f",normalImg.size.width,normalImg.size.height);
            }else {
                normalImg = [self imageWithImageSimple:image scaledToSize:CGSizeMake(600 ,600 * scales)];
                CC_Log(@"%f  %f",image.size.width,image.size.height);
                CC_Log(@" %f   %f",normalImg.size.width,normalImg.size.height);
            }
            
        }
        else {
            normalImg=image;
        }
        CGSize newSize = CGSizeMake(normalImg.size.width, normalImg.size.height);
        UIGraphicsBeginImageContext(newSize);
        [normalImg drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        float kk=1.0f;//图片压缩系数
        int mm;//压缩后的大小
        float aa=0.1f;//图片压缩系数变化步长(可变)
        mm=(int)UIImageJPEGRepresentation(newImage, kk).length;
        while (mm/1024>450) {
            
            if (kk>aa+aa/10) {
                kk-=aa;
                if (mm==UIImageJPEGRepresentation(newImage, kk).length) {
                    break;
                }
                mm=(int)UIImageJPEGRepresentation(newImage, kk).length;
            }else{
                aa/=10;
            }
        }
        newData=UIImageJPEGRepresentation(newImage, kk);//最后压缩结果
        if (newData.length/1024>450) {
            [CCToastView showToastViewContent:@"上传图片过大,请处理后重新上传" andRect:TOAST_RECT andTime:1.5f];
        }else{
            CC_Log(@"压缩后图片大小%ld",(long)newData.length/1024);
            
            return newData;
        }
    }
    
    return nil;
}

@end
