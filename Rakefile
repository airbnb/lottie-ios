require 'json'
require 'git'

namespace :build do
  desc 'Builds all packages and executables'
  task all: ['package:all', 'example:all', 'xcframework']

  desc 'Builds the Lottie package for supported platforms'
  namespace :package do
    desc 'Builds the Lottie package for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS', 'visionOS']

    desc 'Builds the Lottie package for iOS'
    task :iOS do
      xcodebuild('build -scheme "Lottie (iOS)" -destination generic/platform=iOS -workspace Lottie.xcworkspace OTHER_SWIFT_FLAGS="-warnings-as-errors"')
    end

    desc 'Builds the Lottie package for macOS'
    task :macOS do
      xcodebuild('build -scheme "Lottie (macOS)" -destination generic/platform=macOS -workspace Lottie.xcworkspace OTHER_SWIFT_FLAGS="-warnings-as-errors"')
    end

    desc 'Builds the Lottie package for tvOS'
    task :tvOS do
      xcodebuild('build -scheme "Lottie (tvOS)" -destination generic/platform=tvOS -workspace Lottie.xcworkspace OTHER_SWIFT_FLAGS="-warnings-as-errors"')
    end

    desc 'Builds the Lottie package for visionOS'
    task :visionOS do
      ifVisionOSEnabled {
        xcodebuild('build -scheme "Lottie (visionOS)" -destination generic/platform=visionOS -workspace Lottie.xcworkspace OTHER_SWIFT_FLAGS="-warnings-as-errors"')
      }
    end
  end

  desc 'Builds the Lottie example app for supported platforms'
  namespace :example do
    desc 'Builds the Lottie example apps for all supported platforms'
    task all: ['iOS', 'macOS', 'tvOS', 'visionOS']

    desc 'Builds the iOS Lottie Example app'
    task :iOS do
      xcodebuild('build -scheme "Example (Multiplatform)" -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" -workspace Lottie.xcworkspace')
    end

    desc 'Builds the macOS Lottie Example app'
    task :macOS do
      xcodebuild('build -scheme "Example (Multiplatform)" -workspace Lottie.xcworkspace')
    end

    desc 'Builds the tvOS Lottie Example app'
    task :tvOS do
      xcodebuild('build -scheme "Example (Multiplatform)" -destination "platform=tvOS Simulator,name=Apple TV" -workspace Lottie.xcworkspace')
    end

    desc 'Builds the visionOS Lottie Example app'
    task :visionOS do
      ifVisionOSEnabled {
        xcodebuild('build -scheme "Example (Multiplatform)" -destination "platform=visionOS Simulator,name=Apple Vision Pro" -workspace Lottie.xcworkspace')
      }
    end
  end

  desc 'Builds an xcframework for all supported platforms'
  task :xcframework, [:zip_archive_name] do |_t, args|
    args.with_defaults(:zip_archive_name => 'Lottie')

    sh 'rm -rf .build/archives'

    # Build the framework for each supported platform, including simulators
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (iOS)" -destination generic/platform=iOS -archivePath ".build/archives/Lottie_iOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (iOS)" -destination "generic/platform=iOS Simulator" -archivePath ".build/archives/Lottie_iOS_Simulator" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (iOS)" -destination "generic/platform=macOS,variant=Mac Catalyst" -archivePath ".build/archives/Lottie_Mac_Catalyst" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (macOS)" -destination generic/platform=macOS -archivePath ".build/archives/Lottie_macOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (tvOS)" -destination generic/platform=tvOS -archivePath ".build/archives/Lottie_tvOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
    xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (tvOS)" -destination "generic/platform=tvOS Simulator" -archivePath ".build/archives/Lottie_tvOS_Simulator" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')

    ifVisionOSEnabled {
      xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (visionOS)" -destination generic/platform=visionOS -archivePath ".build/archives/Lottie_visionOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
      xcodebuild('archive -workspace Lottie.xcworkspace -scheme "Lottie (visionOS)" -destination "generic/platform=visionOS Simulator" -archivePath ".build/archives/Lottie_visionOS_Simulator" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES ENABLE_BITCODE=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO')
    }

    # Combine all of the platforms into a single XCFramework
    xcframeworkInvocation = [
      '-create-xcframework',
      '-archive .build/archives/Lottie_iOS.xcarchive -framework Lottie.framework',
      '-archive .build/archives/Lottie_iOS_Simulator.xcarchive -framework Lottie.framework',
      '-archive .build/archives/Lottie_Mac_Catalyst.xcarchive -framework Lottie.framework',
      '-archive .build/archives/Lottie_tvOS.xcarchive -framework Lottie.framework',
      '-archive .build/archives/Lottie_tvOS_Simulator.xcarchive -framework Lottie.framework',
      '-archive .build/archives/Lottie_macOS.xcarchive -framework Lottie.framework',
    ]

    ifVisionOSEnabled {
      xcframeworkInvocation.push('-archive .build/archives/Lottie_visionOS.xcarchive -framework Lottie.framework')
      xcframeworkInvocation.push('-archive .build/archives/Lottie_visionOS_Simulator.xcarchive -framework Lottie.framework')
    }

    xcframeworkInvocation.push('-output .build/archives/Lottie.xcframework')

    xcodebuild(xcframeworkInvocation.join(" "))

    Dir.chdir('.build/archives') do
      # Codesign the XCFramework using the "Lottie iOS" certificate, which should be installed in the keychain.
      #  - Check to make sure the certificate is installed before attemtping to codesign.
      #  - In GitHub actions CI, only jobs run by contibutors have access to repo secrets,
      #    so PR jobs from external contributors won't have access to this certificate.
      #    In that case we skip codesigning so the job doesn't fail.
      puts "Checking if signing certificate is installed..."
      `security find-certificate -c 'Lottie iOS'`
      if $?.success?
        puts "Signing certificate is installed. Code signing Lottie.xcframework."
        sh 'codesign --timestamp -v --sign "Lottie iOS" Lottie.xcframework'
      else
        puts "Signing certificate is not installed. Lottie.xcframework will not be code signed."
      end

      # Archive the XCFramework into a zip file
      # Use --symlinks to avoid "Multiple binaries share the same codesign path. This can happen if your build process copies frameworks by following symlinks." 
      # error when validating macOS apps (#1948)
      sh "zip -r --symlinks #{args[:zip_archive_name]}.xcframework.zip Lottie.xcframework"
      sh 'rm -rf Lottie.xcframework'
    end

    sh "swift package compute-checksum .build/archives/#{args[:zip_archive_name]}.xcframework.zip"
  end
