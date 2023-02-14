#
# Be sure to run `pod lib lint lottie-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LottieForAFWP'
  s.version          = '4.1.2'
  s.summary          = 'A library to render native animations from bodymovin json'

  s.description = <<-DESC
Lottie is a mobile library for Android and iOS that parses Adobe After Effects animations exported as json with bodymovin and renders the vector animations natively on mobile and through React Native!

Lottie enables designers to create and ship beautiful animations without an engineer painstakingly recreating it be hand. Since the animation is backed by JSON they are extremely small in size but can be large in complexity! Animations can be played, resized, looped, sped up, slowed down, and even interactively scrubbed.
  DESC

  s.homepage         = 'https://github.com/airbnb/lottie-ios'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Brandon Withrow' => 'buba447@gmail.com', 'Cal Stephens' => 'cal.stephens@airbnb.com' }
  s.source           = { :git => 'https://github.com/airbnb/lottie-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.5'
  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/**/*'
  s.ios.exclude_files = 'Sources/Public/MacOS/**/*'

  s.ios.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.module_name = 'LottieForAFWP'
end
