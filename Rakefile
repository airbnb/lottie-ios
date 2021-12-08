namespace :build do
  desc 'Builds the Lottie package for iOS'
  task :package do
    sh 'xcodebuild build -scheme Lottie -destination generic/platform=iOS'
  end

  desc 'Builds the iOS Lottie Example app'
  task :example do
    sh 'xcodebuild build -scheme "Example (iOS)" -destination "platform=iOS Simulator,name=iPhone 8"'
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