end

namespace :test do
  desc 'Tests the Lottie package for iOS'
  task :package do
    sh 'rm -rf Tests/Artifacts'
    xcodebuild('test -scheme "Lottie (iOS)" -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)" -resultBundlePath Tests/Artifacts/LottieTests.xcresult')
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
      # Build the Lottie framework scheme
      sh 'carthage build --use-xcframeworks'

      # Delete Carthage's derived data to verify that the built .xcframework doesn't depend on any
      # side effects from building on this specific machine.
      # https://github.com/airbnb/lottie-ios/issues/1492
      sh 'rm -rf ~/Library/Caches/org.carthage.CarthageKit/DerivedData'

      # Build a test app that imports and uses the Lottie framework built via Carthage
      xcodebuild('build -scheme CarthageTest  -destination "platform=iOS Simulator,name=iPhone SE (3rd generation)"')
      xcodebuild('build -scheme CarthageTest -destination generic/platform=macOS')
      xcodebuild('build -scheme CarthageTest -destination "platform=tvOS Simulator,name=Apple TV"')
      xcodebuild('build -scheme CarthageTest -destination "platform=visionOS Simulator,name=Apple Vision Pro"')
    end
  end

  desc 'Tests Swift Package Manager support'
  task :spm do
    Dir.chdir('script/test-spm') do
      # Build for iOS, macOS, and tvOS using the targets defined in Package.swift
      xcodebuild('build -scheme "Lottie" -destination generic/platform=iOS')
      xcodebuild('build -scheme "Lottie" -destination generic/platform=macOS')
      xcodebuild('build -scheme "Lottie" -destination generic/platform=tvOS')

      ifVisionOSEnabled {
        xcodebuild('build -scheme "Lottie" -destination generic/platform=visionOS')
      }
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

  desc 'Lints the EmbeddedLibraries directory'
  task :EmbeddedLibraries do
    sh 'echo "Linting /Sources/Private/EmbeddedLibraries (should not contain any public symbols)"'
    sh '! grep -r "public" Sources/Private/EmbeddedLibraries --include \*.swift'
  end
end

namespace :format do
  desc 'Formats swift files'
  task :swift do
    sh 'swift package --allow-writing-to-package-directory format'
  end
end

namespace :emerge do
  desc 'Uploads to emerge'
  task :upload do
    xcodebuild('build -scheme "SizeTest" -destination generic/platform=iOS -project script/SizeTest/SizeTest.xcodeproj -archivePath test.xcarchive archive CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO')
    sh "zip -r -qq test.zip test.xcarchive"

    g = Git.open('.')

    upload_data = {
      repoName: 'airbnb/lottie-ios',
      filename: 'test.zip'
    }
    if ENV["PR_NUMBER"] != "" && ENV["PR_NUMBER"] != "false"
      upload_data[:sha] = g.log[0].parents[1].sha
      upload_data[:baseSha] = g.log[0].parent.sha
      upload_data[:prNumber] = ENV["PR_NUMBER"]
      upload_data[:buildType] = 'pull_request'
    else
      upload_data[:sha] = g.log[0].sha
      upload_data[:buildType] = 'master'
    end
    api_token = ENV['EMERGE_API_TOKEN']
    if api_token.nil? || api_token.empty?
      puts "Skipping Emerge upload because API token was not provided."
      next
    end
    api_token_header = "X-API-Token: #{api_token}"
    url = "https://api.emergetools.com/upload"
    cmd = "curl --fail -s --request POST --url #{url} --header 'Accept: application/json' --header 'Content-Type: application/json' --header '#{api_token_header}' --data '#{upload_data.to_json}'"
    upload_json = %x(#{cmd})
    upload_url = JSON.parse(upload_json)['uploadURL']
    %x(curl --fail -s -H 'Content-Type: application/zip' -T test.zip '#{upload_url}')
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

# Runs the given code block, unless `SKIP_VISION_OS=true`.
# TODO: Remove this once Lottie only supports Xcode 15.2+.
def ifVisionOSEnabled
  if ENV["SKIP_VISION_OS"] == "true"
    puts "Skipping visionOS build"
  else
    yield
  end
end