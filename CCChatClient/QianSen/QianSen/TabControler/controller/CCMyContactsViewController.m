//
//  CCMyContactsViewController.m
//  QianSen
//
//  Created by Kevin on 16/4/12.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCMyContactsViewController.h"
#import "CCSeachNewViewController.h"
#import "CCContacterDataModel.h"
#import "UIImageView+WebCache.h"
#import "CCUIComponentTool.h"
#import "CCTaskInfo.h"
#import "CCUserInfo.h"
#import "CCNetworkManager.h"
#import "CCToastView.h"
#import "CCChatController.h"
#import "CCSocketService.h"
#import "CCSystemTool.h"

static const CGFloat cell_height = 80;
static const CGFloat header_height = 50;

@interface CCMyContactsViewController()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView* tableView;
@property(nonatomic, strong) NSArray* sections;

@end

@implementation CCMyContactsViewController
{
    CCContacterCellDataModel* _selectedCell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"联系人";
    
    [self createUI];
    
    [self getContacterList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    
    _selectedCell = nil;
}

- (void)getContacterList
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CC_TASK_GETFRIENDSLIST_NOTIFICATION object:nil];
    
    NSMutableDictionary* paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:@"getFriends" forKey:@"messagename"];
    [paramsDic setObject:[CCUserInfo defaultUserInfo].login_account forKey:@"account"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContacterListResult:) name:CC_TASK_GETFRIENDSLIST_NOTIFICATION object:nil];
    
    CCNetworkManager* netManager = [CCNetworkManager sharedInstance];
    NSURLSessionDataTask* task = [netManager GET:HTTP_ENTRANCE parameters:paramsDic];
    task.taskDescription = CC_TASK_GETFRIENDSLIST_DESCPRITION;
}

- (void)getContacterListResult:(id)sender
{
    id obj = [sender object];
    
    CC_Log(@"getContacterListResult:%@", obj);
    
    if([obj isKindOfClass:[NSError class]])
    {
        [CCToastView showToastViewContent:@"网络错误" andRect:TOAST_RECT andTime:1.5f];
    }
    else if([obj isKindOfClass:[NSDictionary class]])
    {
        if([[obj objectForKey:@"result"] isEqualToString:@"1"])
        {
            NSArray* friends = [obj objectForKey:@"friends"];
            
            NSMutableArray* cells = [NSMutableArray array];
            for(NSDictionary* dic in friends)
            {
                CCContacterCellDataModel* cellModel = [[CCContacterCellDataModel alloc] init];
                cellModel.account = [dic objectForKey:@"account"];
                cellModel.headImageurl = [dic objectForKey:@"headimage"];
                cellModel.username = [dic objectForKey:@"username"];
               
                [cells addObject:cellModel];
            }
            
            CCContacterSectionDataModel* secModel = [self.sections objectAtIndex:0];
            secModel.cells = cells;
            
            [self.tableView reloadData];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveMessage:) name:CC_RECIEVEDATA_MESSAGE object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveAudio:) name:CC_RECIEVEDATA_AUDIO object:nil];
        }
        else if([[obj objectForKey:@"result"] isEqualToString:@"1"])
        {
            [CCToastView showToastViewContent:[obj objectForKey:@"message"] andRect:TOAST_RECT andTime:1.5f];
        }
    }
}

