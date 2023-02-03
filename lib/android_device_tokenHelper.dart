import 'package:flutter/services.dart';

import 'device_token_help.dart';

class AndroidDeviceTokenHelper extends DeviceTokenHelper {
  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> getDeviceToken() async {
    return methodChannel.invokeMethod<String>('getDeviceToken');
  }

  @override
  MethodChannel get methodChannel =>
      const MethodChannel('android_device_token_helper');
}
