//
//  CCContacterDataModel.h
//  QianSen
//
//  Created by Kevin on 16/5/27.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCContacterSectionDataModel : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* subTitle;
@property(nonatomic, strong) NSArray* cells;

+ modelWithTitle:(NSString*)title subtitle:(NSString*)subtitle cells:(NSArray*)cellData;

@end

@interface CCContacterCellDataModel : NSObject

@property(nonatomic, strong) NSString* account;
@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSString* headImageurl;
@property(nonatomic, assign) BOOL bIsDisplay;
@property(nonatomic, strong) NSMutableArray* messages;

@end

@interface CCContacterMessage : NSObject

@property(nonatomic, assign) NSUInteger nType; // 消息类型 3 文字消息, 4 语音消息
@property(nonatomic, strong) NSString* text;
@property(nonatomic, assign) BOOL isRead;
@property(nonatomic, assign) NSInteger whoseMessage; //0 对方消息  1 己方消息

@end





