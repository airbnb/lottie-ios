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
      xcodebuild('build -scheme CarthageTest-macOS')
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
  task :swift do
    formatTool('format --lint')
  end

  desc 'Lints the CocoaPods podspec'
  task :podspec do
    sh 'pod lib lint lottie-ios.podspec'
  end
end

namespace :format do
  desc 'Formats swift files'
  task :swift do
    formatTool('format')
  end
end

def xcodebuild(command)
  # Check if the mint tool is installed -- if so, pipe the xcodebuild output through xcbeautify
  `which mint`

  if $?.success?
    sh "set -o pipefail && xcodebuild #{command} | mint run thii/xcbeautify@0.10.2"
  else
    sh "xcodebuild #{command}"
  end
end

def formatTool(command)
  # As of Xcode 13.4 / Xcode 14 beta 4, including airbnb/swift as a dependency
  # causes Xcode to spin indefinitely at 100% CPU (due to the remote binary dependencies
  # used by that package). As a workaround, we can specifically add that dependency
  # to our Package.swift file when linting / formatting and remove it afterwards.
  packageDefinition = File.read('Package.swift')
  packageDefinitionWithFormatDependency = packageDefinition +
  <<~EOC
  
  #if swift(>=5.6)
  // Add the Airbnb Swift formatting plugin if possible
  package.dependencies.append(
    .package(
      url: "https://github.com/airbnb/swift",
      // Since we don't have a Package.resolved for this, we need to reference a specific commit
      // so changes to the style guide don't cause this repo's checks to start failing.
      .revision("cec29280c35dd6eccba415fa3bfc24c819eae887")))
  #endif
  EOC

  # Add the format tool dependency to our Package.swift
  File.write('Package.swift', packageDefinitionWithFormatDependency)

  exitCode = 0

  # Run the given command
  begin
    sh "swift package --allow-writing-to-package-directory #{command}"
  rescue
    exitCode = $?.exitstatus
  ensure
    # Revert the changes to Package.swift
    File.write('Package.swift', packageDefinition)
    File.delete('Package.resolved')
  end

  exit exitCode
end