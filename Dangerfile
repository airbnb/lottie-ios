
# Warn when PR size is large
bigPRThreshold = 20

if git.modified_files.count + git.added_files.count > bigPRThreshold
  warn('Big PR : Pull Request size seems relatively large. If Pull Request contains multiple changes, split each into separate PR will helps faster, easier review.')
end


swiftformat.binary_path = "cli_tools/swiftformat"
additional_args = "--config .swiftformat"
swiftformat.additional_args = additional_args

swiftformat.check_format(fail_on_error: true)

swiftlint.binary_path = 'cli_tools/swiftlint'
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files fail_on_error: true