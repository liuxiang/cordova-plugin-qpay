package com.wosai.qpay;

import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Base64;
import android.util.Log;

import com.tencent.mobileqq.openpay.api.IOpenApi;
import com.tencent.mobileqq.openpay.api.OpenApiFactory;
import com.tencent.mobileqq.openpay.constants.OpenConstants;
import com.tencent.mobileqq.openpay.data.pay.PayApi;
//import org.apache.http.HttpResponse;
//import org.apache.http.client.ClientProtocolException;
//import org.apache.http.client.HttpClient;
//import org.apache.http.client.methods.HttpGet;
//import org.apache.http.impl.client.DefaultHttpClient;
//import org.apache.http.util.EntityUtils;

public class QPay extends CordovaPlugin {

	public static final String TAG = "Cordova.Plugin.QPay";

	public static final String QPAY_APPID_PROPERTY_KEY = "qpayappid";
	public static final String ERROR_INVALID_PARAMETERS = "参数格式错误";

	protected IOpenApi openApi;
	protected String appId;
	String callbackScheme = "qwallet0000000000";

	int paySerial = 1;

	public static QPay instance = null;
	protected CallbackContext currentCallbackContext;

	@Override
	protected void pluginInitialize() {

		super.pluginInitialize();

		instance = this;
		initQPay();

	}

	public CallbackContext getCurrentCallbackContext() {
		return currentCallbackContext;
	}

	protected void initQPay() {
		if (openApi == null) {
			String appId = getAppId();
			openApi = OpenApiFactory.getInstance(this.cordova.getActivity(),
					appId);
		}
	}

	public IOpenApi getIOpenApi() {
		return openApi;
	}

	protected String getAppId() {
		if (this.appId == null) {
			this.appId = preferences.getString(QPAY_APPID_PROPERTY_KEY, "");
		}
		callbackScheme = "qwallet" + this.appId;
		return this.appId;
	}

	@Override
	public boolean execute(String action, CordovaArgs args,
			CallbackContext callbackContext) {
		Log.d(TAG, String.format("%s is called. Callback ID: %s.", action,
				callbackContext.getCallbackId()));

		if (action.equals("isMqqInstalled")) {
			return isMqqInstalled(callbackContext);
		} else if (action.equals("isMqqSupportPay")) {
			return isMqqSupportPay(callbackContext);
		} else if (action.equals("getOrderno")) {
			return getOrderno(callbackContext);
		} else if (action.equals("mqqPay")) {
			try {
				return mqqPay(args, callbackContext);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		return false;
	}

	public boolean isMqqInstalled(CallbackContext callbackContext) {
		boolean isInstalled = openApi.isMobileQQInstalled();

		if (!isInstalled) {
			callbackContext.success(0);
		} else {
			callbackContext.success(1);
		}

		return true;
	}

	public boolean isMqqSupportPay(CallbackContext callbackContext) {
		boolean isSupport = openApi
				.isMobileQQSupportApi(OpenConstants.API_NAME_PAY);

		if (!isSupport) {
			callbackContext.success(0);
		} else {
			callbackContext.success(1);
		}

		return true;
	}

	public boolean getOrderno(CallbackContext callbackContext) {
		return true;
	}

	public boolean mqqPay(CordovaArgs args, CallbackContext callbackContext)
			throws Exception {

		// check if # of arguments is correct
		final JSONObject params;
		try {
			params = args.getJSONObject(0);
		} catch (JSONException e) {
			callbackContext.error(ERROR_INVALID_PARAMETERS);
			return true;
		}

		PayApi api = new PayApi();
		api.appId = getAppId();// [√:参与签名]

		api.serialNumber = "" + paySerial++;
		api.callbackScheme = callbackScheme;

		api.tokenId = params.getString("tokenId");// QQ钱包的预支付会话标识
		api.pubAcc = "";// 手Q公众帐号，暂时未对外开放申请。[√:参与签名]
		api.pubAccHint = "";// 关注手Q公众帐号提示语[√:参与签名]

		try {
			api.nonce = params.getString("nonce");// 随机串 [√:参与签名]
		} catch (Exception e) {
			api.nonce = String.valueOf(System.currentTimeMillis());// 补充随机数
		}

		try {
			api.bargainorId = params.getString("bargainorId");// QQ钱包支付商户号[√:参与签名]
		} catch (Exception e) {
			api.bargainorId = "2001";// 补偿商户号
		}

		api.timeStamp = System.currentTimeMillis() / 1000;// 时间戳

		// 签名
		api.sigType = "HMAC-SHA1";
		try {
			api.sig = params.getString("sig");// 签名
		} catch (Exception e) {
			e.printStackTrace();
		}

		boolean debug = true;// 是否开启debug
		if (debug) {
			String sig_online = signApi(api);// 请手动更新APP_KEY
			if (api.sig != sig_online) {
				System.out.println("签名错误-纠正");
				api.sig = sig_online;
			}
		}

		if (api.checkParams()) {
			openApi.execApi(api);// 调用QPay
		}

		// save current callback context
		currentCallbackContext = callbackContext;

		// send no result and keep callback
		PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
		result.setKeepCallback(true);
		callbackContext.sendPluginResult(result);

		return true;
	}

	public boolean mqqPay_demo(CordovaArgs args, CallbackContext callbackContext)
			throws Exception {

		// check if # of arguments is correct
		final JSONObject params;
		try {
			params = args.getJSONObject(0);
		} catch (JSONException e) {
			callbackContext.error(ERROR_INVALID_PARAMETERS);
			return true;
		}

		PayApi api = new PayApi();
		api.appId = "100619284";// [√:参与签名]

		api.serialNumber = "" + paySerial++;
		api.callbackScheme = "qwallet100619284";

		api.tokenId = params.getString("tokenId");// QQ钱包的预支付会话标识
		api.pubAcc = "";// 手Q公众帐号，暂时未对外开放申请。[√:参与签名]
		api.pubAccHint = "";// 关注手Q公众帐号提示语[√:参与签名]

		try {
			api.nonce = params.getString("nonce");// 随机串 [√:参与签名]
		} catch (Exception e) {
			api.nonce = String.valueOf(System.currentTimeMillis());// 补充随机数
		}

		try {
			api.bargainorId = params.getString("bargainorId");// QQ钱包支付商户号[√:参与签名]
		} catch (Exception e) {
			api.bargainorId = "2001";// 补偿商户号
		}

		api.timeStamp = System.currentTimeMillis() / 1000;// 时间戳

		// 签名
		api.sigType = "HMAC-SHA1";
		api.sig = params.getString("sig");// 签名

		if (api.checkParams()) {
			openApi.execApi(api);
		}

		// save current callback context
		currentCallbackContext = callbackContext;

		// send no result and keep callback
		PluginResult result = new PluginResult(PluginResult.Status.NO_RESULT);
		result.setKeepCallback(true);
		callbackContext.sendPluginResult(result);

		return true;
	}

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

}
