import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_token_helper_method_channel.dart';

abstract class DeviceTokenHelperPlatform extends PlatformInterface {
  /// Constructs a DeviceTokenHelperPlatform.
  DeviceTokenHelperPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceTokenHelperPlatform _instance = MethodChannelDeviceTokenHelper();

  /// The default instance of [DeviceTokenHelperPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceTokenHelper].
  static DeviceTokenHelperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DeviceTokenHelperPlatform] when
  /// they register themselves.
  static set instance(DeviceTokenHelperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
