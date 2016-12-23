//
//  QWURLEncodeEngine.m
//  QQWalletSDK
//
//  Created by stonedong on 14-4-2.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "QWURLEncodeEngine.h"
#import "QQWalletDefines.h"
#import "QWApplication.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

NSString* const kQWURLKeyAction      = @"action";
NSString* const kQWURLKeyParams      = @"params";
NSString* const kQWURLKeyApplication = @"application";

@implementation QWURLEncodeEngine

+ (NSURL*) encodeWithAction:(NSDictionary *)action
                     params:(NSDictionary *)params
                      error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary* infos = [NSMutableDictionary new];
    if (action) {
        infos[kQWURLKeyAction] = action;
    }
    if (params) {
        infos[kQWURLKeyParams] = params;
    }
    infos[kQWURLKeyApplication] = [[QWApplication sharedApplication] dictionaryWithAllValues];
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"%@://",kQWURLScheme];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infos options:0 error:&jsonError];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonError) {
        [urlString appendString:[jsonData base64Encoding]];
    }
    
    NSURL* url = [NSURL URLWithString:urlString];
    if (!url) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:kQWErrorDomain code:QWErrorParamsError userInfo:@{NSLocalizedDescriptionKey:@"参数错误！"}];
        }
        return nil;
    }
    return url;
}

+ (NSDictionary*) decodeWithInfo:(NSURL *)url error:(NSError *__autoreleasing *)error
{
    NSString* string = [url absoluteString];
    NSString* prefix = [NSString stringWithFormat:@"%@://",[QWApplication sharedApplication].urlScheme];
    
    NSRange range = [string rangeOfString:prefix];
    if (range.length == NSNotFound || range.location == NSNotFound) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:kQWErrorDomain code:QWErrorParamsError userInfo:@{NSLocalizedDescriptionKey:@"url scheme error"}];
        }
        return nil;
    }
    NSString *base64String = [string substringFromIndex:range.location + range.length];
    NSData *originData = [[NSData alloc] initWithBase64Encoding:base64String];
    
    NSError* parserError = nil;
    NSDictionary* infos = [NSJSONSerialization JSONObjectWithData:originData options:0 error:&parserError];
    if (parserError) {
        if (error != NULL) {
            *error = parserError;
        }
        return nil;
    }
    return infos;
}
@end
