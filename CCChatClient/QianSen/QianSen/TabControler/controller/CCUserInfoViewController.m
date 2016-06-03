//
//  CCUserInfoViewController.m
//  QianSen
//
//  Created by Kevin on 16/4/13.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCUserInfoViewController.h"
#import "CCUIComponentTool.h"
#import "UIImageView+WebCache.h"
#import "CCUserInfo.h"
#import "CCNetworkManager.h"
#import "CCTaskInfo.h"
#import "CCToastView.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface CCUserInfoViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

{
    UIImageView* _imageView;
    UIViewController* _picker;
}

@end

@implementation CCUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [CCUIComponentTool colorWithHexString:@"#3a3a3a"];
    
    [self createUI];
}

- (void)imageTap
{
    if ([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
    {
        CC_Log(@"unavailable source type: UIImagePickerControllerSourceTypeSavedPhotosAlbum");
        return ;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    NSArray* array =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    if(![array containsObject:(__bridge NSString*)kUTTypeImage])
    {
        CC_Log(@"unavailable media type kUTTypeImage");
        return ;
    }
    
    mediaUI.mediaTypes = @[(__bridge NSString*)kUTTypeImage];
    
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = self;
    
    _picker = mediaUI;
    [self presentViewController:mediaUI animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    CCUserInfo* userInfo = [CCUserInfo defaultUserInfo];
    
    UIImage* originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData* data = [CCUIComponentTool compressImage:originalImage];
    if(!data)
    {
        CC_Log(@"压缩图片失败");
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_UPLOADHEADIMAGE_NOTIFICATION object:nil];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:@"uploadHeadImage" forKey:@"messagename"];
    [dic setObject:userInfo.login_account forKey:@"account"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadHeadImageNotification:) name:CC_TASK_UPLOADHEADIMAGE_NOTIFICATION object:nil];
    
    NSString* strFileName = [NSString stringWithFormat:@"%@_head.png", userInfo.login_account];
    
    NSURLSessionDataTask* task = [[CCNetworkManager sharedInstance] POST:HTTP_UPLOADFILE parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"image" fileName: strFileName mimeType:@"image/png"];
    }];
    task.taskDescription = CC_TASK_UPLOADHEADIMAGE_DESCPRITION;
}

- (void)uploadHeadImageNotification:(id)sender
{
    CC_Log("sender: %@", [sender object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_UPLOADHEADIMAGE_NOTIFICATION object:nil];
    [self dismissViewControllerAnimated:_picker completion:^{
    }];
    
    id object = [sender object];
    
    if([object isKindOfClass:[NSError class]])
    {
        [CCToastView showToastViewContent:@"网络错误" andRect:TOAST_RECT andTime:1.5f];
    }
    else if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* dic = (NSDictionary*)object;
        if([[dic objectForKey:@"result"] isEqualToString:@"1"])
        {
            NSString* strUrl = [dic objectForKey:@"imageurl"];
            [CCUserInfo defaultUserInfo].login_headimage = strUrl;
            
//            [[SDImageCache sharedImageCache] removeImageForKey:strUrl];
            
            [_imageView sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"cc_logon.png"]  options:SDWebImageRefreshCached];
            
//            NSURL* url = [NSURL URLWithString:strUrl];
//            UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
//            _imageView.image = image;
        }
        else
        {
            [CCToastView showToastViewContent:[dic objectForKey:@"reason"] andRect:TOAST_RECT andTime:1.5f];
        }
    }
}

- (void)createUI
{
    CCUserInfo* userinfo = [CCUserInfo defaultUserInfo];
    
    const NSInteger len = 40;
    
    CGFloat yPos = 80;
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(KSCREEN_WIDTH/2 - len/2, yPos, len, len)];
    NSURL* url = [NSURL URLWithString:userinfo.login_headimage];
    
//    [[SDImageCache sharedImageCache] removeImageForKey:userinfo.login_headimage];
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"cc_logon.png"] options:SDWebImageRefreshCached];
//    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
//    imageView.image = image;
    
    [self.view addSubview:imageView];
    _imageView = imageView;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    [imageView addGestureRecognizer:tapGes];
    
    yPos += len + 20;

    NSString* strUserName = [NSString stringWithFormat:@"昵称: %@", userinfo.login_userName];
    [CCUIComponentTool addLabelWithRect:CGRectMake(15, yPos, 200, 20) text:strUserName textColor:[CCUIComponentTool colorWithHexString:@"#aa6666"] fontSize:16 alignment:NSTextAlignmentLeft superview:self.view];
}

@end
