//
//  QQWalletSDK.m
//  QQWalletSDK
//
//  Created by stonedong on 14-3-31.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import "QQWalletSDK.h"
#import "QWApplication.h"
#import "QWURLEncodeEngine.h"
#import "QWServerPayTask.h"
#import "QWMessage.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

@interface QQWalletSDK()
@property (nonatomic, strong) QWTask* currentTask;
+ (QQWalletSDK *)sharedInstance;
- (void) startTask:(QWTask*)task;
- (void) handleResponseWithInfo:(NSDictionary*)infos;
@end



@implementation QQWalletSDK

#pragma mark - Private

// 初始化单例
+ (QQWalletSDK *)sharedInstance
{
    static QQWalletSDK *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [QQWalletSDK new];
    });
    return shared;
}

// 开始支付任务
- (void)startTask:(QWTask *)task
{
    self.currentTask = task;
    NSError* error = nil;
    if (![self.currentTask start:&error]) {
        if (task.completionBlock) {
            task.completionBlock(nil, error);
        }
    }
}

- (void) handleResponseWithInfo:(NSDictionary *)infos
{
    NSDictionary* actions = infos[kQWURLKeyAction];
    NSDictionary* params =  infos[kQWURLKeyParams];
    
    QWMessage* message = [QWMessage new];
    [message setValuesForKeysWithDictionary:params];
    
    NSString* identifier = actions[kQWTaskKeyIdentifier];
    if (![identifier isEqual:self.currentTask.identifier]) {
        return;
    }
    NSError* error = nil;
    if (message.code != 0) {
        error = [NSError errorWithDomain:kQWErrorDomain code:message.code userInfo:@{NSLocalizedDescriptionKey: message.message ? message.message: @"unknow!"}];
    }
    if (self.currentTask.completionBlock) {
        self.currentTask.completionBlock(message, error);
    }
}

#pragma mark - Public

+ (void) startPayWithServerParams:(NSDictionary*)params completion:(QQTaskCompletion)completion
{
    QWServerPayTask* task = [[QWServerPayTask alloc] initWithParams:params];
    task.completionBlock = completion;
    [[QQWalletSDK sharedInstance] startTask:task];
}

/**
 *  调起QQ钱包进行支付，参数为从第三方APP从服务器获取的参数，透传到手机QQ内，唤起支付功能
 *
 *  @param appId           第三方APP在QQ钱包开放平台申请的appID
 *  @param bargainorId     第三方APP在财付通后台的商户号
 *  @param tokenId         在财付通后台下单的订单号
 *  @param signature       参数按照规则签名后的字符串
 *  @param nonce           签名过程中使用的随机串
 *  @param completion      回调的Block
 */
+ (void)startPayWithAppId:(NSString *)appId
              bargainorId:(NSString *)bargainorId
                  tokenId:(NSString *)tokenId
                signature:(NSString *)sig
                    nonce:(NSString *)nonce
               completion:(QQTaskCompletion)completion{
    
    NSString *appVersion = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleVersion"];
    NSDictionary* params = @{kQWPayParamTokenID:tokenId,
                             kQWPayParamSignature:sig,
                             kQWPayParamBargainorId:bargainorId,
                             kQWPayParamNonce:nonce,
                             kQWPayParamAppVersion:appVersion};
    
    QWServerPayTask* task = [[QWServerPayTask alloc] initWithParams:params];
    task.completionBlock = completion;
    [[QQWalletSDK sharedInstance] startTask:task];
}

+ (BOOL) QQWalletSDKHanldeApplication:(UIApplication*)application
                              openURL:(NSURL *)url
                       sourceApplication:(NSString *)sourceApplication
                              annotation:(id)annotation
{

    if (![[url absoluteString] hasPrefix:[QWApplication sharedApplication].urlSchemePrefix]) {
        return NO;
    }
    NSError* error = nil;
    NSDictionary* infos = [QWURLEncodeEngine decodeWithInfo:url error:&error];
    [[QQWalletSDK sharedInstance] handleResponseWithInfo:infos];
    return YES;
}

+ (void) registerQQWalletApplication:(NSString *)appId urlScheme:(NSString *)urlScheme name:(NSString *)name
{
    QWApplication* application = [QWApplication sharedApplication];
    application.name = name;
    application.appId = appId;
    application.urlScheme = urlScheme;
}

@end
