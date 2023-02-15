namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all', 'xcframework']

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

  desc 'Builds an xcframework for all supported platforms'
  task :xcframework do
    sh 'rm -rf .build/archives'
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (iOS)" -destination generic/platform=iOS -archivePath ".build/archives/Lottie_iOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (iOS)" -destination "generic/platform=iOS Simulator" -archivePath ".build/archives/Lottie_iOS_Simulator" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (iOS)" -destination "generic/platform=macOS,variant=Mac Catalyst" -archivePath ".build/archives/Lottie_Mac_Catalyst" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (macOS)" -destination generic/platform=macOS -archivePath ".build/archives/Lottie_macOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (tvOS)" -destination generic/platform=tvOS -archivePath ".build/archives/Lottie_tvOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (tvOS)" -destination "generic/platform=tvOS Simulator" -archivePath ".build/archives/Lottie_tvOS_Simulator" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES')
    xcodebuild(
      [
        '-create-xcframework',
        '-framework .build/archives/Lottie_iOS.xcarchive/Products/Library/Frameworks/Lottie.framework',
        '-framework .build/archives/Lottie_iOS_Simulator.xcarchive/Products/Library/Frameworks/Lottie.framework',
        '-framework .build/archives/Lottie_Mac_Catalyst.xcarchive/Products/Library/Frameworks/Lottie.framework',
        '-framework .build/archives/Lottie_macOS.xcarchive/Products/Library/Frameworks/Lottie.framework',
        '-framework .build/archives/Lottie_tvOS.xcarchive/Products/Library/Frameworks/Lottie.framework',
        '-framework .build/archives/Lottie_tvOS_Simulator.xcarchive/Products/Library/Frameworks/Lottie.framework',
        '-output .build/archives/Lottie.xcframework'
      ].join(" "))
    Dir.chdir('.build/archives') do
      # Use --symlinks to avoid "Multiple binaries share the same codesign path. This can happen if your build process copies frameworks by following symlinks." 
      # error when validating macOS apps (#1948)
      sh 'zip -r --symlinks Lottie.xcframework.zip Lottie.xcframework'
      sh 'rm -rf Lottie.xcframework'
    end
    sh 'swift package compute-checksum .build/archives/Lottie.xcframework.zip'
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
    sh 'mint run ChargePoint/xcparse@2.3.1 xcparse attachments Tests/Artifacts/LottieTests.xcresult Tests/Artifacts/TestAttachments'
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
    sh 'swift package --allow-writing-to-package-directory format --lint'
  end

  desc 'Lints the CocoaPods podspec'
  task :podspec do
    sh 'pod lib lint lottie-ios.podspec'
  end
end

namespace :format do
  desc 'Formats swift files'
  task :swift do
    sh 'swift package --allow-writing-to-package-directory format'
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