- (void)recieveAudio:(NSNotification*)notification
{
//    CC_Log(@"recieveAudio notification: %@", notification);
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSString* friendAcc = [userInfo objectForKey:CC_AudioFriendAccountKey];
    if(_selectedCell)
    {
        if([friendAcc isEqualToString:_selectedCell.account])
            return ;
    }
    
    NSString* audioPath = [userInfo objectForKey:CC_AudioPathKey];
    NSData* audioData = [userInfo objectForKey:CC_AudioDataKey];
    
    CC_Log(@"recieveAudio friendAcc: %@, audioPath: %@", friendAcc, audioPath);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *urlStr = [CCSystemTool getSandBoxPathOfAudioWithName:audioPath];
        if(!urlStr)
        {
            CC_Log(@"directory not existed");
            return ;
        }
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:urlStr])
        {
            BOOL bRet = [[NSFileManager defaultManager] createFileAtPath:urlStr contents:audioData attributes:nil];
            if(!bRet)
            {
                CC_Log(@"write audio data error");
                return ;
            }
        }
        else
        {
            NSError* error = nil;
            NSFileHandle* fileHandler = [NSFileHandle fileHandleForWritingToURL:[NSURL URLWithString:urlStr] error:&error];
            if(error)
            {
                CC_Log(@"fileHandleForWritingToURL error: %@", error);
            }
            
            [fileHandler writeData:audioData];
            [fileHandler closeFile];
        }
    });
    
    CCContacterMessage* messageModel = [[CCContacterMessage alloc] init];
    messageModel.text = audioPath;
    messageModel.isRead = NO;
    messageModel.whoseMessage = 0;
    messageModel.nType = 4;
    
    NSIndexPath* indexPath = nil;
    CCContacterCellDataModel* cellModel = [self getFriendCellData:friendAcc indexPath:&indexPath];
    if(!cellModel)
        return ;
    
    if(cellModel.bIsDisplay)
        return ;
    
    if(!cellModel.messages)
    {
        cellModel.messages = [NSMutableArray array];
    }
    
    [cellModel.messages addObject:messageModel];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (id)getFriendCellData:(NSString*)friendAcc indexPath:(NSIndexPath**)indexPath
{
    NSInteger nSection = 0;
    for(CCContacterSectionDataModel* secModel in self.sections)
    {
        NSInteger nRow = 0;
        for(CCContacterCellDataModel* cellModel in secModel.cells)
        {
            if([cellModel.account isEqualToString:friendAcc])
            {
                *indexPath = [NSIndexPath indexPathForRow:nRow inSection:nSection];
                
                return cellModel;
            }
            
            nRow ++;
        }
        
        nSection ++;
    }
    
    return nil;
}

- (void)recieveMessage:(NSNotification*)notification
{
    CC_Log(@"recieveMessage notification: %@", notification);
    
    id obj = [notification object];
    if(![obj isKindOfClass:[NSString class]])
    {
        return ;
    }
    
    NSString* text = obj;
    CC_Log(@"text: %@", text);
    
    NSArray* array = [text componentsSeparatedByString:@","];
    if(array.count < 3)
    {
        CC_Log(@"recieveMessage: wrong message format");
        return ;
    }
    
    NSString* acc = [array objectAtIndex:0];
    NSString* friendAcc = [array objectAtIndex:1];
    
    NSIndexPath* indexPath = nil;
    
    CCContacterCellDataModel* cellModel = [self getFriendCellData:friendAcc indexPath:&indexPath];
    if(!cellModel)
        return ;
    
    if(cellModel.bIsDisplay)
        return ;
    
    if(!cellModel.messages)
    {
        cellModel.messages = [NSMutableArray array];
    }
    
    NSString* message = [text substringFromIndex:(acc.length + 1 + friendAcc.length + 1)];
    
    CCContacterMessage* messageModel = [[CCContacterMessage alloc] init];
    messageModel.text = message;
    messageModel.isRead = NO;
    messageModel.whoseMessage = 0;
    messageModel.nType = 3;
    
    [cellModel.messages addObject:messageModel];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)createUI
{
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,50, 30)];
    [btn addTarget:self action:@selector(addContacter) forControlEvents:UIControlEventTouchUpInside];
    
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:@"添加" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSMutableArray* arraySec = [NSMutableArray array];
    
    CCContacterSectionDataModel* secModel = [[CCContacterSectionDataModel alloc] init];
    secModel.title = @"我的好友";
    secModel.subTitle = @"0/0";
    [arraySec addObject:secModel];
    
    self.sections = arraySec;
    
    UITableView* tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT - 40*2) style:UITableViewStylePlain];
    [self.view addSubview:tbView];
    self.tableView = tbView;
    
    tbView.dataSource = self;
    tbView.delegate = self;
    
    [tbView reloadData];
}

