//
//  LoginViewController.m
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCLoginViewController.h"
#import "CCUIComponentTool.h"
#import "CCSystemTool.h"
#import "CCCheckBox.h"
#import "CCUserInfo.h"
#import "AFHTTPSessionManager.h"
#import "Global.h"
#import "CCErollViewController.h"
#import "CCTaskInfo.h"
#import "SecurityUtilities.h"
#import "CCNetworkManager.h"
#import "CCToastView.h"
#import "CCTabViewController.h"
#import "CCMyContactsViewController.h"
#import "CCUserInfoViewController.h"
#import "CCSocketService.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


@interface CCLoginViewController ()<UITextFieldDelegate,CCCheckBoxDelegate>
{
    UITextField* _currentTextField;
}

@end

@implementation CCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rt = [CCSystemTool applicationFrame];
    
    UITextField* textfieldAc = [CCUIComponentTool addTextFieldWithRect:CGRectMake(50, 120, rt.size.width - 50*2, 40) text:@"" placeholder:@"请输入账号" delegate:self tag:1001 superview:self.view];
    textfieldAc.layer.cornerRadius = 5;
    textfieldAc.layer.masksToBounds = YES;
    textfieldAc.layer.borderColor = [CCUIComponentTool colorWithHexString:@"#888888"].CGColor;
    textfieldAc.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    UITextField* textfieldPass = [CCUIComponentTool addTextFieldWithRect:CGRectMake(50, 180, rt.size.width - 50*2, 40) text:@"" placeholder:@"请输入密码" delegate:self tag:1002 superview:self.view];
    textfieldPass.secureTextEntry = YES;
    textfieldPass.layer.cornerRadius = 5;
    textfieldPass.layer.masksToBounds = YES;
    textfieldPass.layer.borderColor = [CCUIComponentTool colorWithHexString:@"#888888"].CGColor;
    textfieldPass.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    CCCheckBox* checkBox = [[CCCheckBox alloc] initWithFrame:CGRectMake(50, 220, 30, 30)];
    [self.view addSubview:checkBox];
    checkBox.checkDelegate = self;
    checkBox.selected = NO;
    
    NSString* strText = @"记住密码";
    CGSize sizeText = [CCUIComponentTool textSize:strText fontSize:13 constrainedToSize:CGSizeZero];
    [CCUIComponentTool addLabelWithRect:CGRectMake(80, 220, sizeText.width, 30) text:strText textColor:[CCUIComponentTool colorWithHexString:@"#3333ff"] fontSize:13 alignment:NSTextAlignmentLeft superview:self.view];
    
    NSString* strEnroll = @"注册新用户";
    CGSize sizeEnroll = [CCUIComponentTool textSize:strEnroll fontSize:13 constrainedToSize:CGSizeZero];
    sizeEnroll = CGSizeMake(sizeEnroll.width + 8, sizeEnroll.height);
    [CCUIComponentTool addButtonWithRect:CGRectMake(textfieldPass.frame.origin.x + textfieldPass.frame.size.width - sizeEnroll.width, 220, sizeEnroll.width, 30) title:strEnroll titleColor:[CCUIComponentTool colorWithHexString:@"#3333ff"] titleSize:13 backColor:[UIColor clearColor] target:self sel:@selector(enroll) superview:self.view];
    
    
    UILabel* labelTip = [CCUIComponentTool addLabelWithRect:CGRectMake(rt.size.width/2 - 180, 260, 180, 20) text:@"" textColor:[CCUIComponentTool colorWithHexString:@"#aa0000"] fontSize:13 alignment:NSTextAlignmentLeft superview:self.view];
    labelTip.tag = 30010;
    
    [CCUIComponentTool addButtonWithRect:CGRectMake(50, 300, rt.size.width - 50*2, 36) title:@"登录" titleColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] titleSize:15 backColor:[CCUIComponentTool colorWithHexString:@"#33aa33"] target:self sel:@selector(login) superview:self.view];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if(touch.view == self.view)
    {
        [_currentTextField resignFirstResponder];
        _currentTextField = nil;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextField = textField;
}

- (void) enroll
{
    CCErollViewController* erollVc = [[CCErollViewController alloc] init];
    [self.navigationController pushViewController:erollVc animated:YES];
}

