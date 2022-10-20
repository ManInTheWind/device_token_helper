import 'package:flutter/services.dart';

class DeviceTokenHelper {
  final MethodChannel _methodChannel =
      const MethodChannel('device_token_helper');

  Future<String?> getPlatformVersion() {
    return _methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> getHmsPushToken() async {
    return _methodChannel.invokeMethod<String>('getHmsPushToken');
  }

  Future<void> getIOSDeviceToken() async {
    return _methodChannel.invokeMethod<void>('getIOSDeviceToken');
  }
}
