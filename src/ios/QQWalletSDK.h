//
//  QQWalletSDK.h
//  QQWalletSDK
//
//  Created by stonedong on 14-3-31.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QQWalletDefines.h"
#import "QWMessage.h"

/**
 *  钱包SDK
 */
@interface QQWalletSDK : NSObject

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
               completion:(QQTaskCompletion)completion;

/**
 *  注册第三方APP信息
 *
 *  @param appId     APP的唯一标识
 *  @param urlScheme APP的URL SCHEME，用户在手机QQ内部完成功能后进行回调
 *  @param name      APP的名字
 */
+ (void) registerQQWalletApplication:(NSString*)appId
                           urlScheme:(NSString*)urlScheme
                                name:(NSString*)name;

/**
 *  在手机QQ完成功能后，进行对本APP进行回调，传递功能执行结果
 *
 *  @param application       当前APP
 *  @param url               出发回调的URL
 *  @param sourceApplication 发起回调的APP
 *  @param annotation        nil
 *
 *  @return 是否能够响应改回调
 */
+ (BOOL) QQWalletSDKHanldeApplication:(UIApplication*)application
                              openURL:(NSURL *)url
                    sourceApplication:(NSString *)sourceApplication
                           annotation:(id)annotation;

@end
