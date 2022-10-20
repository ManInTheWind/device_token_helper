package com.fluttercandies.device_token_helper.helper;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.huawei.agconnect.AGConnectOptions;
import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.common.ApiException;
import com.hyphenate.chat.EMClient;
import com.hyphenate.util.EMLog;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

public class DeviceTokenHelper {
    public static String TAG = DeviceTokenHelper.class.getSimpleName();
    private WeakReference<Activity> mActivity;

    private static volatile DeviceTokenHelper instance;

    private DeviceTokenHelper(){

    }

    public static DeviceTokenHelper getInstance(){
        if (instance == null){
            synchronized (DeviceTokenHelper.class){
                if (instance  == null){
                    instance = new DeviceTokenHelper();
                }
            }
        }
        return instance;
    }

    private MethodChannel.Result hmsPushTokenResult;

    public void hmsPushTokenResultSuccessSender(String token){
        hmsPushTokenResult.success(token);
    }

    public void hmsPushTokenResultFailureSender(
            @NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails){
        hmsPushTokenResult.error(errorCode,errorMessage,errorDetails);
    }

    public void getHmsPushToken(MethodChannel.Result result) {
        hmsPushTokenResult = result;
        try {
            // 判断是否启用FCM推送
            if (EMClient.getInstance().isFCMAvailable()) {
                return;
            }
            if (Class.forName("com.huawei.hms.api.HuaweiApiClient") == null) {
                hmsPushTokenResultFailureSender("-1","no huawei hms push sdk or mobile is not a huawei phone",null);
                return;
            }
            Class<?> classType = Class.forName("android.os.SystemProperties");
            Method getMethod = classType.getDeclaredMethod("get", new Class<?>[]{String.class});
            String buildVersion = (String) getMethod.invoke(classType, new Object[]{"ro.build.version.emui"});
            //在某些手机上，invoke方法不报错
            if (TextUtils.isEmpty(buildVersion)) {
                hmsPushTokenResultFailureSender("-1","huawei hms push is unavailable!",null);
                return;
            }
            new Thread() {
                @Override
                public void run() {
                    try {
                        Activity _activity = mActivity.get();
                        // 从agconnect-services.json文件中读取APP_ID
                        String appId = new AGConnectOptionsBuilder().build(_activity).getString("client/app_id");
                        // 输入token标识"HCM"
                        String tokenScope = "HCM";
                        EMLog.i(TAG, "appId: " + appId);
                        String token = HmsInstanceId.getInstance(_activity).getToken(appId, tokenScope);
                        //service register huawei hms push token success token:0861063044859805300017555200CN01
                        //result.success(token);
                        if(Objects.isNull(token) || TextUtils.isEmpty(token)){
                            hmsPushTokenResultFailureSender("-1","register huawei hms push token fail!",null);
                            return;
                        }
                        EMLog.d(TAG, "成功获取到token:" + token);
                        hmsPushTokenResultSuccessSender(token);
                    } catch (Exception e) {
                        EMLog.e(TAG, "get token failed, " + e);
                        e.printStackTrace();
                    }
                }
            }.start();

        } catch (Exception e) {

        }


    }

    public void onDispose(){
        this.mActivity.clear();
        this.hmsPushTokenResult = null;
    }

    public void setActivity(WeakReference<Activity> mActivity) {
        this.mActivity = mActivity;
    }
}

