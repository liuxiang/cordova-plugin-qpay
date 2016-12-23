
#import "CDVWechat.h"
#import <Cordova/CDVPluginResult.h>

#import <CommonCrypto/CommonHMAC.h>
#import "QQWalletSDK.h"
#import "QPay.h"

@implementation QPay

/**
 *  插件初始化，主要用户appkey注册
 */
- (void)pluginInitialize {
    NSString *appId = [[self.commandDelegate settings] objectForKey:@"qpayappid"];
    // appId = @"100619284";                             // 第三方APP在QQ钱包开放平台申请的appID

    self.qpayAppId = appId;
    NSString *schemaPrefix = [@"qwallet" stringByAppendingString:appId];
    // schemaPrefix=@"qpaywosai";

    // 1. 注册第三方APP信息 appId
    // APP的唯一标识 urlScheme
    // APP的URL SCHEME，用户在手机QQ内部完成功能后进行回调
    // name      APP的名字
    [QQWalletSDK registerQQWalletApplication:appId // app id
                                   urlScheme:schemaPrefix // 在您的工程中的plist文件中创建用于回调的URL SCHEMA。此URL SCHEMA用于手机QQ完成功能后，传递结果信息用。请尽量保证此URL SCHEMA不会与其他冲突。
                                        name:@"赛学霸物理"];
}

- (void)handleOpenURL:(NSNotification *)notification
{
    NSURL* url = [notification object];
    UIApplication* application = [UIApplication sharedApplication];
    NSString* sourceApplication = @"";
    [QQWalletSDK QQWalletSDKHanldeApplication:application openURL:url  sourceApplication:sourceApplication annotation:nil];
}


// 获得订单(测试－http://fun.svip.qq.com/mqqopenpay_demo.php)
- (void)getOrderno:(CDVInvokedUrlCommand *)command{

    NSString *orderId = [self getTokenIDForThisDemo];

    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:orderId];
    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];

//    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"orderId"];
//    [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
}


// 获取一个demo订单号
- (NSString *)getTokenIDForThisDemo{
    NSURL* url = [NSURL URLWithString:@"http://fun.svip.qq.com/mqqopenpay_demo.php"];  // demo
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (!error) {
        NSDictionary* infos = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (!error) {
            NSString* tokenId = infos[@"token"]; // 取得订单号
            return tokenId;
        }
    }
    return nil;
}

- (void)mqqPay_demo:(CDVInvokedUrlCommand *)command{

    // demo版需要修改包名为：com.tencent.qqwallet.example
    NSDictionary *params = [command.arguments objectAtIndex:0];
    NSString *tokenId = [params objectForKey:@"tokenId"];// http://fun.svip.qq.com/mqqopenpay_demo.php
    NSString *nonce = [self getNonce];

    NSString *appId = @"100619284";                             // 第三方APP在QQ钱包开放平台申请的appID
    NSString *appKey = @"d139ae6fb0175e5659dce2a7c1fe84d5";     // appID对应的appKey (这个key应当保存在后台，在
    NSString *bargainorId = @"2001";                            // 第三方APP在财付通后台的商户号

    // 获取签名串
    NSString *sig = [self getMySignatureWithAppId:appId
                                      bargainorId:bargainorId
                                            nonce:nonce
                                          tokenId:tokenId
                                       signingKey:appKey];

    // 调用QQ钱包进行支付
    [QQWalletSDK startPayWithAppId:appId
                       bargainorId:bargainorId
                           tokenId:tokenId
                         signature:sig
                             nonce:nonce
                        completion:^(QWMessage *message, NSError *error){
                            // 支付完成的回调处理
                            //                            if (error) {
                            //                                NSLog(@"error %@",error);
                            //                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            //                                [alert show];
                            //                            }else{
                            //                                NSLog(@"message infos %@", message.infos);
                            //                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付成功" message:[message.infos description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            //                                [alert show];
                            //                            }

                            if (error) {
                                NSLog(@"error %@",error);

//                                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"code": [NSNumber numberWithInteger:error.code], @"message": error.localizedDescription}];
//
//                                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];


                                CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:error.localizedDescription];
                                [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];

                            }else{
                                NSLog(@"message infos %@", message.infos);

                                CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"支付成功"];
                                [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
                            }

                        }];


}

- (void)mqqPay:(CDVInvokedUrlCommand *)command{

    NSDictionary *params = [command.arguments objectAtIndex:0];
    NSString *tokenId = [params objectForKey:@"tokenId"];
    NSString *nonce = [params objectForKey:@"nonce"];
    nonce = nonce==nil? [self getNonce]: nonce;// 补偿随机数

    NSString *bargainorId = [params objectForKey:@"bargainorId"];// @"2001" 第三方APP在财付通后台的商户号
    bargainorId = bargainorId==nil? @"2001": bargainorId;// 补偿商户号

    NSString *appId = self.qpayAppId;

    NSString *sig = [params objectForKey:@"sig"];// 传入签名

    BOOL debug = true;// 调试
    if(debug){
        // 获取签名串
        NSString *appKey = @"d139ae6fb0175e5659dce2a7c1fe84d5";// 测试使用，正式环境请删除
        NSString *sig_online = [self getMySignatureWithAppId:appId
                                                 bargainorId:bargainorId
                                                       nonce:nonce
                                                     tokenId:tokenId
                                                  signingKey:appKey];

        if(sig != sig_online){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"签名错误－纠正" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            sig = sig_online;
        }
    }

    // 调用QQ钱包进行支付
    [QQWalletSDK startPayWithAppId:appId
                       bargainorId:bargainorId
                           tokenId:tokenId
                         signature:sig
                             nonce:nonce
                        completion:^(QWMessage *message, NSError *error){
                            // 支付完成的回调处理
                            if (error) {
                                NSLog(@"error %@",error);
                                CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:error.localizedDescription];
                                [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];

                            }else{
                                NSLog(@"message infos %@", message.infos);

                                CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"支付成功"];
                                [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
                            }
                        }];
}

// 生成签名串
- (NSString *)getMySignatureWithAppId:(NSString *)appId
                          bargainorId:(NSString *)bargainorId
                                nonce:(NSString *)nonce
                              tokenId:(NSString *)tokenId
                           signingKey:(NSString *)signingKey{

    // 1. 将 appId,bargainorId,nonce,tokenId 拼成字符串
    NSString *source = [NSString stringWithFormat:@"appId=%@&bargainorId=%@&nonce=%@&pubAcc=&tokenId=%@",
                        appId,bargainorId,nonce,tokenId];

    // 2. 将刚才拼好的字符串，用key来加密
    NSData *signature = [source dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signingData = [[signingKey stringByAppendingString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];  // 约定在key末尾拼一个‘&’符号
    NSData *digest = [self hmacSha1:signature key:signingData];

    // 3. 将加密后的data以base64形式输出
    NSString *signatureBase64 = [digest base64Encoding];
    return signatureBase64;
}

// 获取一个随机串
- (NSString *)getNonce{
    NSDate *now = [NSDate date];
    NSNumber *s = @([now timeIntervalSince1970]);
    NSString *nonce = s.stringValue;
    return nonce;
}

//
// 以下“签名”的步骤为了安全起见，应当放在后台处理
// 客户端从后台来获取签名后的字符串
//

// 将data用hmac-sha1算法加密
- (NSData *)hmacSha1:(NSData *)data key:(NSData *)key {
    NSMutableData *hmac = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac( kCCHmacAlgSHA1,
           key.bytes,  key.length,
           data.bytes, data.length,
           hmac.mutableBytes);
    return hmac;
}


@end