- (void)addContacter
{
    CCSeachNewViewController* seachVc = [[CCSeachNewViewController alloc] init];
    
    [self.navigationController pushViewController:seachVc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CCContacterSectionDataModel* model = [self.sections objectAtIndex:section];
    return model.cells.count;
}

- (void)decorateCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    CCContacterSectionDataModel* secData = [self.sections objectAtIndex:indexPath.section];
    
    CCContacterCellDataModel* cellData = [secData.cells objectAtIndex:indexPath.row];
    
//    [[SDImageCache sharedImageCache] removeImageForKey:cellData.headImageurl];
    
    UIImageView* imageView = [cell.contentView viewWithTag:10000 + 1];
    NSArray* modes = @[NSDefaultRunLoopMode];
    if(!imageView)
    {
        UIImageView* tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 60, 60)];
        [cell.contentView addSubview:tempImageView];
        imageView = tempImageView;
        
        imageView.tag = 10000 + 1;
    }
    
    [imageView performSelector:@selector(sd_setImageWithURL:) withObject:[NSURL URLWithString:cellData.headImageurl] afterDelay:0 inModes:modes];
    
    UILabel* label = [cell.contentView viewWithTag:10000 + 2];
    CGSize sizeUserName = [CCUIComponentTool textSize:cellData.username fontSize:15 constrainedToSize:CGSizeZero];
    if(!label)
    {
        label = [CCUIComponentTool addLabelWithRect:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + 20, cell_height/2 - sizeUserName.height/2, sizeUserName.width, sizeUserName.height) text:cellData.username textColor:[CCUIComponentTool colorWithHexString:@"#333333"] fontSize:15 alignment:NSTextAlignmentLeft superview:cell.contentView];
        label.tag = 10000 + 2;
    }
    else
    {
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, sizeUserName.width, sizeUserName.height);
        label.text = cellData.username;
    }
    
    NSInteger unReadCount = 0;
    for(CCContacterMessage* messageModel in cellData.messages)
    {
        if(!messageModel.isRead)
        {
            unReadCount ++;
        }
    }
    
    UILabel* labelCount = [cell.contentView viewWithTag:10000 + 3];
        
    if(!labelCount)
    {
        if(0 == unReadCount)
            return ;
        
        const CGFloat fLen = 20;
        labelCount = [CCUIComponentTool addLabelWithRect:CGRectMake(KSCREEN_WIDTH - 30, cell_height/2 - fLen/2, fLen, fLen) text:[NSString stringWithFormat:@"%ld", unReadCount] textColor:[CCUIComponentTool colorWithHexString:@"#ffffff"] fontSize:11 alignment:NSTextAlignmentCenter superview:cell.contentView];
        labelCount.backgroundColor = [CCUIComponentTool colorWithHexString:@"#fd3131"];
        
        labelCount.layer.cornerRadius = fLen/2;
        labelCount.layer.masksToBounds = YES;
        
        labelCount.tag = 10000 + 3;
    }
    else
    {
        if(0 == unReadCount)
        {
            labelCount.hidden = YES;
            return ;
        }
        else
        {
            labelCount.hidden = NO;
            labelCount.text = [NSString stringWithFormat:@"%ld", unReadCount];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strKey = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strKey];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strKey];
    }
    
    [self decorateCell:cell indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cell_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return header_height;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString* header = @"header";
    UITableViewHeaderFooterView* headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if(!headerView)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
    }
    
    CCContacterSectionDataModel* secModel = [self.sections objectAtIndex:section];
    CGSize titleSize = [CCUIComponentTool textSize:secModel.title fontSize:13 constrainedToSize:CGSizeZero];
    CGSize subTitleSize = [CCUIComponentTool textSize:secModel.subTitle fontSize:13 constrainedToSize:CGSizeZero];
    
    UILabel* labelTitle = [headerView viewWithTag:10000 + section*100 + 1];
    if(!labelTitle)
    {
        labelTitle = [CCUIComponentTool addLabelWithRect:CGRectMake(10, header_height/2 - titleSize.height/2, titleSize.width, titleSize.height) text:secModel.title textColor:[CCUIComponentTool colorWithHexString:@"888888"] fontSize:13 alignment:NSTextAlignmentLeft superview:headerView];
        labelTitle.tag = 10000 + section*100 + 1;
    }
    else
    {
        labelTitle.text = secModel.title;
    }
    
    UILabel* labelSubTitle = [headerView viewWithTag:10000 + section*100 + 2];
    if(!labelSubTitle)
    {
        labelSubTitle = [CCUIComponentTool addLabelWithRect:CGRectMake(KSCREEN_WIDTH - 10 - subTitleSize.width, header_height/2 - subTitleSize.height/2, subTitleSize.width, subTitleSize.height) text:secModel.subTitle textColor:[CCUIComponentTool colorWithHexString:@"888888"] fontSize:13 alignment:NSTextAlignmentLeft superview:headerView];
        labelSubTitle.tag = 10000 + section*100 + 2;
    }
    else
    {
        labelSubTitle.text = secModel.subTitle;
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CC_Log(@"select cell indexpath: %@", indexPath);
    
    CCContacterSectionDataModel* secData = [self.sections objectAtIndex:indexPath.section];
    CCContacterCellDataModel* cellData = [secData.cells objectAtIndex:indexPath.row];
    
    _selectedCell = cellData;
    
    for(CCContacterMessage* messageModel in cellData.messages)
    {
        messageModel.isRead = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
    
    CCChatController* chatVc = [[CCChatController alloc] init];
    chatVc.cellModel = cellData;
    
    [self.navigationController pushViewController:chatVc animated:YES];
    
//    CCSocketService* server = [CCSocketService defaultSocketService];
//    
//    [server sendMessage:@"你好, 朋友" friendAccount:cellData.account];
}

@end
