import 'package:flutter_test/flutter_test.dart';
import 'package:device_token_helper/device_token_helper.dart';
import 'package:device_token_helper/device_token_helper_platform_interface.dart';
import 'package:device_token_helper/device_token_helper_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceTokenHelperPlatform
    with MockPlatformInterfaceMixin
    implements DeviceTokenHelperPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DeviceTokenHelperPlatform initialPlatform = DeviceTokenHelperPlatform.instance;

  test('$MethodChannelDeviceTokenHelper is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceTokenHelper>());
  });

  test('getPlatformVersion', () async {
    DeviceTokenHelper deviceTokenHelperPlugin = DeviceTokenHelper();
    MockDeviceTokenHelperPlatform fakePlatform = MockDeviceTokenHelperPlatform();
    DeviceTokenHelperPlatform.instance = fakePlatform;

    expect(await deviceTokenHelperPlugin.getPlatformVersion(), '42');
  });
}
