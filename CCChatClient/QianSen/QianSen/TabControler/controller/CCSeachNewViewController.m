//
//  CCSeachNewViewController.m
//  QianSen
//
//  Created by Kevin on 16/4/13.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCSeachNewViewController.h"
#import "CCUIComponentTool.h"
#import "CCToastView.h"
#import "CCTaskInfo.h"
#import "CCNetworkManager.h"
#import "CCSearchUserDataModel.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "CCUserInfo.h"

@interface CCSeachNewViewController()<UISearchBarDelegate>
{
    UISearchBar* _searchBar;
    UIView* _userView;
}

@property(nonatomic, strong) CCSearchUserDataModel* userDataModel;

@end

@implementation CCSeachNewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"搜索联系人";
    
    [self createUI];
}

- (void)createUI
{
    self.navigationItem.leftBarButtonItem = [CCUIComponentTool navigationBackBtn:self Sel:@selector(naviBack)];
    
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 5, KSCREEN_WIDTH - 20 - 5 - 30, 40)];
    _searchBar = searchBar;
    searchBar.delegate = self;
    
    searchBar.returnKeyType = UIReturnKeyDone;
    searchBar.barTintColor = [UIColor clearColor];
    searchBar.backgroundColor = [UIColor clearColor];
    UIView *view = [searchBar.subviews firstObject];
    UIView *backgroundView = [view.subviews firstObject];
    [backgroundView removeFromSuperview];
    searchBar.placeholder = @"请输入对方账号";
    
    UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, 50)];
    backView.backgroundColor = [CCUIComponentTool colorWithHexString:@"#888888"];
    [self.view addSubview:backView];
    [backView addSubview:searchBar];
    
    [CCUIComponentTool addButtonWithRect:CGRectMake(KSCREEN_WIDTH - 35, 5, 28, 40) title:@"确定" titleColor:[CCUIComponentTool colorWithHexString:@"fafafa"] titleSize:14 backColor:[UIColor clearColor] target:self sel:@selector(searchAccount) superview:backView];
}

- (void)addFriend
{
    NSString* strTemp = _searchBar.text;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_ADDFRIEND_NOTIFICATION object:nil];
    
    NSMutableDictionary* paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:@"addFriend" forKey:@"messagename"];
    [paramsDic setObject:[CCUserInfo defaultUserInfo].login_account forKey:@"account"];
    [paramsDic setObject:strTemp forKey:@"addAccount"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFrientResult:) name:CC_TASK_ADDFRIEND_NOTIFICATION object:nil];
    
    CCNetworkManager* netManager = [CCNetworkManager sharedInstance];
    NSURLSessionDataTask* task = [netManager GET:HTTP_ENTRANCE parameters:paramsDic];
    task.taskDescription = CC_TASK_ADDFRIEND_DESCPRITION;
}

- (void)addFrientResult:(id)sender
{
    id obj = [sender object];
    
    CC_Log(@"addFrientResult:(id)sender: %@", sender);
    
    if([obj isKindOfClass:[NSError class]])
    {
        [CCToastView showToastViewContent:@"网络错误" andRect:TOAST_RECT andTime:1.5f];
    }
    else if([obj isKindOfClass:[NSDictionary class]])
    {
        if([[obj objectForKey:@"result"] isEqualToString:@"1"])
        {
            [CCToastView showToastViewContent:@"添加成功" andRect:TOAST_RECT andTime:1.5f];
        }
        else
        {
            [CCToastView showToastViewContent:[obj objectForKey:@"message"] andRect:TOAST_RECT andTime:1.5f];
        }
    }
}

- (void)cancel
{
    UIView* backView = [self.view viewWithTag:100100];
    [backView removeFromSuperview];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [self searchAccount];
        return NO;
    }
    
    return YES;
}

