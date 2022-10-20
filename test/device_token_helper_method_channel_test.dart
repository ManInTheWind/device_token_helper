import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_token_helper/device_token_helper_method_channel.dart';

void main() {
  MethodChannelDeviceTokenHelper platform = MethodChannelDeviceTokenHelper();
  const MethodChannel channel = MethodChannel('device_token_helper');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
