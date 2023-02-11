package com.fluttercandies.device_token_helper;

import android.app.Activity;
import android.os.Build;

import androidx.annotation.NonNull;

import com.fluttercandies.device_token_helper.helper.DeviceTokenHelper;

import java.lang.ref.WeakReference;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * DeviceTokenHelperPlugin
 */
public class DeviceTokenHelperPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private DeviceTokenHelper deviceTokenHelper;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "android_device_token_helper");
        channel.setMethodCallHandler(this);
        deviceTokenHelper = DeviceTokenHelper.getInstance();
        deviceTokenHelper.setMethodChannel(new WeakReference<>(channel));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + Build.VERSION.RELEASE);
                break;
            case "DeviceBrand":
                deviceTokenHelper.getDeviceBrand(result);
                break;
            case "HuaweiDeviceToken":
                deviceTokenHelper.getHmsPushToken(result);
                break;
            case "initOppoPush":
                deviceTokenHelper.initOppoPush(call.arguments, result);
                break;
            case "OppoDeviceToken":
                /**
                 * arguments:{'AppID':'30956839','AppKey':'8924c4a5ca1e4bd8afdd2a7bac39e00c','AppSecret':'9f8ec31f0268431d9fa73a68b2b27cee'}
                 * 只会用到 [AppKey] 和 [AppSecret]
                 */
                deviceTokenHelper.getOppoDeviceToken(call.arguments, result);
                break;
            case "XiaomiDeviceToken":
                deviceTokenHelper.getXiaomiDeviceToken(result);
                break;
            case "MeizuDeviceToken":
                deviceTokenHelper.getMeizuDeviceToken(result);
                break;
            case "SonyDeviceToken":
                deviceTokenHelper.getSonyDeviceToken(result);
                break;
            case "SamsungDeviceToken":
                deviceTokenHelper.getSamsungDeviceToken(result);
                break;
            case "LgDeviceToken":
                deviceTokenHelper.getLgDeviceToken(result);
                break;
            case "HtcDeviceToken":
                deviceTokenHelper.getHtcDeviceToken(result);
                break;
            case "NovaDeviceToken":
                deviceTokenHelper.getNovaDeviceToken(result);
                break;
            case "LeMobileDeviceToken":
                deviceTokenHelper.getLeMobileDeviceToken(result);
                break;
            case "LenovoDeviceToken":
                deviceTokenHelper.getLenovoDeviceToken(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        deviceTokenHelper.onDispose();
        deviceTokenHelper = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        WeakReference<Activity> activityWeakReference = new WeakReference<>(binding.getActivity());
        deviceTokenHelper.setActivity(activityWeakReference);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }


}
