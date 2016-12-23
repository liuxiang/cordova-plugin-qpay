# 腾讯财付通 移动QQ支付 Cordova-plugin-qpay
- 场景介绍
https://qpay.qq.com/qpaywiki/showdocument.php?pid=38&docid=160

- 支付流程
https://qpay.qq.com/qpaywiki/showdocument.php?pid=38&docid=201

- 接入指引
http://kf.qq.com/faq/150107UZvUZB160405mumyaq.html

- 普通商户如何接入APP支付？`★特别注意,如未填写将无法使用APP支付.且无法变更,只能重新申请`
![](http://file.service.qq.com/user-files/uploads/201611/1445a222fa15c23d2a688ee6041eea51.jpg)
http://kf.qq.com/faq/150107UZvUZB161117vyEBBR.html

---
# 卸载
```
cordova plugin remove com.wosai.qpay
```

# 安装
```
cordova plugin add plugins-ws/com.wosai.qpay --variable qpayappid=YOUR_QPAY_APPID
```

---
# 官方测试账号（快速验证qpay plugin）
注：ios可调试到支付。 android因为没有官方的签名文件导致服务正确匹配sha1，会提示商户中找不到appid。
- 1.安装插件
```
cordova plugin add plugins-ws/com.wosai.qpay --variable qpayappid=100619284
```

- 获取QQ支付订单（orderCode or tokenId）
访问demo地址可获得 http://fun.svip.qq.com/mqqopenpay_demo.php

- 2.程序调用
```
QPay.mqqPay({tokenId:'1V39f4eaf286fe3718731871b4fe96dc'} ,function(res){console.log("res",res)},function(res){console.log("error",res)});
```

- 3.更新ios应用名`config.xml`
```
<widget id="com.tencent.qqwallet.example"
```

- 4.编译，xcode运行
```
ionic build ios
```

---
# 能力
- 是否安装QQ(限：android)
```
QPay.isMqqInstalled(function(res){console.log(res)});
```
- 是否支持移动QQ支付(限：android)
```
QPay.isMqqSupportPay(function(res){console.log(res)})
```
- 获取订单（后端实现，插件留白）
```
QPay.getOrderno(function(res){console.log("res",res)},function(res){console.log("error",res)})
```
- ★移动QQ支付（android | ios）
```
QPay.mqqPay({
  tokenId: '1V39f4eaf286fe3718731871b4fe96dc',// 订单号
  nonce: '',// 随机数
  bargainorId: '1234567890',// 商户号
  appKey: '88888888888888',// appkey
  sig: ''
}, function (res) {
  alert("res:" + res)
}, function (res) {
  alert("error:" + res)
});
```
- 建议先用官方测试账号验证（未填字段会在插件中补充-仅限测试）
```
QPay.mqqPay_demo({tokenId:'1V39f4eaf286fe3718731871b4fe96dc'} ,function(res){console.log("res",res)},function(res){console.log("error",res)});
```

---
#  签名纠正功能(后端签名,也可参考此代码段)
注：签名依赖密钥等敏感信息，建议后台进行。插件提供此功能，仅用于后台签名校验。上线请关闭`debug = false`
## android 见`qpay.java`
注：APP_KEY默认填写了访问示例使用的app_key. 调试自由app支付，请修改。
```
boolean debug = true;// 是否开启debug
if (debug) {
  String sig_online = signApi(api);// 请手动更新APP_KEY
  if (api.sig != sig_online) {
    System.out.println("签名错误-纠正");
    api.sig = sig_online;
  }
}
```
```
/**
* 签名步骤建议不要在app上执行，要放在服务器上执行.
*/
public String signApi(PayApi api) throws Exception {
  // 按key排序
  StringBuilder stringBuilder = new StringBuilder();
  stringBuilder.append("appId=").append(api.appId);
  stringBuilder.append("&bargainorId=").append(api.bargainorId);
  stringBuilder.append("&nonce=").append(api.nonce);
  stringBuilder.append("&pubAcc=").append("");
  stringBuilder.append("&tokenId=").append(api.tokenId);
 
  String APP_KEY = "d139ae6fb0175e5659dce2a7c1fe84d5";// 调试使用,应该服务器保护
  byte[] byteKey = (APP_KEY + "&").getBytes("UTF-8");
  // 根据给定的字节数组构造一个密钥,第二参数指定一个密钥算法的名称
  SecretKey secretKey = new SecretKeySpec(byteKey, "HmacSHA1");
  // 生成一个指定 Mac 算法 的 Mac 对象
  Mac mac = Mac.getInstance("HmacSHA1");
  // 用给定密钥初始化 Mac 对象
  mac.init(secretKey);
  byte[] byteSrc = stringBuilder.toString().getBytes("UTF-8");
  // 完成 Mac 操作
  byte[] dst = mac.doFinal(byteSrc);
 
  // Base64
  // api.sig = Base64.encodeToString(dst, Base64.NO_WRAP);
  // api.sigType = "HMAC-SHA1";
  return Base64.encodeToString(dst, Base64.NO_WRAP);
}
```

## ios 见`qpay.m`
注：APP_KEY默认填写了访问示例使用的app_key. 调试自由app支付，请修改。
```
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
```
```
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
```

---
# 后端 
# 生成订单,
- 参考统一下单接口
https://qpay.qq.com/qpaywiki/showdocument.php?pid=38&docid=58
```
<xml>
  <appid>1111223451</appid> <!-- 应用ID -->
  <body>123</body> <!-- 商品描述  -->
  <device_info>1234567890abc</device_info> <!-- 设备信息 -->
  <limit_pay></limit_pay> <!-- 支付方式限制  -->
  <mch_id>1301278501</mch_id> <!-- 商户ID -->
  <nonce_str>fecf31a13be2309093db5df934848583</nonce_str> <!-- 随机字符串 -->
  <notify_url>https://qpay.qq.com/cgi-bin/pay/qpay_unified_order.cgi</notify_url><!-- 支付结果通知地址 -->
  <out_trade_no>2016061235213702</out_trade_no> <!-- 商户订单号  -->
  <sign>f0c328d362858713b66feafb802615d8</sign><!-- 统一下单签名 -->
  <spbill_create_ip>10.123.9.102</spbill_create_ip> <!-- 终端ip -->
  <total_fee>1</total_fee> <!-- 价格  -->
  <trade_type>NATIVE</trade_type> <!-- 支付场景  -->
</xml>
```

---
# 可能遇到的问题
## ios build error
- 错误
```
Library not found for -lcrt1.3.1.o
```
- 解决
```
deployment target from ios5.0 then change it to ios6.0 or later
```
 
## cordova 方法控制台需要在第二次调用时才会回调方法,可测试一下几个方法
```
Wechat.isInstalled(function(res){console.log("res",res)},function(res){console.log("error",res)})
YCQQ.checkClientInstalled(function(res){console.log("res",res)},function(res){console.log("error",res)})
 
QPay.getOrderno(function(res){console.log("res",res)},function(res){console.log("error",res)})
QPay.mqqPay({tokenId:'1V39f4eaf286fe3718731871b4fe96dc'} ,function(res){console.log("res",res)},function(res){console.log("error",res)});
```
注:经测试,代码调用不会出现首次首次失效的情况
 
## xcode插件失效
```
2016-12-06 17:15:03.982 xcodebuild[9374:245800] [MT] PluginLoading: Required plug-in compatibility UUID 8A66E736-A720-4B3C-92F1-33D9962C69DF for plug-in at path '~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/Unity4XC.xcplugin' not present in DVTPlugInCompatibilityUUIDs
Build settings from command line:
    ARCHS = armv7 armv7s arm64
    CONFIGURATION_BUILD_DIR = /Users/wosai/Desktop/work/hybrid Dev/sxb_physics/platforms/ios/build/device
    SDKROOT = iphoneos10.0
    SHARED_PRECOMPS_DIR = /Users/wosai/Desktop/work/hybrid Dev/sxb_physics/platforms/ios/build/sharedpch
    VALID_ARCHS = armv7 armv7s arm64
```
- 处理办法1
```
curl -s https://raw.githubusercontent.com/ForkPanda/RescueXcodePlug-ins/master/RescueXcode.sh | sh
```
http://stackoverflow.com/questions/35110910/xcode-7-pluginloading-required-plug-in-compatibility-uuid

- 处理办法2
```
xcode-select --install
```
http://stackoverflow.com/questions/20732327/xcode-5-required-plug-in-not-present-in-dvtplugincompatibilityuuids

- 处理办法3
```
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID`
```
http://joeshang.github.io/2015/04/10/fix-xcode-upgrade-plugin-invalid/
 
## SDK 'iOS 10.0'问题
```
Check dependencies
Signing for "赛学霸物理" requires a development team. Select a development team in the project editor.
Code signing is required for product type 'Application' in SDK 'iOS 10.0'
 
** BUILD FAILED **
```
- 解决办法
```
打开xcode,General中勾选:Automatically manage signing
```
http://blog.csdn.net/h643342713/article/details/52728782