import Foundation

extension String {

  /// Checks whether the string has escaped special character literals or not.
  ///
  /// This method won't detect an unescaped special character.
  /// For example, this method will return true for "\\n" or #"\n"#, but false for "\n"
  ///
  /// The following are the special character literals that this methods looks for:
  /// The escaped special characters \0 (null character), \\ (backslash),
  /// \t (horizontal tab), \n (line feed), \r (carriage return),
  /// \" (double quotation mark) and \' (single quotation mark),
  /// An arbitrary Unicode scalar value, written as \u{n},
  /// where n is a 1–8 digit hexadecimal number (Unicode is discussed in Unicode below)
  /// The character sequence "#
  ///
  /// - Returns: True if the string has any special character literals, false otherwise.
  func hasEscapedSpecialCharactersLiteral() -> Bool {
    let multilineLiteralAndNumberSign = ##"""
    """#
    """##
    let patterns = [
      // Matches \u{n} where n is a 1–8 digit hexadecimal number
      try? NSRegularExpression(pattern: #"\\u\{[a-fA-f0-9]{1,8}\}"#, options: .init()),
      try? NSRegularExpression(pattern: #"\0"#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: #"\\"#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: #"\t"#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: #"\n"#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: #"\r"#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: #"\""#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: #"\'"#, options: .ignoreMetacharacters),
      try? NSRegularExpression(pattern: multilineLiteralAndNumberSign, options: .ignoreMetacharacters),
    ]
    let matches = patterns.compactMap { $0?.firstMatch(in: self, options: .init(), range: NSRange.init(location: 0, length: self.count)) }
    return matches.count > 0
  }


  /// This method calculates how many number signs (#) we need to add around a string
  /// literal to properly escape its content.
  ///
  /// Multiple # are needed when the literal contains "#, "##, "### ...
  ///
  /// - Returns: The number of "number signs(#)" needed around a string literal.
  ///            When there is no "#, ... return 1
  func numberOfNumberSignsNeeded() -> Int {
    let pattern = try! NSRegularExpression(pattern: ##""#{1,}"##, options: .init())

    let matches = pattern.matches(in: self, options: .init(), range: NSRange.init(location: 0, length: self.count))

    // If we have "## then the length of the match is 3,
    // which is also the number of "number signs (#)" we need to add
    // before and after the string literal
    return matches.map { $0.range.length }.max() ?? 1
  }
}
