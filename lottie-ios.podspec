#
# Be sure to run `pod lib lint lottie-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'lottie-ios'
  s.version          = '4.5.1'
  s.summary          = 'A library to render native animations from bodymovin json'

  s.description = <<-DESC
Lottie is a mobile library for Android and iOS that parses Adobe After Effects animations exported as json with bodymovin and renders the vector animations natively on mobile and through React Native!

Lottie enables designers to create and ship beautiful animations without an engineer painstakingly recreating it be hand. Since the animation is backed by JSON they are extremely small in size but can be large in complexity! Animations can be played, resized, looped, sped up, slowed down, and even interactively scrubbed.
  DESC

  s.homepage         = 'https://github.com/airbnb/lottie-ios'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Brandon Withrow' => 'buba447@gmail.com', 'Cal Stephens' => 'cal.stephens@airbnb.com' }
  s.source           = { :git => 'https://github.com/airbnb/lottie-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.visionos.deployment_target = "1.0"

  s.source_files = 'Sources/**/*.swift'
  s.resource_bundles = {
    'LottiePrivacyInfo' => ['Sources/PrivacyInfo.xcprivacy'],
  }
  s.ios.exclude_files = 'Sources/Public/MacOS/**/*'
  s.tvos.exclude_files = 'Sources/Public/MacOS/**/*'
  s.osx.exclude_files = 'Sources/Public/iOS/**/*'

  s.ios.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.tvos.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.osx.frameworks = ['AppKit', 'CoreGraphics', 'QuartzCore']
  s.weak_frameworks = ['SwiftUI', 'Combine']
  s.module_name = 'Lottie'
end