- (void) login
{
    UITextField* accountTextFd = [self.view viewWithTag:1001];
    NSString* strAccount = accountTextFd.text;
    if([strAccount isEqualToString:@""])
    {
        [self showTip:@"*用户名不能为空"];
        return ;
    }
    
    UITextField* passwordTextFd = [self.view viewWithTag:1002];
    NSString* strPassword = passwordTextFd.text;
    if([strPassword isEqualToString:@""])
    {
        [self showTip:@"*密码不能为空"];
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_LOGIN_NOTIFICATION object:nil];
    
    NSMutableDictionary* paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:strAccount forKey:@"account"];
    [paramsDic setObject:[strPassword doubleMD5String] forKey:@"password"];
    [paramsDic setObject:@"login" forKey:@"messagename"];
    [paramsDic setObject:[@"test" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"test"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginResult:) name:CC_TASK_LOGIN_NOTIFICATION object:nil];
    
    CCNetworkManager* netManager = [CCNetworkManager sharedInstance];
    NSURLSessionDataTask* task = [netManager POST:HTTP_ENTRANCE parameters:paramsDic];
    task.taskDescription = CC_TASK_LOGIN_DESCPRITION;
}

- (void) gotoMainUI
{
    // 创建tabBarViewController
    CCTabViewController* tabVc = [[CCTabViewController alloc] init];
    tabVc.tabBar.barTintColor = [CCUIComponentTool colorWithHexString:@"88aa88"];
    tabVc.delegate = tabVc;
    tabVc.tabBar.hidden = YES;
    
    // 联系人tab
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:[[CCMyContactsViewController alloc] init]];
    navi.navigationBar.barTintColor = K_NAVI_COLOR;
    navi.navigationBar.translucent = NO;
    
    UIImage* imageItem = [UIImage imageNamed:@"cc_tabbar_contact"];
    imageItem = [imageItem imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage* imageItem2 = [UIImage imageNamed:@"cc_tabbar_contact_selected"];
    imageItem2 = [imageItem2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"联系人" image:imageItem selectedImage:imageItem2];
    
    navi.tabBarItem = item;
    
    // 用户信息tab
    UINavigationController* naviUser = [[UINavigationController alloc] initWithRootViewController:[[CCUserInfoViewController alloc] init]];
    naviUser.navigationBar.barTintColor = K_NAVI_COLOR;
    naviUser.navigationBar.translucent = NO;
    tabVc.viewControllers = @[navi];
    
    UIImage* imageItemUser = [UIImage imageNamed:@"cc_tabbar_userinfo"];
    imageItemUser = [imageItemUser imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage* imageItemUser2 = [UIImage imageNamed:@"cc_tabbar_userinfo_selected"];
    imageItemUser2 = [imageItemUser2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem* itemUser = [[UITabBarItem alloc] initWithTitle:@"我" image:imageItemUser selectedImage:imageItemUser2];
    naviUser.tabBarItem = itemUser;
    
    tabVc.viewControllers = @[navi, naviUser];
    [tabVc setSelectedViewController:navi];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = tabVc;
}

- (void)loginResult:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_LOGIN_NOTIFICATION object:nil];
    
    CC_Log(@"erollResult:(id)sender: %@", sender);
    
    id object = [(NSNotification*)sender object];
    
    if([object isKindOfClass:[NSError class]])
    {
        [CCToastView showToastViewContent:@"网络错误, 请稍后重试" andRect:TOAST_RECT andTime:2.0f];
        return ;
    }
    
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* tempDic = (NSDictionary*)object;
        if([[tempDic objectForKey:@"result"] isEqualToString:@"1"])
        {
            NSDictionary* userDic = [tempDic objectForKey:@"userinfo"];
            if(userDic)
            {
                NSString* username = [userDic objectForKey:@"username"];
                NSString* headimage = [userDic objectForKey:@"headimage"];
                if(!headimage)
                    headimage = @"";
                NSString* account = [userDic objectForKey:@"account"];
                
                CCUserInfo* userInfo = [CCUserInfo defaultUserInfo];
                userInfo.login_userName = username;
                userInfo.login_headimage = headimage;
                userInfo.login_account = account;
                userInfo.login_status = @"1";
                
                [self gotoMainUI];
                
                CCSocketService* service = [CCSocketService defaultSocketService];
                [service loginService];
            }
            else
            {
                [CCToastView showToastViewContent:@"返回用户信息错误" andRect:TOAST_RECT andTime:1.5f];
            }
        }
        else
        {
            [CCToastView showToastViewContent:[tempDic objectForKey:@"message"] andRect:TOAST_RECT andTime:2.0f];
        }
    }
}

- (void)checkStatus:(BOOL)checked
{
    if(checked)
    {
        [CCUserInfo defaultUserInfo].login_Always = @"1";
    }
    else
    {
        [CCUserInfo defaultUserInfo].login_Always = @"0";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTip:(NSString*)strText
{
    UILabel* label = [self.view viewWithTag:30010];
    label.text = strText;
}

@end


