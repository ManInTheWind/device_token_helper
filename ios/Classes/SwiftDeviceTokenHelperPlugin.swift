import Flutter
import HyphenateChat
import UIKit

@objc public class SwiftDeviceTokenHelperPlugin: NSObject, FlutterPlugin, EMLocalNotificationDelegate {
    // private var authorizationOptions: UNAuthorizationOptions = []

    internal init(_ channel: FlutterMethodChannel) {
        methodChannel = channel
    }

    let methodChannel: FlutterMethodChannel

    var launchNotification: String?

    var resumingFromBackground = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ios_device_token_helper", binaryMessenger: registrar.messenger())

        let instance = SwiftDeviceTokenHelperPlugin(channel)

        registrar.addMethodCallDelegate(instance, channel: channel)

        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // print("call.method:\(call.method)")
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "configure":
            onConfigure(result)
        case "initEMLocalNotificationManager":
            initEMLocalNotificationManager()
        case "requestNotificationPermissions":
            requestNotificationPermissions(call, result: result)
        case "unregisterForNotification":
            UIApplication.shared.unregisterForRemoteNotifications()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - 开启环信推送处理

    public func initEMLocalNotificationManager() {
        EMLocalNotificationManager.shared().launch(with: self)
    }

    // MARK: - 获取权限，设置通知样式

    func requestNotificationPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let center = UNUserNotificationCenter.current()
        let application = UIApplication.shared

        func readBool(_ key: String) -> Bool {
            (call.arguments as? [String: Any])?[key] as? Bool ?? false
        }

        assert(center.delegate != nil)

        var options = [UNAuthorizationOptions]()

        if readBool("sound") {
            options.append(.sound)
        }
        if readBool("badge") {
            options.append(.badge)
        }
        if readBool("alert") {
            options.append(.alert)
        }

        // var provisionalRequested = false
        if #available(iOS 12.0, *) {
            if readBool("provisional") {
                options.append(.provisional)
                // provisionalRequested = true
            }
        }

        let optionsUnion = UNAuthorizationOptions(options)

        center.requestAuthorization(options: optionsUnion) { granted, error in
            if let error = error {
                result(self.getFlutterError(error))
                return
            }

            result(granted)
        }

        application.registerForRemoteNotifications()
    }

    // MARK: - 配置回调并开始注册DeviceTolen

    public func onConfigure(_ result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        assert(
            UNUserNotificationCenter.current().delegate != nil,
            "UNUserNotificationCenter.current().delegate is not set. Check and add it at [AppDeletegate.didFinishLaunchingWithOptions]"
        )
        // 请求Token
        UIApplication.shared.registerForRemoteNotifications()

        // check for onLaunch notification *after* configure has been ran
        if let launchNotification = launchNotification {
            methodChannel.invokeMethod("onLaunch", arguments: launchNotification)
            self.launchNotification = nil
            return
        }
        result(nil)
    }

    // MARK: - 回调成功

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        // deviceToken success:bd67c2dc33cb8817a4646a5d70a4e5b542343c8e9bc0184d19a45e8d24cefb45
        methodChannel.invokeMethod("onTokenRequestSuccess", arguments: deviceToken.hexString)
    }

    // MARK: - 回调失败

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        methodChannel.invokeMethod("onTokenRequestError", arguments: getFlutterError(error))
    }

    // MARK: - AppDelegate

    public func applicationDidEnterBackground(_ application: UIApplication) {
        resumingFromBackground = true
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        resumingFromBackground = false
        UIApplication.shared.applicationIconBadgeNumber = -1
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {
        if let launchNotification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any] {
            self.launchNotification = remoteMessageUserInfoToDict(launchNotification)
        }

        return true
    }

    // MARK: - EMLocalNotificationDelegate

    // MARK: - 收到推送消息,并决定是否展示

    //! !! -在启用在线通道过程中，SDK会重写[UNUserNotificationCenter currentNotificationCenter]的delegate，如果要处理其他本地通知，需要实现EMLocalNotificationDelegate，过程如下

    public func emuserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("---emuserNotificationCenter willPresent---")
        print("userInfo:\(notification.request.content.userInfo)")

        /*
         userInfo:[AnyHashable("ext"): {
             userId = 3402125616893952;
         }, AnyHashable("emtype"): em_custom_localpush, AnyHashable("operation"): {
             type = 0;
         }, AnyHashable("report"): {
             "task_id" = 1033448775987388209;
         }]
         */

        let userInfoStr = remoteMessageUserInfoToDict(notification.request.content.userInfo)

        methodChannel.invokeMethod("onMessageWillPresent", arguments: userInfoStr) { result in
            let shouldPresentNotication = (result as? Bool) ?? false
            if shouldPresentNotication {
                if #available(iOS 14.0, *) {
                    completionHandler([.sound, .banner])
                } else {
                    completionHandler([.sound, .alert])
                }
            } else {
                completionHandler([])
            }
        }
    }

    // MARK: - 当用户打开应用推送通知时，此方法会被调用

    public func emuserNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("---emuserNotificationCenter didReceiveResponse---")

        print("userInfo:\(response.notification.request.content.userInfo)")

        /*
         userInfo:[AnyHashable("EPush"): {
             origin = push;
             provider = APNS;
             report =     {
                 "task_id" = 1033451712516085529;
             };
             timestamp = 1666435690596;
         }, AnyHashable("userId"): 3402125616893952, AnyHashable("aps"): {
             alert =     {
                 body = "\U8bd5\U8bd5\U5e26ext\U7684";
                 title = "\U8bd5\U8bd5\U5e26ext\U7684";
             };
             badge = 1;
             "mutable-content" = 1;
             sound = default;
         }]
         */

        var userInfo = response.notification.request.content.userInfo

        userInfo["actionIdentifier"] = response.actionIdentifier

        let userInfoStr = remoteMessageUserInfoToDict(response.notification.request.content.userInfo)

        methodChannel.invokeMethod("onMessageDidReceive", arguments: userInfoStr)

        completionHandler()
    }

    func remoteMessageUserInfoToDict(_ userInfo: [AnyHashable: Any]) -> String? {
        var jsonData: Data?
        do {
            jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        } catch let parseError {
            print(parseError)
        }
        var str: String?
        if let jsonData {
            str = String(data: jsonData, encoding: .utf8)
        }
        return str
    }

    func getFlutterError(_ error: Error) -> FlutterError {
        let e = error as NSError
        return FlutterError(code: "Error: \(e.code)", message: e.domain, details: error.localizedDescription)
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
