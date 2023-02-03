package com.fluttercandies.device_token_helper.helper;

import static com.fluttercandies.device_token_helper.Constant.*;

import android.app.Activity;
import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.hms.aaid.HmsInstanceId;

import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.util.Objects;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class DeviceTokenHelper {

    public static String TAG = DeviceTokenHelper.class.getSimpleName();

    private WeakReference<Activity> mActivity;

    private static volatile DeviceTokenHelper instance;

    private DeviceTokenHelper() {

    }

    public static DeviceTokenHelper getInstance() {
        if (instance == null) {
            synchronized (DeviceTokenHelper.class) {
                if (instance == null) {
                    instance = new DeviceTokenHelper();
                }
            }
        }
        return instance;
    }

    private MethodChannel.Result hmsPushTokenResult;

    public void hmsPushTokenResultSuccessSender(String token) {
        hmsPushTokenResult.success(token);
    }

    public void hmsPushTokenResultFailureSender(
            @NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        hmsPushTokenResult.error(errorCode, errorMessage, errorDetails);
    }


    /**
     * 根据手机品牌获取推送的device token
     *
     * @param result 回调
     */
    public void getDeviceToken(MethodChannel.Result result) {
        String brand = Build.BRAND;
        android.util.Log.d(TAG, "手机品牌:"+brand);
        if (brand.equals(PHONE_HUAWEI1) || brand.equals(PHONE_HUAWEI2) || brand.equals(PHONE_HUAWEI3)) {
            //华为
            getHmsPushToken(result);
        } else if (brand.equals(PHONE_XIAOMI)) {
            //小米
            result.success(null);
        } else if (brand.equals(PHONE_OPPO1) || brand.equals(PHONE_OPPO2)) {
            //oppo
            result.success(null);
        } else if (brand.equals(PHONE_MEIZU)) {
            result.success(null);
        } else if (brand.equals(PHONE_SONY)) {
            result.success(null);
        } else if (brand.equals(PHONE_SAMSUNG)) {
            result.success(null);
        } else if (brand.equals(PHONE_LG)) {
            result.success(null);
        } else if (brand.equals(PHONE_HTC)) {
            result.success(null);
        } else if (brand.equals(PHONE_NOVA)) {
            result.success(null);
        } else if (brand.equals(PHONE_LeMobile)) {
            result.success(null);
        } else if (brand.equals(PHONE_LENOVO)) {
            result.success(null);
        } else {
            result.success(null);
        }
    }

    /**
     * 申请华为Push Token
     * 1、getToken接口只有在AppGallery Connect平台开通服务后申请token才会返回成功。
     * <p>
     * 2、EMUI10.0及以上版本的华为设备上，getToken接口直接返回token。如果当次调用失败Push会缓存申请，之后会自动重试申请，成功后则以onNewToken接口返回。
     * <p>
     * 3、低于EMUI10.0的华为设备上，getToken接口如果返回为空，确保Push服务开通的情况下，结果后续以onNewToken接口返回。
     * <p>
     * 4、服务端识别token过期后刷新token，以onNewToken接口返回。
     */
    public void getHmsPushToken(MethodChannel.Result result) {
        try {
            hmsPushTokenResult = result;
            // 判断是否启用FCM推送
//            if (EMClient.getInstance().isFCMAvailable()) {
//                return;
//            }
            if (Class.forName("com.huawei.hms.api.HuaweiApiClient") == null) {
                hmsPushTokenResultFailureSender("-1", "no huawei hms push sdk or mobile is not a huawei phone", null);
                return;
            }
            Class<?> classType = Class.forName("android.os.SystemProperties");
            Method getMethod = classType.getDeclaredMethod("get", new Class<?>[]{String.class});
            String buildVersion = (String) getMethod.invoke(classType, new Object[]{"ro.build.version.emui"});
            //在某些手机上，invoke方法不报错
            if (TextUtils.isEmpty(buildVersion)) {
                hmsPushTokenResultFailureSender("-1", "huawei hms push is unavailable!", null);
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
                        Log.i(TAG, "appId: " + appId);
                        String token = HmsInstanceId.getInstance(_activity).getToken(appId, tokenScope);
                        //service register huawei hms push token success token:0861063044859805300017555200CN01
                        //result.success(token);
                        if (Objects.isNull(token) || TextUtils.isEmpty(token)) {
                            Log.d(TAG, "获取token失败:" + token);
                            //hmsPushTokenResultFailureSender("-1","register huawei hms push token fail!",null);
                            /*
                            I/HMSSDK_PushReceiver(30392): receive a push token: com.jalaga.toersen
                            I/HMSSDK_RemoteService(30392): remote service bind service start
                            I/HMSSDK_HmsMessageService(30392): start to bind
                            I/HMSSDK_RemoteService(30392): remote service onConnected
                            I/HMSSDK_RemoteService(30392): remote service unbindservice
                            I/HMSSDK_HmsMessageService(30392): handle message start...
                            I/HMSSDK_HmsMessageService(30392): onNewToken
                             */
                            return;
                        }
                        Log.d(TAG, "成功获取到token:" + token);
                        hmsPushTokenResultSuccessSender(token);
                    } catch (Exception e) {
                        Log.e(TAG, "get token failed, " + e);
                        e.printStackTrace();
                    }
                }
            }.start();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void onDispose() {
        this.mActivity.clear();
        this.hmsPushTokenResult = null;
    }

    public void setActivity(WeakReference<Activity> mActivity) {
        this.mActivity = mActivity;
    }
}

