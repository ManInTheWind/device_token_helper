package com.fluttercandies.device_token_helper.service;

import android.text.TextUtils;

import com.fluttercandies.device_token_helper.helper.DeviceTokenHelper;
import com.huawei.hms.push.HmsMessageService;

import java.util.Objects;

import io.flutter.Log;

public class HMSPushService extends HmsMessageService {
    @Override
    public void onNewToken(String token) {
       try {
           Log.d("HMSPushService", "获取到新的Token:" + token);
           DeviceTokenHelper tokenHelper = DeviceTokenHelper.getInstance();
           if(Objects.isNull(token) || TextUtils.isEmpty(token)){
               //没有失败回调，假定token失败时token为null
               tokenHelper.hmsPushTokenResultFailureSender("-1","register huawei hms push token fail!",null);
               return;
           }
           Log.d("HMSPushService", "成功获取到token:" + token);
           tokenHelper.hmsPushTokenResultSuccessSender(token);
       }catch (Exception e){
           e.printStackTrace();
       }
    }
}
