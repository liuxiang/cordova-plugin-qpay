//
//  QWServerPayTask.m
//  QQWalletSDK
//
//  Created by stonedong on 14-4-3.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "QWServerPayTask.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@implementation QWServerPayTask

+ (NSString*) actionName
{
    return @"pay";
}

- (BOOL) start:(NSError *__autoreleasing *)error
{
    NSDictionary* infos = _params;
    return [self startWithParams:infos error:error];
}

- (instancetype) initWithParams:(NSDictionary *)params
{
    self = [super init];
    if (!self) {
        return self;
    }
    _params = params;
    return self;
}

@end
