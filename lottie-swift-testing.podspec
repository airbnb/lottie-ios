#
# This podspec is used for local developing of Lottie only. It is not to be published.

Pod::Spec.new do |s|
  s.name             = 'lottie-swift-testing'
  s.version          = '0.1.0'
  s.summary          = 'Podspec used for testing new versions of lottie against the current published base.'

  s.description      = 'Podspec used for testing new versions of lottie against the current published base.'

  s.homepage         = 'https://github.com/buba447/lottie-swift'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Brandon Withrow' => 'buba447@gmail.com' }
  s.source           = { :git => 'https://github.com/airbnb/lottie-ios.git', :branch => 'master' }
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  
  s.source_files = 'lottie-swift/src/**/*'
  s.ios.source_files   = 'lottie-swift/iOS/*.swift'
  s.ios.exclude_files   = 'lottie-swift/src/Public/MacOS/**/*'
  s.tvos.exclude_files   = 'lottie-swift/src/Public/MacOS/**/*'
  s.osx.exclude_files = 'lottie-swift/src/Public/iOS/**/*'
  
  s.ios.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.tvos.frameworks = ['UIKit', 'CoreGraphics', 'QuartzCore']
  s.osx.frameworks = ['AppKit', 'CoreGraphics', 'QuartzCore']
  s.module_name = 'LottieNew'
  s.header_dir = 'LottieNew'
end
