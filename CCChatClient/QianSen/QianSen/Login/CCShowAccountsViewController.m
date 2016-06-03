//
//  CCShowAccountViewController.m
//  QianSen
//
//  Created by Kevin on 16/4/8.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCShowAccountsViewController.h"
#import "CCDataBaseTool.h"
#import "CCUIComponentTool.h"

@interface CCShowAccountsViewController ()

@end

@implementation CCShowAccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(!self.strNewAcc || [self.strNewAcc isEqualToString:@""]) // 没有新账号, 默认显示历史记录
    {
        NSArray* array = [[[CCDataBaseTool alloc] init] erollHistory];
        
        self.navigationItem.leftBarButtonItem = [CCUIComponentTool navigationBackBtn:self Sel:@selector(gotoBack)];
    }
    else // 显示单独的账号
    {
        NSString* strText = [NSString stringWithFormat:@"您已成功申请账号 %@, 快去登录吧~",self.strNewAcc];
        CGSize sizeText = [CCUIComponentTool textSize:strText fontSize:15 constrainedToSize:CGSizeMake(280, 1000)];
        [CCUIComponentTool addLabelWithRect:CGRectMake(KSCREEN_WIDTH/2 - sizeText.width/2, 200, sizeText.width, sizeText.height) text:strText textColor:[CCUIComponentTool colorWithHexString:@"#338833"] fontSize:15 alignment:NSTextAlignmentLeft superview:self.view];
        
        self.navigationItem.leftBarButtonItem = [CCUIComponentTool navigationBackBtn:self Sel:@selector(gotoLogin)];
    }
}

- (void)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoLogin
{
    NSArray* array = self.navigationController.viewControllers;
    for(NSInteger i = 0; i < array.count; ++ i)
    {
        UIViewController* vc = [array objectAtIndex:i];
        if([vc isKindOfClass:NSClassFromString(@"CCLoginViewController")])
        {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
