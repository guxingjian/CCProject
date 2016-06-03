//
//  DataBaseTool.m
//  QianSen
//
//  Created by Kevin on 16/1/11.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import "CCDataBaseTool.h"
#import "CCUserInfo.h"
#import "CCUserInfo_Entity.h"
#import "Global.h"

@interface CCDataBaseTool()

@property(nonatomic, strong) NSManagedObjectContext* managedContext;

@end

@implementation CCDataBaseTool

- (NSManagedObjectContext*)managedContext
{
    if(!_managedContext)
    {
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"QianSen" withExtension:@"momd"];
        NSLog(@"url: %@", url);
        
        NSManagedObjectModel* model = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
        
        NSPersistentStoreCoordinator* perCoor = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        _managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedContext setPersistentStoreCoordinator:perCoor];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSURL* dbUrl = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        dbUrl = [dbUrl URLByAppendingPathComponent:@"QianSen.sqlite"];
        
        NSError* error = nil;
        [perCoor addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbUrl options:nil error:&error];
        if(error)
        {
            CC_Log(@"add sqlite file failed! error: %@", error);
            return nil;
        }
    }
    
    return _managedContext;
}

- (QianSenUserInfo*)loadUserInfo
{
    return [CCUserInfo_Entity loadUserInfo:self.managedContext];
}

- (BOOL)updateUserInfo
{
    return [CCUserInfo_Entity updateUserInfo:self.managedContext];
}

- (NSArray*)erollHistory
{
    return nil;
}

- (void)addErollRecord
{
    
}

@end
