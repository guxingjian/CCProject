//
//  QianSenErollViewController.m
//  QianSen
//
//  Created by Kevin on 16/4/7.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCErollViewController.h"
#import "CCUIComponentTool.h"
#import "CCSystemTool.h"
#import "AFHTTPSessionManager.h"
#import "SecurityUtilities.h"
#import "CCToastView.h"
#import "CCShowAccountsViewController.h"
#import "CCNetworkManager.h"
#import "CCTaskInfo.h"

@interface CCErollViewController ()<UITextFieldDelegate>

@end

@implementation CCErollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [CCUIComponentTool navigationBackBtn:self Sel:@selector(navigationBack)];
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    CGRect rt = [CCSystemTool applicationFrame];
    
    UITextField* textfieldAc = [CCUIComponentTool addTextFieldWithRect:CGRectMake(50, 60, rt.size.width - 50*2, 40) text:@"" placeholder:@"请输入用户名" delegate:self tag:1001 superview:self.view];
    textfieldAc.layer.cornerRadius = 5;
    textfieldAc.layer.masksToBounds = YES;
    textfieldAc.layer.borderColor = [CCUIComponentTool colorWithHexString:@"#888888"].CGColor;
    textfieldAc.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    UITextField* textfieldPass = [CCUIComponentTool addTextFieldWithRect:CGRectMake(50, 120, rt.size.width - 50*3, 40) text:@"" placeholder:@"请输入密码" delegate:self tag:1002 superview:self.view];
    [textfieldPass addTarget:self action:@selector(edittingChanged:) forControlEvents:UIControlEventEditingChanged];
    textfieldPass.secureTextEntry = YES;
    textfieldPass.layer.cornerRadius = 5;
    textfieldPass.layer.masksToBounds = YES;
    textfieldPass.layer.borderColor = [CCUIComponentTool colorWithHexString:@"#888888"].CGColor;
    textfieldPass.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    UITextField* textfieldPass1 = [CCUIComponentTool addTextFieldWithRect:CGRectMake(50, 180, rt.size.width - 50*3, 40) text:@"" placeholder:@"请输入确认密码" delegate:self tag:1003 superview:self.view];
    [textfieldPass1 addTarget:self action:@selector(edittingChanged:) forControlEvents:UIControlEventEditingChanged];
    textfieldPass1.secureTextEntry = YES;
    textfieldPass1.layer.cornerRadius = 5;
    textfieldPass1.layer.masksToBounds = YES;
    textfieldPass1.layer.borderColor = [CCUIComponentTool colorWithHexString:@"#888888"].CGColor;
    textfieldPass1.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    UILabel* labelTip = [CCUIComponentTool addLabelWithRect:CGRectMake(50, 230, 300, 20) text:@"" textColor:[CCUIComponentTool colorWithHexString:@"#aa0000"] fontSize:13 alignment:NSTextAlignmentLeft superview:self.view];
    labelTip.tag = 2001;
    
    [CCUIComponentTool addButtonWithRect:CGRectMake(50, 280, rt.size.width - 50*2, 36) title:@"注册" titleColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] titleSize:15 backColor:[CCUIComponentTool colorWithHexString:@"#33aa33"] target:self sel:@selector(eroll) superview:self.view];
}

- (void)eroll
{
    UITextField* user = [self.view viewWithTag:1001];
    if([user.text isEqualToString:@""])
    {
        [self showTip:@"*请输入用户名"];
        return ;
    }
    
    UITextField* pw = [self.view viewWithTag:1002];
    if([pw.text isEqualToString:@""])
    {
        [self showTip:@"*请输入密码"];
        return ;
    }
    
    UITextField* pw2 = [self.view viewWithTag:1003];
    if([pw2.text isEqualToString:@""])
    {
        [self showTip:@"*请输入确认密码"];
        return ;
    }
    
    if(![pw.text isEqualToString:pw2.text])
    {
        [self showTip:@"*确认密码与密码不符"];
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_EROLLNEWUSER_NOTIFICATION object:nil];
    
    NSMutableDictionary* paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:user.text forKey:@"username"];
    [paramsDic setObject:[pw.text doubleMD5String] forKey:@"password"];
    [paramsDic setObject:@"register" forKey:@"messagename"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(erollResult:) name:CC_TASK_EROLLNEWUSER_NOTIFICATION object:nil];
    
    CCNetworkManager* netManager = [CCNetworkManager sharedInstance];
    NSURLSessionDataTask* task = [netManager POST:HTTP_ENTRANCE parameters:paramsDic];
    task.taskDescription = CC_TASK_EROLLNEWUSER_DESCPRITION;
    
//    AFHTTPSessionManager* sessionMg = [AFHTTPSessionManager manager];
//    
//    __weak AFHTTPSessionManager* mg = sessionMg;
//    __weak CCErollViewController* weakSelf = self;
//    
//    [sessionMg POST:HTTP_ENTRANCE parameters:paramsDic progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [weakSelf erollResult:responseObject];
//        [mg invalidateSessionCancelingTasks:YES];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        CC_Log(@"error: %@", error);
//        [weakSelf erollResult:error];
//    }];
}

- (void)erollResult:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_EROLLNEWUSER_NOTIFICATION object:nil];
    
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
//            [CCToastView showToastViewContent:@"注册成功" andRect:TOAST_RECT andTime:2.0f];
            
            CCShowAccountsViewController* vc = [[CCShowAccountsViewController alloc] init];
            vc.strNewAcc = [tempDic objectForKey:@"userAccount"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [CCToastView showToastViewContent:[tempDic objectForKey:@"message"] andRect:TOAST_RECT andTime:2.0f];
        }
    }
}

- (void)edittingChanged:(UITextField*)textfield
{
    if(1002 == textfield.tag || 1003 == textfield.tag)
    {
        if(![self comparePws])
        {
            [self showTip:@"*确认密码与密码不符"];
        }
        else
        {
            [self showTip:@""];
        }
    }
}

- (BOOL)comparePws
{
    UITextField* pw = [self.view viewWithTag:1002];
    UITextField* pw2 = [self.view viewWithTag:1003];
    
    if([pw.text isEqualToString:@""] || [pw2.text isEqualToString:@""])
        return YES;
    
    NSRange subRang = [pw.text rangeOfString:pw2.text];
    
    if(subRang.length > 0)
        return YES;
    
    return NO;
}

- (void)showTip:(NSString*)strText
{
    UILabel* label = [self.view viewWithTag:2001];
    label.text = strText;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
