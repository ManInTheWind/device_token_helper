import 'package:flutter/services.dart';

import 'device_token_help.dart';

class AndroidDeviceTokenHelper extends DeviceTokenHelper {
  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> getHmsPushToken() async {
    return methodChannel.invokeMethod<String>('getHmsPushToken');
  }

  @override
  MethodChannel get methodChannel =>
      const MethodChannel('android_device_token_helper');
}
