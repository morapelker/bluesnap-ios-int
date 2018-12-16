Pod::Spec.new do |s|
  s.name         = "BluesnapSDK"
  s.version      = "1.0.1"
  s.summary      = "An iOS SDK for Bluesnap "
  s.description  = <<-DESC
  Integrate payment methods into your iOS native apps quickly and easily.
  Bluesnap iOS SDK supports credit card and apple pay, currency conversions and more.
                  DESC
  s.homepage     = "http://www.bluesnap.com"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "snpori" => "oribsnap@gmail.com" }
  s.platform = :ios
  s.ios.deployment_target = '9.3'
  s.swift_version = '4.2'
  s.source       = { :git => "https://github.com/bluesnap/bluesnap-ios.git", :tag => "#{s.version}" }
  s.source_files  = "BluesnapSDK/**/*.{h,m,swift,a}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2', 'ONLY_ACTIVE_ARCH' => 'NO' }
  s.resource_bundles = {
    'BluesnapUI' => [
        'BluesnapSDK/**/*.xib',
        'BluesnapSDK/**/*.storyboard',
        'BluesnapSDK/**/Media.xcassets',
        'BluesnapSDK/**/*.strings' 
	]
  }
  s.exclude_files = "BluesnapSDK/BluesnapSDKTests/**/*.*"
  s.resources = "BluesnapSDK/**/Media.xcassets"
  s.frameworks                     = 'Foundation', 'Security', 'WebKit', 'PassKit', 'AddressBook', 'UIKit'
  s.weak_frameworks                = 'Contacts'
  s.requires_arc = true
end
