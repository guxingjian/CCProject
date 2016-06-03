//
//  SecurityUtilities.m
//  Security
//
//  Created by Kevin on 16/4/5.
//  Copyright © 2016年 Kevin. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "SecurityUtilities.h"

@implementation NSString(MD5Test)

- (NSString*)MD5String
{
    const char* cStr = [self UTF8String];
    unsigned char buffer[CC_MD5_DIGEST_LENGTH] = {};
    CC_MD5(cStr, sizeof(buffer), buffer);
    
    NSString* strTemp = [NSString string];
    
    for(NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; ++ i)
    {
        strTemp = [strTemp stringByAppendingString:[NSString stringWithFormat:@"%02x", buffer[i]]];
    }
    
    return strTemp;
}

- (NSString*)doubleMD5String
{
    return [[self MD5String] MD5String];
}

@end
