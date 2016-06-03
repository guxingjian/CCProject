//
//  CCSearchUserDataModel.h
//  QianSen
//
//  Created by Kevin on 16/4/18.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface CCSearchUserDataModel : JSONModel

@property(nonatomic, strong) NSString* result;
@property(nonatomic, strong) NSString* message;
@property(nonatomic, strong) NSString* userAccount;
@property(nonatomic, strong) NSString* userName;
@property(nonatomic, strong) NSString* userHeadImage;

@end
