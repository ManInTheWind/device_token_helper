import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_token_help.dart';
import 'ios_notification_message_model.dart';

typedef WillPresentHandler = Future<bool> Function();

/// Handler that returns true/false to decide if push alert should be displayed when in foreground.
/// Returning true will delay onMessage callback until user actually clicks on it
typedef OnMessageWillPresent = Future<bool> Function(
    IOSNotificationMessageModel);

class IosDeviceTokenHelper extends DeviceTokenHelper {
  WillPresentHandler? shouldPresent;

  final token = ValueNotifier<String?>(null);

  void registerIosPluginHandler({
    required ValueChanged<String?> tokenCallback,
    AsyncValueSetter<IOSNotificationMessageModel>? onLaunch,
    OnMessageWillPresent? onMessageWillPresent,
    AsyncValueSetter<IOSNotificationMessageModel>? onMessageDidReceive,
    Function? onTokenRequestError,
  }) {
    void tokenListener() {
      tokenCallback.call(token.value);
      if (token.value != null) {
        token.removeListener(tokenListener);
      }
    }

    token.addListener(tokenListener);
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTokenRequestSuccess':
          token.value = call.arguments;
          break;
        case 'onTokenRequestError':
          onTokenRequestError?.call(call.arguments);
          break;
        case 'onMessageWillPresent':
          //需要在一秒内决定是否展示通知
          return onMessageWillPresent?.call(_extractMessage(call)).timeout(
                  const Duration(seconds: 1),
                  onTimeout: () => false) ??
              false;
        case 'onLaunch':
          onLaunch?.call(_extractMessage(call));
          break;
        case 'onMessageDidReceive':
          onMessageDidReceive?.call(_extractMessage(call));
          break;
        default:
          break;
      }
    });

    methodChannel.invokeMethod("initEMLocalNotificationManager");
  }

  Future<bool?> requestNotificationPermissionsWithOption({
    bool sound = true,
    bool alert = true,
    bool badge = true,
    bool provisional = false,
  }) async {
    final bool? result = await methodChannel.invokeMethod<bool>(
        'requestNotificationPermissions',
        IosNotificationSettings(
          sound: sound,
          alert: alert,
          badge: badge,
          provisional: provisional,
        ).toMap());
    return result ?? false;
  }

  Future<void> unregisterForNotification() async {
    await methodChannel.invokeMethod("unregisterForNotification");
    token.value = null;
  }

  IOSNotificationMessageModel _extractMessage(MethodCall call) {
    final rawJsonData = call.arguments as String?;
    if (rawJsonData == null) {
      return const IOSNotificationMessageModel();
    }
    final json = jsonDecode(rawJsonData);
    return IOSNotificationMessageModel.fromJson(
      Map<String, dynamic>.from(json),
    );
  }

  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>('getPlatformVersion');
  }

  @override
  MethodChannel get methodChannel =>
      const MethodChannel('ios_device_token_helper');
}

class IosNotificationSettings {
  const IosNotificationSettings({
    this.sound = true,
    this.alert = true,
    this.badge = true,
    this.provisional = false,
  });

  IosNotificationSettings._fromMap(Map<String, bool> settings)
      : sound = settings['sound'],
        alert = settings['alert'],
        badge = settings['badge'],
        provisional = settings['provisional'];

  final bool? sound;
  final bool? alert;
  final bool? badge;
  final bool? provisional;

  Map<String, dynamic> toMap() => <String, bool?>{
        'sound': sound,
        'alert': alert,
        'badge': badge,
        'provisional': provisional,
      };

  @override
  String toString() => 'PushNotificationSettings ${toMap()}';
}
