import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_token_helper_platform_interface.dart';

/// An implementation of [DeviceTokenHelperPlatform] that uses method channels.
class MethodChannelDeviceTokenHelper extends DeviceTokenHelperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('device_token_helper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
