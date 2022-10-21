import Flutter
import UIKit

public class SwiftDeviceTokenHelperPlugin: NSObject, FlutterPlugin {
    private var authorizationOptions: UNAuthorizationOptions = []

    private var methodChannel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "device_token_helper", binaryMessenger: registrar.messenger())

        let instance = SwiftDeviceTokenHelperPlugin()

        instance.methodChannel = channel

        registrar.addMethodCallDelegate(instance, channel: channel)

        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("call.method:\(call.method)")
        switch call.method {
        case "requestAuthorizationWithOption":
            _requestAuthorizationWithOption(arguments: call.arguments, result: result)

        case "getIOSDeviceToken":
            getIOSDeviceToken(result)

        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - 获取权限，设置通知样式

    public func _requestAuthorizationWithOption(arguments: Any?, result: @escaping FlutterResult) {
        if let userRequestAuthorizationRaw = arguments {
            if let userRequestAuthorizationOptions = userRequestAuthorizationRaw as? [Int] {
                for index in userRequestAuthorizationOptions {
                    let option =
                        UNAuthorizationOptions(rawValue: UInt(index))

                    authorizationOptions.insert(option)
                }
            }
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error != nil {
                result(FlutterError(code: "-1", message: "请求通知权限时候遇到错误：", details: error))
            } else {
                result(granted)
            }
        }
    }

    // MARK: - 请求Token

    public func getIOSDeviceToken(_ result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - 回调成功

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        // deviceToken success:bd67c2dc33cb8817a4646a5d70a4e5b542343c8e9bc0184d19a45e8d24cefb45
        // print("deviceToken success:\(token)")
        methodChannel?.invokeMethod("onToken", arguments: token)
    }

    // MARK: - 回调失败

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // print("deviceToken failed:\(error)")
        methodChannel?.invokeMethod("onError", arguments: FlutterError(code: "-1", message: "请求Token时候遇到错误：", details: error))
    }

    // MARK: - 收到推送消息

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        print("userInfo:\(userInfo)")
        return true
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        return true
    }
}
