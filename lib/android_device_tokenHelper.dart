import 'package:flutter/services.dart';

import 'device_token_help.dart';

class AndroidDeviceTokenHelper extends DeviceTokenHelper {
  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> getDeviceBrand() async {
    return methodChannel.invokeMethod<String>('DeviceBrand');
  }

  Future<String?> getHuaweiDeviceToken() async {
    return methodChannel.invokeMethod<String>('HuaweiDeviceToken');
  }

  Future<void> onUpdateDeviceToken(
    ValueChanged<String> onUpdate,
    Function? onError,
  ) async {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'UpdateHuaweiDeviceToken') {
        onUpdate.call(call.arguments as String);
      } else if (call.method == "CatchHuaweiDeviceTokenError") {
        onError?.call(call.arguments);
      }
    });
  }

  Future<void> onCatchHuaweiDeviceTokenError(
      ValueChanged<String> onUpdate) async {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'UpdateHuaweiDeviceToken') {
        onUpdate.call(call.arguments as String);
      }
    });
  }

  Future<String?> getOppoDeviceToken({
    required String appKey,
    required String appSecret,
    bool needLog = true,
  }) async {
    assert(appKey.isNotEmpty || appSecret.isNotEmpty, 'appKey或者appSecret不正确');
    return methodChannel.invokeMethod<String>('OppoDeviceToken', {
      'AppKey': appKey,
      'AppSecret': appSecret,
      'NeedLog': needLog,
    });
  }

  Future<String?> getXiaomiDeviceToken() async {
    return methodChannel.invokeMethod<String>('XiaomiDeviceToken');
  }

  Future<String?> getMeizuDeviceToken() async {
    return methodChannel.invokeMethod<String>('MeizuDeviceToken');
  }

  Future<String?> getSonyDeviceToken() async {
    return methodChannel.invokeMethod<String>('SonyDeviceToken');
  }

  Future<String?> getSamsungDeviceToken() async {
    return methodChannel.invokeMethod<String>('SamsungDeviceToken');
  }

  Future<String?> getLgDeviceToken() async {
    return methodChannel.invokeMethod<String>('LgDeviceToken');
  }

  Future<String?> getHtcDeviceToken() async {
    return methodChannel.invokeMethod<String>('HtcDeviceToken');
  }

  Future<String?> getNovaDeviceToken() async {
    return methodChannel.invokeMethod<String>('NovaDeviceToken');
  }

  Future<String?> getLeMobileDeviceToken() async {
    return methodChannel.invokeMethod<String>('LeMobileDeviceToken');
  }

  Future<String?> getLenovoDeviceToken() async {
    return methodChannel.invokeMethod<String>('LenovoDeviceToken');
  }

  @override
  MethodChannel get methodChannel =>
      const MethodChannel('android_device_token_helper');
}
