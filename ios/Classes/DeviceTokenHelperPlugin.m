#import "DeviceTokenHelperPlugin.h"
#if __has_include(<device_token_helper/device_token_helper-Swift.h>)
#import <device_token_helper/device_token_helper-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "device_token_helper-Swift.h"
#endif

@implementation DeviceTokenHelperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDeviceTokenHelperPlugin registerWithRegistrar:registrar];
}
@end
