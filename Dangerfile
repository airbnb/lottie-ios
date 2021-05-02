
# Warn when PR size is large
bigPRThreshold = 20

if git.modified_files.count + git.added_files.count > bigPRThreshold
  warn('Big PR : Pull Request size seems relatively large. If Pull Request contains multiple changes, split each into separate PR will helps faster, easier review.')
end


# swiftformat.binary_path = "ios/Pods/SwiftFormat/CommandLineTool/swiftformat"
# swiftformat.exclude = %w(ios/Pods/** Tokopedia/ThirdParty/** ios/ThirdParty/**)

# additional_args = "--config ios/.swiftformat"

# # check if commit have param 'clear cache'
# if git.commits.any? { |c| c.message =~ /\[clear cache\]/ }
#   message "SwiftFormat run with args --cache clear"
#   additional_args = "#{additional_args} --cache clear"
# end

# swiftformat.additional_args = additional_args

swiftformat.check_format(fail_on_error: true)

# swiftlint.binary_path = 'ios/Pods/SwiftLint/swiftlint'
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files fail_on_error: true