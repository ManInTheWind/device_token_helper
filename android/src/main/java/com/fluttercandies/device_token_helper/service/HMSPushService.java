package com.fluttercandies.device_token_helper.service;

import android.text.TextUtils;
import android.util.Log;

import com.fluttercandies.device_token_helper.helper.DeviceTokenHelper;
import com.huawei.hms.push.HmsMessageService;
import com.hyphenate.chat.EMClient;
import com.hyphenate.util.EMLog;

import java.util.Objects;

public class HMSPushService extends HmsMessageService {
    @Override
    public void onNewToken(String token) {
        DeviceTokenHelper tokenHelper = DeviceTokenHelper.getInstance();
        if(Objects.isNull(token) || TextUtils.isEmpty(token)){
            EMLog.d("HMSPushService", "成功获取到token:" + token);
            //没有失败回调，假定token失败时token为null
            tokenHelper.hmsPushTokenResultFailureSender("-1","register huawei hms push token fail!",null);
            return;
        }
        tokenHelper.hmsPushTokenResultSuccessSender(token);
    }
}
