var cordova = require('cordova');

var QPay = function () {
};

QPay.prototype = {
  // 是否安装手Q
  isMqqInstalled: function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "QPay", "isMqqInstalled", []);
  },
  // 是否支持手Q支付
  isMqqSupportPay: function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "QPay", "isMqqSupportPay", []);
  },
  // 获得订单
  getOrderno: function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "QPay", "getOrderno", []);
  },
  // 启动手Q支付
  mqqPay: function (paymentInfo, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "QPay", "mqqPay", [paymentInfo]);
  },
  // 启动手Q支付_demo(demo版需要修改包名为：com.tencent.qqwallet.example)
  mqqPay_demo: function (paymentInfo, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "QPay", "mqqPay_demo", [paymentInfo]);
  }
}

var QPay = new QPay();
module.exports = QPay;
