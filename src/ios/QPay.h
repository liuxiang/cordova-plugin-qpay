#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface QPay : CDVPlugin

@property (nonatomic, strong) NSString *qpayAppId;

// - (void)isMqqInstalled:(CDVInvokedUrlCommand *)command;
// - (void)isMqqSupportPay:(CDVInvokedUrlCommand *)command;
- (void)getOrderno:(CDVInvokedUrlCommand *)command;
- (void)mqqPay:(CDVInvokedUrlCommand *)command;
- (void)mqqPay_demo:(CDVInvokedUrlCommand *)command;

@end
