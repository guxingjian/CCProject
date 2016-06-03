

#import "CCNetworkManager.h"
#import "CCTaskInfo.h"

@interface CCNetworkManager ()

@end

@implementation CCNetworkManager

+ (CCNetworkManager *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static CCNetworkManager * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[CCNetworkManager alloc] init];
    });
    return sSharedInstance;
}

- (AFHTTPSessionManager*)sessionManager
{
    if(!_sessionManager)
    {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    
    return _sessionManager;
}

- (NSURLSessionDataTask *)GET:(NSString*)URLString
                   parameters:(NSDictionary*)parameters
{
    __weak CCNetworkManager* netManager = self;
    
    return [self.sessionManager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self taskSuccess:task data:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [netManager taskError:task error:error];
    }];
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(NSDictionary*)parameters
{
    __weak CCNetworkManager* netManager = self;
    
    return [self.sessionManager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [netManager taskSuccess:task data:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [netManager taskError:task error:error];
    }];
}

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary*)params constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
{
    __weak CCNetworkManager* netManager = self;
    return [self.sessionManager POST:URLString parameters:params constructingBodyWithBlock:block progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [netManager taskSuccess:task data:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [netManager taskError:task error:error];
    }];
}

- (void)taskSuccess:(NSURLSessionDataTask*)task data:(id)data
{
    NSString* strDes = [task taskDescription];
    if([strDes isEqualToString:CC_TASK_EROLLNEWUSER_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_EROLLNEWUSER_NOTIFICATION object:data];
    }
    else if([strDes isEqualToString:CC_TASK_LOGIN_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_LOGIN_NOTIFICATION object:data];
    }
    else if([strDes isEqualToString:CC_TASK_UPLOADHEADIMAGE_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_UPLOADHEADIMAGE_NOTIFICATION object:data];
    }
    else if([strDes isEqualToString:CC_TASK_SEARCHACCOUNT_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_SEARCHACCOUNT_NOTIFICATION object:data];
    }
    else if([strDes isEqualToString:CC_TASK_ADDFRIEND_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_ADDFRIEND_NOTIFICATION object:data];
    }
    else if([strDes isEqualToString:CC_TASK_GETFRIENDSLIST_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_GETFRIENDSLIST_NOTIFICATION object:data];
    }
}

- (void)taskError:(NSURLSessionDataTask*)task error:(NSError*)error
{
    NSString* strDes = [task taskDescription];
    if([strDes isEqualToString:CC_TASK_EROLLNEWUSER_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_EROLLNEWUSER_NOTIFICATION object:error];
    }
    else if([strDes isEqualToString:CC_TASK_LOGIN_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_LOGIN_NOTIFICATION object:error];
    }
    else if([strDes isEqualToString:CC_TASK_UPLOADHEADIMAGE_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_UPLOADHEADIMAGE_NOTIFICATION object:error];
    }
    else if([strDes isEqualToString:CC_TASK_SEARCHACCOUNT_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_SEARCHACCOUNT_NOTIFICATION object:error];
    }
    else if([strDes isEqualToString:CC_TASK_ADDFRIEND_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_ADDFRIEND_NOTIFICATION object:error];
    }
    else if([strDes isEqualToString:CC_TASK_GETFRIENDSLIST_DESCPRITION])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_TASK_ADDFRIEND_NOTIFICATION object:error];
    }
}

- (void)dealloc
{
    [self.sessionManager invalidateSessionCancelingTasks:YES];
}

//
//- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
//{
//    NSString *  result;
//    CFUUIDRef   uuid;
//    CFStringRef uuidStr;
//    
//    uuid = CFUUIDCreate(NULL);
//    assert(uuid != NULL);
//    
//    uuidStr = CFUUIDCreateString(NULL, uuid);
//    assert(uuidStr != NULL);
//    
//    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
//    assert(result != nil);
//    
//    CFRelease(uuidStr);
//    CFRelease(uuid);
//    
//    return result;
//}


@end
