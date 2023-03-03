package com.fluttercandies.device_token_helper.helper;

import static com.fluttercandies.device_token_helper.Constant.*;

import android.app.Activity;
import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.heytap.msp.push.HeytapPushManager;
import com.heytap.msp.push.callback.ICallBackResultService;
import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.hms.aaid.HmsInstanceId;

import java.lang.ref.WeakReference;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.Objects;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class DeviceTokenHelper {

    public static String TAG = DeviceTokenHelper.class.getSimpleName();

    private WeakReference<Activity> mActivity;
    private WeakReference<MethodChannel> methodChannel;

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

    public void getDeviceBrand(MethodChannel.Result result) {
        result.success(Build.BRAND);
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
            // 判断是否启用FCM推送
//            if (EMClient.getInstance().isFCMAvailable()) {
//                return;
//            }
            if (Class.forName("com.huawei.hms.api.HuaweiApiClient") == null) {
                result.error("-1", "no huawei hms push sdk or mobile is not a huawei phone", null);
                return;
            }
            Class<?> classType = Class.forName("android.os.SystemProperties");
            Method getMethod = classType.getDeclaredMethod("get", new Class<?>[]{String.class});
            String buildVersion = (String) getMethod.invoke(classType, new Object[]{"ro.build.version.emui"});
            //在某些手机上，invoke方法不报错
            if (TextUtils.isEmpty(buildVersion)) {
                Log.i(TAG, "huawei hms push is unavailable!");
                result.error("-1", "huawei hms push is unavailable!", null);
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
                            result.error("-1", "获取token失败", null);
                            return;
                        }
                        Log.d(TAG, "成功获取到token:" + token);
//                        hmsPushTokenResultSuccessSender(token);
                        result.success(token);
                    } catch (Exception e) {
                        Log.e(TAG, "get token failed, " + e);
                        e.printStackTrace();
                        result.error("-1", e.getMessage(), e.getStackTrace());
                    }
                }
            }.start();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void initOppoPush(Object arguments, MethodChannel.Result result) {
        try {
            Activity activity = mActivity.get();
            if (activity == null) {
                result.error("-1", "暂时无法获取Token，请检查页面调用是否正确", null);
            }
            boolean needLog = true;
            if (arguments != null) {
                needLog = ((boolean) arguments);
            }
            HeytapPushManager.init(activity, needLog);
            boolean supportPush = HeytapPushManager.isSupportPush(activity);
            result.success(supportPush);
        } catch (Exception e) {
            result.error("-1", "初始化失败", null);
        }
    }

    /**
     * 获取Oppo的DeviceToken
     * arguments:{'AppID':'30956839','AppKey':'8924c4a5ca1e4bd8afdd2a7bac39e00c','AppSecret':'9f8ec31f0268431d9fa73a68b2b27cee'}
     * 只会用到 [AppKey] 和 [AppSecret]
     * 所有回调都需要根据responseCode来判断操作是否成功，0 代表成功,其他代码失败，失败具体原因可以查阅附录中的错误码列表。
     * onRegister接口返回的registerID是当前客户端的唯一标识，app开发者可以上传保存到应用服务器中,在发送push消息是可以指定registerID发送。
     *
     * @param arguments 需要传入[AppKey] 和 [AppSecret]
     * @param result    flutter回调
     */
    public void getOppoDeviceToken(Object arguments, MethodChannel.Result result) {
        Gson gson = new Gson();
        String appKey = "";
        String appSecret = "";
        boolean needLog = true;
        if (arguments == null) {
            result.error("-1", "参数错误，Oppo的[AppKey]和[AppSecret]是必传参数", null);
            return;
        }
        try {
            String jsonString = gson.toJson(arguments);
            Map<String, Object> params = gson.fromJson(jsonString, new TypeToken<Map<String, Object>>() {
            }.getType());//反序列化
            appKey = Objects.requireNonNull(params.get("AppKey")).toString();
            appSecret = Objects.requireNonNull(params.get("AppSecret")).toString();
            needLog = ((Boolean) Objects.requireNonNull(params.get("NeedLog")));
        } catch (Exception e) {
            result.error("-1", "参数错误，请检查参数是否正确！", e.getStackTrace());
            return;
        }
        if (TextUtils.isEmpty(appKey) || TextUtils.isEmpty(appSecret)) {
            result.error("-1", "参数错误，未获取到[AppKey]和[AppSecret]", null);
            return;
        }
        Activity activity = mActivity.get();
        if (activity == null) {
            result.error("-1", "暂时无法获取Token，请检查页面调用是否正确", null);
        }
        ICallBackResultService oppoPushTokenCallback = new ICallBackResultService() {
            @Override
            public void onRegister(int code, String s) {
                if (code == 0) {
                    Log.d(TAG, "Oppo注册成功，registerId:" + s);
                    result.success(s);
                } else {
                    result.error(Integer.toString(code), "Oppo注册失败,code=" + code + ",msg=" + s, null);
                }
            }

            @Override
            public void onUnRegister(int code) {
                if (code == 0) {
                    Log.d(TAG, "Oppo注销成功，code=" + code);
                    result.success("Oppo注销成功，code=" + code);
                } else {
                    result.error(Integer.toString(code), "Oppo注销失败，code=" + code, null);
                }
            }

            @Override
            public void onGetPushStatus(final int code, int status) {
                if (code == 0 && status == 0) {
                    result.success("Oppo Push状态错误，code=" + code + ",status=" + status);
                } else {
                    result.error(Integer.toString(code), "Push状态错误，code=" + code + ",status=" + status, null);
                }
            }

            @Override
            public void onGetNotificationStatus(final int code, final int status) {
                if (code == 0 && status == 0) {
                    result.success("Oppo通知状态成功，code=" + code + ",status=" + status);
                } else {
                    result.error(Integer.toString(code), "Oppo 通知状态错误，code=" + code + ",status=" + status, null);
                }
            }

            @Override
            public void onError(int i, String s) {
                result.error(Integer.toString(i), "Oppo onError code : " + i + "   message : " + s, null);
            }

            @Override
            public void onSetPushTime(final int code, final String s) {
                result.error(Integer.toString(code), "Oppo SetPushTime code=" + code + ",result:" + s, null);
            }

        };
        HeytapPushManager.register(activity, appKey, appSecret, oppoPushTokenCallback);
        HeytapPushManager.requestNotificationPermission();
        result.success(null);
    }


    public void getXiaomiDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getMeizuDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getSonyDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getSamsungDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getLgDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getHtcDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getNovaDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getLeMobileDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }

    public void getLenovoDeviceToken(MethodChannel.Result result) {
        result.success(null);
    }


    public void onDispose() {
        this.mActivity.clear();
        this.methodChannel.clear();
    }

    public void setActivity(WeakReference<Activity> mActivity) {
        this.mActivity = mActivity;
    }

    public void setMethodChannel(WeakReference<MethodChannel> methodChannel) {
        this.methodChannel = methodChannel;
    }


    @Nullable
    public MethodChannel getMethodChannel() {
        if (this.methodChannel == null) {
            return null;
        }
        return this.methodChannel.get();
    }
}

