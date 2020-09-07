#
# Be sure to run `pod lib lint lottie-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'lottie-ios'
  s.version          = '3.1.8'
  s.summary          = 'A library to render native animations from bodymovin json. Now in Swift!'

  s.description = <<-DESC
Lottie is a mobile library for Android and iOS that parses Adobe After Effects animations exported as json with bodymovin and renders the vector animations natively on mobile and through React Native!

For the first time, designers can create and ship beautiful animations without an engineer painstakingly recreating it be hand. Since the animation is backed by JSON they are extremely small in size but can be large in complexity! Animations can be played, resized, looped, sped up, slowed down, and even interactively scrubbed.
  DESC

  s.homepage         = 'https://github.com/airbnb/lottie-ios'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Brandon Withrow' => 'buba447@gmail.com' }
  s.source           = { :git => 'https://github.com/airbnb/lottie-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'lottie-swift/src/**/*'
  s.ios.source_files = 'lottie-swift/iOS/*.swift'
  s.ios.exclude_files = 'lottie-swift/src/Public/MacOS/**/*'
  s.tvos.exclude_files = 'lottie-swift/src/Public/MacOS/**/*'
  s.osx.exclude_files = 'lottie-swift/src/Public/iOS/**/*'

  s.ios.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.tvos.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.osx.frameworks = ['AppKit', 'CoreGraphics', 'QuartzCore']
  s.module_name = 'Lottie'
  s.header_dir = 'Lottie'
end
