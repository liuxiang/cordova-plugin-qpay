package __PACKAGE_NAME__;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.tencent.mobileqq.openpay.api.IOpenApiListener;
import com.tencent.mobileqq.openpay.data.base.BaseResponse;
import com.tencent.mobileqq.openpay.data.pay.PayResponse;
import com.wosai.qpay.QPay;

public class CallbackActivity extends Activity implements IOpenApiListener {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// String appId = "100619284";
		// openApi = OpenApiFactory.getInstance(this, appId);
		// openApi.handleIntent(getIntent(), this);

		QPay.instance.getIOpenApi().handleIntent(getIntent(), this);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
		QPay.instance.getIOpenApi().handleIntent(intent, this);
	}

	@Override
	public void onOpenResponse(BaseResponse response) {
		String title = "Callback from mqq";
		String message;

		if (response == null) {
			message = "response is null.";
			QPay.instance.getCurrentCallbackContext().success(0);// 回调
			finish();
			return;
		} else {
			JSONObject res = new JSONObject();

			if (response instanceof PayResponse) {
				PayResponse payResponse = (PayResponse) response;

				message = " apiName:" + payResponse.apiName + " serialnumber:"
						+ payResponse.serialNumber + " isSucess:"
						+ payResponse.isSuccess() + " retCode:"
						+ payResponse.retCode + " retMsg:" + payResponse.retMsg;

				try {
					res.put("apiName", payResponse.apiName);
					res.put("serialNumber", payResponse.serialNumber);
					res.put("isSuccess", payResponse.isSuccess());
					res.put("retCode", payResponse.retCode);
					res.put("retMsg", payResponse.retMsg);
				} catch (JSONException e) {
					System.out.println(e);
				}

				if (payResponse.isSuccess()) {
					if (!payResponse.isPayByWeChat()) {
						message += " transactionId:"
								+ payResponse.transactionId + " payTime:"
								+ payResponse.payTime + " callbackUrl:"
								+ payResponse.callbackUrl + " totalFee:"
								+ payResponse.totalFee + " spData:"
								+ payResponse.spData;
					}

					try {
						res.put("transactionId", payResponse.transactionId);
						res.put("payTime", payResponse.payTime);
						res.put("callbackUrl", payResponse.callbackUrl);
						res.put("totalFee", payResponse.totalFee);
						res.put("spData", payResponse.spData);
					} catch (JSONException e) {
						System.out.println(e);
					}

				}
			} else {
				message = "response is not PayResponse.";
			}
			QPay.instance.getCurrentCallbackContext().success(res);// 回调
			finish();
		}
	}

}
