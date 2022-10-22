import 'package:flutter/services.dart';

abstract class DeviceTokenHelper {
  MethodChannel get methodChannel;

  Future<String?> getPlatformVersion();
}
