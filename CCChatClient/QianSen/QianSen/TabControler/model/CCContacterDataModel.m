//
//  CCContacterDataModel.m
//  QianSen
//
//  Created by Kevin on 16/5/27.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCContacterDataModel.h"

@implementation CCContacterSectionDataModel

+ modelWithTitle:(NSString*)title subtitle:(NSString*)subtitle cells:(NSArray*)cellData
{
    CCContacterSectionDataModel* secModel = [[self alloc] init];
    secModel.title = title;
    secModel.subTitle = subtitle;
    secModel.cells = cellData;
    
    return secModel;
}

@end

@implementation CCContacterCellDataModel

@end

@implementation CCContacterMessage

@end
