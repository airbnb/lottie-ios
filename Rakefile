namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all']

  desc 'Builds the Lottie package for supported platforms'
  namespace :package do
    desc 'Builds the Lottie package for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the Lottie package for iOS'
    task :iOS do
      sh 'xcodebuild build -scheme Lottie -destination generic/platform=iOS'
    end

    desc 'Builds the Lottie package for macOS'
    task :macOS do
      sh 'xcodebuild build -scheme Lottie -destination generic/platform=macOS'
    end

    desc 'Builds the Lottie package for tvOS'
    task :tvOS do
      sh 'xcodebuild build -scheme Lottie -destination generic/platform=tvOS'
    end
  end

  desc 'Builds the Lottie example app for supported platforms'
  namespace :example do
    desc 'Builds the Lottie example apps for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS']

    desc 'Builds the iOS Lottie Example app'
    task :iOS do
      sh 'xcodebuild build -scheme "Example (iOS)" -destination "platform=iOS Simulator,name=iPhone 8"'
    end

    desc 'Builds the macOS Lottie Example app'
    task :macOS do
      sh 'xcodebuild build -scheme "Example (macOS)"'
    end

    desc 'Builds the tvOS Lottie Example app'
    task :tvOS do
      sh 'xcodebuild build -scheme "Example (tvOS)" -destination "platform=tvOS Simulator,name=Apple TV"'
    end
  end
end

namespace :lint do
  desc 'Lints swift files'
  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint lint Sources Example Package.swift --config script/lint/swiftlint.yml --strict'
    sh 'mint run SwiftFormat Sources Example Package.swift --config script/lint/airbnb.swiftformat --lint '
  end
end

namespace :format do
  desc 'Runs SwiftFormat'
  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint autocorrect Sources Example Package.swift --config script/lint/swiftlint.yml'
    sh 'mint run SwiftFormat Sources Example Package.swift --config script/lint/airbnb.swiftformat'
  end
end

namespace :bootstrap do
  task :mint do
    `which mint`
    throw 'You must have mint installed to lint or format swift' unless $?.success?
    sh 'mint bootstrap'
  end
end
