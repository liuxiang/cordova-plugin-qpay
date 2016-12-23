//
//  QQWalletDefines.h
//  QQWalletSDK
//
//  Created by stonedong on 14-3-31.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  代表QQWallet出错的域名
 */
extern NSString* const kQWErrorDomain;

/**
 *  QQWallet出错信息
 */
typedef enum {
    /**
     *  未知错误，不支持
     */
    QWErrorNotSupport = 7000,
    /**
     *  参数传递错误
     */
    QWErrorParamsError = 8000
}QWErrorCode;

/**
 *  手机QQ唤起钱包功能使用的URL Schema
 */
extern NSString* const kQWURLScheme;


/**
 *  支付时传参，用来表示单号
 */
extern NSString* const kQWPayParamTokenID;

/**
 *  支付时传参，表示签名串
 */
extern NSString* const kQWPayParamSignature;

/**
 *  支付时传参，表示随机串
 */
extern NSString* const kQWPayParamNonce;

/**
 *  支付时传参，表示商户号
 */
extern NSString* const kQWPayParamBargainorId;

/**
 *  支付时传参，表示本app的版本号
 */
extern NSString* const kQWPayParamAppVersion;



@class QWMessage;
/**
 *  进行QQWallet操作之后的回调函数，开发者可以在这里进行，QQWallet动作完成后接受完成结果，并进行处理
 *
 *  @param message 包含返回结果信息的对象
 *  @param error   出错信息，如果出错则改信息不为空，否则为空。
 */
typedef void(^QQTaskCompletion)(QWMessage* message, NSError* error);


