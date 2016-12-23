//
//  QWApplication.h
//  QQWalletSDK
//
//  Created by stonedong on 14-4-2.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QWApplication : NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* urlScheme;
@property (nonatomic, strong) NSString* sdkVersion;
@property (nonatomic, strong) NSString* appId;
@property (nonatomic, strong ,readonly) NSString* urlSchemePrefix;

+ (QWApplication*) sharedApplication;
- (NSDictionary*) dictionaryWithAllValues;

@end