- (void)searchAccount
{
    NSString* rexStr = @"^\\d*$";
    NSString* strText = _searchBar.text;
    
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", rexStr];
    BOOL bIsAllNum = [pre evaluateWithObject:strText];
    
    if(!bIsAllNum)
    {
        [CCToastView showToastViewContent:@"请输入数字账号" andRect:TOAST_RECT andTime:1.5f];
        return ;
    }
    
    [_searchBar resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_SEARCHACCOUNT_NOTIFICATION object:nil];
    
    NSMutableDictionary* paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:strText forKey:@"searchAccount"];
    [paramsDic setObject:@"searchAccount" forKey:@"messagename"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchResult:) name:CC_TASK_SEARCHACCOUNT_NOTIFICATION object:nil];
    
    CCNetworkManager* netManager = [CCNetworkManager sharedInstance];
    NSURLSessionDataTask* task = [netManager GET:HTTP_ENTRANCE parameters:paramsDic];
    task.taskDescription = CC_TASK_SEARCHACCOUNT_DESCPRITION;
    
}

- (void)showUserInfo
{
    UIView* backView = nil;
    
    if([self.view viewWithTag:100100])
    {
        backView = [self.view viewWithTag:100100];
    }
    else
    {
        backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.tag = 100100;
        backView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:backView];
    }
    backView.frame = CGRectMake(KSCREEN_WIDTH, 200, KSCREEN_WIDTH, 100);
    
    UIImageView* imageView = nil;
    if([backView viewWithTag:100101])
    {
        imageView = [backView viewWithTag:100101];
    }
    else
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 80, 80)];
        imageView.tag = 100101;
        [backView addSubview:imageView];
    }
    [[SDImageCache sharedImageCache] removeImageForKey:self.userDataModel.userHeadImage];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.userDataModel.userHeadImage] placeholderImage:[UIImage imageNamed:@"cc_logo.png" ]];
    
    CGRect imageFrame = imageView.frame;
    [CCUIComponentTool addLabelWithRect:CGRectMake(imageFrame.origin.x + imageFrame.size.width + 20, 0, 180, 80) text:self.userDataModel.userName textColor:[CCUIComponentTool colorWithHexString:@"#fa3333"] fontSize:13 alignment:NSTextAlignmentLeft tag:100102 superview:backView];

    if(self.userDataModel.userAccount != [CCUserInfo defaultUserInfo].login_account)
    {
        [CCUIComponentTool addButtonWithRect:CGRectMake(KSCREEN_WIDTH - 100, 20, 50, 40) title:@"加好友" titleColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] titleSize:13 backColor:[CCUIComponentTool colorWithHexString:@"#3333aa"] target:self sel:@selector(addFriend) superview:backView];
        [CCUIComponentTool addButtonWithRect:CGRectMake(KSCREEN_WIDTH - 45, 20, 30, 40) title:@"取消" titleColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] titleSize:13 backColor:[CCUIComponentTool colorWithHexString:@"#3333aa"] target:self sel:@selector(cancel) superview:backView];
    }
    
    [UIView beginAnimations:@"showUserInfo" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    CGRect rt = backView.frame;
    backView.frame = CGRectMake(0, rt.origin.y, KSCREEN_WIDTH, rt.size.height);
    
    [UIView commitAnimations];
}

- (void)searchResult:(id)sender
{
    id obj = [sender object];
    
    CC_Log(@"searchResult:(id)sender: %@", sender);
    
    if([obj isKindOfClass:[NSError class]])
    {
        [CCToastView showToastViewContent:@"网络错误" andRect:TOAST_RECT andTime:1.5f];
    }
    else if([obj isKindOfClass:[NSDictionary class]])
    {
        if([[obj objectForKey:@"result"] isEqualToString:@"1"])
        {
            NSError* error = nil;
            self.userDataModel = [[CCSearchUserDataModel alloc] initWithDictionary:obj error:&error];
            if(!error)
            {
                CC_Log("CCSearchUserDataModel: %@", self.userDataModel);
                [self showUserInfo];
            }
            else
            {
                CC_Log(@"initWithDictionary error: %@", error);
            }
        }
        else
        {
            [CCToastView showToastViewContent:[obj objectForKey:@"message"] andRect:TOAST_RECT andTime:1.5f];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)naviBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if(touch.view == self.view)
    {
        [_searchBar resignFirstResponder];
        return ;
    }
    
    [super touchesBegan:touches withEvent:event];
}

@end
