namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all']

  desc 'Builds the Lottie package for supported platforms'
  namespace :package do
    desc 'Builds the Lottie package for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the Lottie package for iOS'
    task :iOS do
      xcodebuild('build -scheme Lottie -destination generic/platform=iOS')
    end

    desc 'Builds the Lottie package for macOS'
    task :macOS do
      xcodebuild('build -scheme Lottie -destination generic/platform=macOS')
    end

    desc 'Builds the Lottie package for tvOS'
    task :tvOS do
      xcodebuild('build -scheme Lottie -destination generic/platform=tvOS')
    end
  end

  desc 'Builds the Lottie example app for supported platforms'
  namespace :example do
    desc 'Builds the Lottie example apps for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the iOS Lottie Example app'
    task :iOS do
      xcodebuild('build -scheme "Example (iOS)" -destination "platform=iOS Simulator,name=iPhone 8"')
    end

    desc 'Builds the macOS Lottie Example app'
    task :macOS do
      xcodebuild('build -scheme "Example (macOS)"')
    end

    desc 'Builds the tvOS Lottie Example app'
    task :tvOS do
      xcodebuild('build -scheme "Example (tvOS)" -destination "platform=tvOS Simulator,name=Apple TV"')
    end
  end
end

namespace :test do
  desc 'Tests the Lottie package for iOS'
  task :package do
    sh 'rm -rf Tests/Artifacts'
    xcodebuild('test -scheme Lottie -destination "platform=iOS Simulator,name=iPhone 8" -resultBundlePath Tests/Artifacts/LottieTests.xcresult')
  end

  desc 'Processes .xcresult artifacts from the most recent test:package execution'
  task :process do
    sh 'mint run ChargePoint/xcparse@2.1.0 xcparse attachments Tests/Artifacts/LottieTests.xcresult Tests/Artifacts/TestAttachments'
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
