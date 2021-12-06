namespace :lint do
  desc 'Lints swift files'
  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint lint lottie-swift Example --config script/lint/swiftlint.yml --strict'
    sh 'mint run SwiftFormat lottie-swift Example --config script/lint/airbnb.swiftformat --lint '
  end
end

namespace :format do
  desc 'Runs SwiftFormat'
  task :swift => 'bootstrap:mint' do
    sh 'mint run SwiftLint autocorrect lottie-swift Example --config script/lint/swiftlint.yml'
    sh 'mint run SwiftFormat lottie-swift Example --config script/lint/airbnb.swiftformat'
  end
end

namespace :bootstrap do
  task :mint do
    `which mint`
    throw 'You must have mint installed to lint or format swift' unless $?.success?
    sh 'mint bootstrap'
  end
end