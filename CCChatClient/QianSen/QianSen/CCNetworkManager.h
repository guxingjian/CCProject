

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
@interface CCNetworkManager : NSObject

@property(nonatomic, strong) AFHTTPSessionManager* sessionManager;

+ (CCNetworkManager* __nonnull)sharedInstance;

- (NSURLSessionDataTask *)GET:(NSString*)URLString
                            parameters:(NSDictionary*)parameters;
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(NSDictionary*)parameters;
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary*)params constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block;

@end
