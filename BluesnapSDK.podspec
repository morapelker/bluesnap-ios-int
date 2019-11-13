Pod::Spec.new do |s|
  s.name         = "BluesnapSDK"
  s.version      = "1.3.0"
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
  s.swift_version = '5.0'
  s.source       = { :git => "https://github.com/bluesnap/bluesnap-ios.git", :tag => "#{s.version}" }
  s.source_files  = "BluesnapSDK/**/*.{h,m,swift,a}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0', 'ONLY_ACTIVE_ARCH' => 'NO' }
  s.resource_bundles = {
    'BluesnapUI' => [
        'BluesnapSDK/**/*.xib',
        'BluesnapSDK/**/*.storyboard',
        'BluesnapSDK/**/Media.xcassets',
        'BluesnapSDK/**/*.strings' 
	]
  }
  s.exclude_files =  ["BluesnapSDK/CardinalMobile.framework/Headers/**", "BluesnapSDK/BluesnapSDKTests/**/*.*","BluesnapSDK/BluesnapSDKIntegrationTests/**/*.*","BluesnapSDK/**/libKountDataCollector.a","BluesnapSDK/**/KDataCollector.{h,m}" ]
  s.ios.vendored_frameworks = 'BluesnapSDK/CardinalMobile.framework'
  
  s.resources = "BluesnapSDK/**/Media.xcassets"
  s.frameworks                     = 'Foundation', 'Security', 'WebKit', 'PassKit', 'AddressBook', 'UIKit' , 
  s.weak_frameworks                = 'Contacts'
  s.requires_arc = true
  s.subspec "DataCollector" do |s|
    s.source_files = "BluesnapSDK/**/KDataCollector.{h,m}"
    s.public_header_files = "BluesnapSDK/**/KDataCollector*.h"
    s.public_header_files = "BluesnapSDK/**/KDataCollector*.h"
    s.vendored_library = "BluesnapSDK/**/libKountDataCollector.a"
    end
  
end
