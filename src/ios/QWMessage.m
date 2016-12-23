//
//  QWMessage.m
//  QQWalletSDK
//
//  Created by stonedong on 14-3-31.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "QWMessage.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#define INIT_EXTERN_STRING(key, value) NSString* const k##key=@#value
INIT_EXTERN_STRING(QWMessageCode, code);
INIT_EXTERN_STRING(QWMessageText, message);
INIT_EXTERN_STRING(QWMessageInfos, infos);

@implementation QWMessage

- (NSDictionary*) dictionaryWithAllValues
{
    return [self dictionaryWithValuesForKeys:@[kQWMessageText, kQWMessageInfos, kQWMessageCode]];
}
@end
