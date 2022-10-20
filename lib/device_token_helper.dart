import 'package:flutter/services.dart';

import 'device_token_helper_platform_interface.dart';

class DeviceTokenHelper {
  Future<String?> getPlatformVersion() {
    return DeviceTokenHelperPlatform.instance.getPlatformVersion();
  }

  final MethodChannel _methodChannel =
      const MethodChannel('device_token_helper');

  Future<String?> getHmsPushToken() async {
    return _methodChannel.invokeMethod<String>('getHmsPushToken');
  }
}
