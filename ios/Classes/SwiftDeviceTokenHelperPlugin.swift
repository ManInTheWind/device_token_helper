import Flutter
import UIKit

public class SwiftDeviceTokenHelperPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "device_token_helper", binaryMessenger: registrar.messenger())
        let instance = SwiftDeviceTokenHelperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("call.method:\(call.method)")
        switch call.method {
        case "getIOSDeviceToken":
            registerDeviceToken(result)
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            break
        }
    }

    public func registerDeviceToken(_ result: @escaping FlutterResult) {
        print("registerDeviceToken")
        UIApplication.shared.registerForRemoteNotifications()
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
        let token = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        
        print("deviceToken success:\(token)")
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("deviceToken failed:\(error)")
    }
}
