import 'package:flutter/services.dart';

import 'ios_authorization_options.dart';

class DeviceTokenHelper {
  final MethodChannel _methodChannel =
      const MethodChannel('device_token_helper');

  Future<String?> getPlatformVersion() {
    return _methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  Future<String?> getHmsPushToken() async {
    return _methodChannel.invokeMethod<String>('getHmsPushToken');
  }

  Future<bool?> requestAuthorizationWithOption(
    List<IOSAuthorizationOption> options,
  ) async {
    return _methodChannel.invokeMethod<bool>(
      "requestAuthorizationWithOption",
      options.map((e) => e.index).toList(),
    );
  }

  Future<void> getIOSDeviceToken({
    required ValueChanged<String?> tokenCallback,
    Function? onError,
  }) async {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onToken":
          tokenCallback.call(call.arguments as String?);
          break;
        case "onError":
          onError?.call(call.arguments);
          break;
        default:
          break;
      }
    });
    _methodChannel.invokeMethod<void>('getIOSDeviceToken');
  }
}
