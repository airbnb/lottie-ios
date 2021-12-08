namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all']

  desc 'Builds the Lottie package for supported platforms'
  namespace :package do
    desc 'Builds the Lottie package for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the Lottie package for iOS'
    task :iOS do
      sh 'xcodebuild build -scheme Lottie -destination generic/platform=iOS | mint run xcbeautify'
    end

    desc 'Builds the Lottie package for macOS'
    task :macOS do
      sh 'xcodebuild build -scheme Lottie -destination generic/platform=macOS | mint run xcbeautify'
    end

    desc 'Builds the Lottie package for tvOS'
    task :tvOS do
      sh 'xcodebuild build -scheme Lottie -destination generic/platform=tvOS | mint run xcbeautify'
    end
  end

  desc 'Builds the Lottie example app for supported platforms'
  namespace :example do
    desc 'Builds the Lottie example apps for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the iOS Lottie Example app'
    task :iOS do
      sh 'xcodebuild build -scheme "Example (iOS)" -destination "platform=iOS Simulator,name=iPhone 8" | mint run xcbeautify'
    end

    desc 'Builds the macOS Lottie Example app'
    task :macOS do
      sh 'xcodebuild build -scheme "Example (macOS)" | mint run xcbeautify'
    end

    desc 'Builds the tvOS Lottie Example app'
    task :tvOS do
      sh 'xcodebuild build -scheme "Example (tvOS)" -destination "platform=tvOS Simulator,name=Apple TV" | mint run xcbeautify'
    end
  end
end

namespace :lint do
  desc 'Lints swift files'
  task :swift do
    sh 'mint run SwiftLint lint Sources Example Package.swift --config script/lint/swiftlint.yml --strict'
    sh 'mint run SwiftFormat Sources Example Package.swift --config script/lint/airbnb.swiftformat --lint'
  end
end

namespace :format do
  desc 'Runs SwiftFormat'
  task :swift do
    sh 'mint run SwiftLint autocorrect Sources Example Package.swift --config script/lint/swiftlint.yml'
    sh 'mint run SwiftFormat Sources Example Package.swift --config script/lint/airbnb.swiftformat'
  end
end
