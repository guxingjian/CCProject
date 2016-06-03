//
//  QianSenToastView.m
//  QianSen
//
//  Created by Kevin on 16/2/2.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCToastView.h"
#import "Global.h"
#import "CCUIComponentTool.h"

@implementation CCToastView

+ (void) showToastViewContent:(NSString *)content andRect:(CGRect)rect andTime:(float)time
{
    UIView* superView = nil;
    
    NSArray* windows = [UIApplication sharedApplication].windows;
    UIWindow* topWindow = [UIApplication sharedApplication].keyWindow;
    
    for(NSInteger i = windows.count - 1; i >= 0; -- i)
    {
        UIWindow* tempWnd = [windows objectAtIndex:i];
        if(tempWnd.frame.size.height == topWindow.frame.size.height)
        {
            topWindow = tempWnd;
            break;
        }
    }
    
    superView = topWindow;
    
    if ([superView viewWithTag:1234554321]) {
        UIView * tView = [superView viewWithTag:1234554321];
        [tView removeFromSuperview];
    }
    
    UIImageView * toastView = [[UIImageView alloc] initWithFrame:rect];
    
    [toastView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.75f]];
    
    [toastView.layer setCornerRadius:5.0f];
    [toastView.layer setMasksToBounds:YES];
    [toastView setAlpha:1.0f];
    [toastView setTag:1234554321];
    [superView addSubview:toastView];
    
    CGSize labelSize = [CCUIComponentTool textSize:content fontSize:17 constrainedToSize:CGSizeMake(rect.size.width, 1000)];
    
    if (labelSize.height > rect.size.height) {
        [toastView setFrame:CGRectMake(toastView.frame.origin.x, rect.origin.y + rect.size.height/2 - labelSize.height/2, toastView.frame.size.width, labelSize.height)];
    }
    
    UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, toastView.frame.size.width - 20, toastView.frame.size.height)];
    [contentLabel setText:content];
    [contentLabel setTextColor:[UIColor whiteColor]];
    [contentLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [contentLabel setTextAlignment:NSTextAlignmentCenter];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setNumberOfLines:0];
    [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [toastView addSubview:contentLabel];
    
    if (time>0.01) {
        [self performSelector:@selector(removeToastViewExtension:) withObject:superView afterDelay:time];
    }
}

+ (void) removeToastViewExtension:(id)sender
{
    UIView* view = (UIView *)sender;
    UIView * tempToastView = [view viewWithTag:1234554321];
    [tempToastView removeFromSuperview];
}

@end
