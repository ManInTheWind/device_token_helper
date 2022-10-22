#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint device_token_helper.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'device_token_helper'
  s.version          = '0.0.1'
  s.summary          = 'assist developer to get device token to implement the ability of the vendor push'
  s.description      = <<-DESC
assist developer to get device token to implement the ability of the vendor push
                       DESC
  s.homepage         = 'https://github.com/ManInTheWind/device_token_helper'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'kangkang' => 'kangkanglaile1205@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'HyphenateChat'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
