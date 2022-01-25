namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all']

  desc 'Builds the Lottie package for supported platforms'
  namespace :package do
    desc 'Builds the Lottie package for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the Lottie package for iOS'
    task :iOS do
      xcodebuild('build -scheme "Lottie (iOS)" -destination generic/platform=iOS -workspace Lottie.xcworkspace')
    end

    desc 'Builds the Lottie package for macOS'
    task :macOS do
      xcodebuild('build -scheme "Lottie (macOS)" -destination generic/platform=macOS -workspace Lottie.xcworkspace')
    end

    desc 'Builds the Lottie package for tvOS'
    task :tvOS do
      xcodebuild('build -scheme "Lottie (tvOS)" -destination generic/platform=tvOS -workspace Lottie.xcworkspace')
    end
  end

  desc 'Builds the Lottie example app for supported platforms'
  namespace :example do
    desc 'Builds the Lottie example apps for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the iOS Lottie Example app'
    task :iOS do
      xcodebuild('build -scheme "Example (iOS)" -destination "platform=iOS Simulator,name=iPhone 8" -workspace Lottie.xcworkspace')
    end

    desc 'Builds the macOS Lottie Example app'
    task :macOS do
      xcodebuild('build -scheme "Example (macOS)" -workspace Lottie.xcworkspace')
    end

    desc 'Builds the tvOS Lottie Example app'
    task :tvOS do
      xcodebuild('build -scheme "Example (tvOS)" -destination "platform=tvOS Simulator,name=Apple TV" -workspace Lottie.xcworkspace')
    end
  end
end

namespace :test do
  desc 'Tests the Lottie package for iOS'
  task :package do
    sh 'rm -rf Tests/Artifacts'
    xcodebuild('test -scheme "Lottie (iOS)" -destination "platform=iOS Simulator,name=iPhone 8" -resultBundlePath Tests/Artifacts/LottieTests.xcresult')
  end

  desc 'Processes .xcresult artifacts from the most recent test:package execution'
  task :process do
    sh 'mint run ChargePoint/xcparse@2.2.1 xcparse attachments Tests/Artifacts/LottieTests.xcresult Tests/Artifacts/TestAttachments'
  end

  desc 'Tests Carthage support'
  task :carthage do
    # Copy the repo to `Carthage/Checkouts/Lottie-ios`
    sh 'rm -rf script/test-carthage/Carthage'
    sh 'mkdir script/test-carthage/Carthage script/test-carthage/Carthage/Checkouts script/test-carthage/Carthage/Checkouts/lottie-ios'
    sh 'cp -R [^script]* script/test-carthage/Carthage/Checkouts/lottie-ios'

    Dir.chdir('script/test-carthage') do
      # Build the LottieCarthage framework scheme
      sh 'carthage build --use-xcframeworks'

      # Delete Carthage's derived data to verify that the built .xcframework doesn't depend on any
      # side effects from building on this specific machine.
      # https://github.com/airbnb/lottie-ios/issues/1492
      sh 'rm -rf ~/Library/Caches/org.carthage.CarthageKit/DerivedData'

      # Build a test app that imports and uses the LottieCarthage framework
      xcodebuild('build -scheme CarthageTest -destination "platform=iOS Simulator,name=iPhone 8"')
    end
  end

  desc 'Tests Swift Package Manager support'
  task :spm do
    Dir.chdir('script/test-spm') do
      # Build for iOS, macOS, and tvOS using the targets defined in Package.swift
      xcodebuild('build -scheme "Lottie" -destination generic/platform=iOS')
      xcodebuild('build -scheme "Lottie" -destination generic/platform=macOS')
      xcodebuild('build -scheme "Lottie" -destination generic/platform=tvOS')
    end
  end
end

namespace :lint do
  desc 'Lints swift files'
  task swift: ['swift:swiftlint', 'swift:swiftformat']

  desc 'Lints swift files'
  namespace :swift do
    desc 'Lints swift files using SwiftLint'
    task :swiftlint do
      sh 'mint run SwiftLint lint Sources Tests Example Package.swift --config script/lint/swiftlint.yml --strict'
    end

    desc 'Lints swift files using SwiftLint'
    task :swiftformat do
      sh 'mint run SwiftFormat Sources Tests Example Package.swift --config script/lint/airbnb.swiftformat --lint'
    end
  end

  desc 'Lints the CocoaPods podspec'
  task :podspec do
    sh 'pod lib lint lottie-ios.podspec'
  end
end

namespace :format do
  desc 'Runs SwiftFormat'
  task :swift do
    sh 'mint run SwiftLint autocorrect Sources Tests Example Package.swift --config script/lint/swiftlint.yml'
    sh 'mint run SwiftFormat Sources Tests Example Package.swift --config script/lint/airbnb.swiftformat'
  end
end

def xcodebuild(command)
  sh "set -o pipefail && xcodebuild #{command} | mint run xcbeautify"
end
