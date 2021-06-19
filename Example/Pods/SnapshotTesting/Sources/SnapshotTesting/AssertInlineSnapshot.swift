import XCTest

/// Asserts that a given value matches a string literal.
///
/// Note: Empty `reference` will be replaced automatically with generated output.
///
/// Usage:
/// ```
/// _assertInlineSnapshot(matching: value, as: .dump, with: """
/// """)
/// ```
///
/// - Parameters:
///   - value: A value to compare against a reference.
///   - snapshotting: A strategy for serializing, deserializing, and comparing values.
///   - recording: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - reference: The expected output of snapshotting.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
public func _assertInlineSnapshot<Value>(
  matching value: @autoclosure () throws -> Value,
  as snapshotting: Snapshotting<Value, String>,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  with reference: String,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
  ) {

  let failure = _verifyInlineSnapshot(
    matching: try value(),
    as: snapshotting,
    record: recording,
    timeout: timeout,
    with: reference,
    file: file,
    testName: testName,
    line: line
  )
  guard let message = failure else { return }
  XCTFail(message, file: file, line: line)
}

/// Verifies that a given value matches a string literal.
///
/// Third party snapshot assert helpers can be built on top of this function. Simply invoke `verifyInlineSnapshot` with your own arguments, and then invoke `XCTFail` with the string returned if it is non-`nil`.
///
/// - Parameters:
///   - value: A value to compare against a reference.
///   - snapshotting: A strategy for serializing, deserializing, and comparing values.
///   - recording: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - reference: The expected output of snapshotting.
///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
/// - Returns: A failure message or, if the value matches, nil.
public func _verifyInlineSnapshot<Value>(
  matching value: @autoclosure () throws -> Value,
  as snapshotting: Snapshotting<Value, String>,
  record recording: Bool = false,
  timeout: TimeInterval = 5,
  with reference: String,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
  )
  -> String? {

    let recording = recording || isRecording

    do {
      let tookSnapshot = XCTestExpectation(description: "Took snapshot")
      var optionalDiffable: String?
      snapshotting.snapshot(try value()).run { b in
        optionalDiffable = b
        tookSnapshot.fulfill()
      }
      let result = XCTWaiter.wait(for: [tookSnapshot], timeout: timeout)
      switch result {
      case .completed:
        break
      case .timedOut:
        return """
          Exceeded timeout of \(timeout) seconds waiting for snapshot.

          This can happen when an asynchronously rendered view (like a web view) has not loaded. \
          Ensure that every subview of the view hierarchy has loaded to avoid timeouts, or, if a \
          timeout is unavoidable, consider setting the "timeout" parameter of "assertSnapshot" to \
          a higher value.
          """
      case .incorrectOrder, .invertedFulfillment, .interrupted:
        return "Couldn't snapshot value"
      @unknown default:
        return "Couldn't snapshot value"
      }

      let trimmingChars = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\u{FEFF}"))
      guard let diffable = optionalDiffable?.trimmingCharacters(in: trimmingChars) else {
        return "Couldn't snapshot value"
      }

      let trimmedReference = reference.trimmingCharacters(in: .whitespacesAndNewlines)

      // Always perform diff, and return early on success!
      guard let (failure, attachments) = snapshotting.diffing.diff(trimmedReference, diffable) else {
        return nil
      }

      // If that diff failed, we either record or fail.
      if recording || trimmedReference.isEmpty {
        let fileName = "\(file)"
        let sourceCodeFilePath = URL(fileURLWithPath: fileName, isDirectory: false)
        let sourceCode = try String(contentsOf: sourceCodeFilePath)
        var newRecordings = recordings

        let modifiedSource = try writeInlineSnapshot(
          &newRecordings,
          Context(
            sourceCode: sourceCode,
            diffable: diffable,
            fileName: fileName,
            lineIndex: Int(line)
          )
        ).sourceCode

        try modifiedSource
          .data(using: String.Encoding.utf8)?
          .write(to: sourceCodeFilePath)

        if newRecordings != recordings {
          recordings = newRecordings
          /// If no other recording has been made, then fail!
          return """
          No reference was found inline. Automatically recorded snapshot.

          Re-run "\(sanitizePathComponent(testName))" to test against the newly-recorded snapshot.
          """
        } else {
          /// There is already an failure in this file,
          /// and we don't want to write to the wrong place.
          return nil
        }
      }

      /// Did not successfully record, so we will fail.
      if !attachments.isEmpty {
        #if !os(Linux)
        if ProcessInfo.processInfo.environment.keys.contains("__XCODE_BUILT_PRODUCTS_DIR_PATHS") {
          XCTContext.runActivity(named: "Attached Failure Diff") { activity in
            attachments.forEach {
              activity.add($0)
            }
          }
        }
        #endif
      }

      return """
      Snapshot does not match reference.

      \(failure.trimmingCharacters(in: .whitespacesAndNewlines))
      """

    } catch {
      return error.localizedDescription
    }
}

internal typealias Recordings = [String: [FileRecording]]

internal struct Context {
  let sourceCode: String
  let diffable: String
  let fileName: String
  // First line of a file is line 1 (as with the #line macro)
  let lineIndex: Int

  func setSourceCode(_ newSourceCode: String) -> Context {
    return Context(
      sourceCode: newSourceCode,
      diffable: diffable,
      fileName: fileName,
      lineIndex: lineIndex
    )
  }
}

internal func writeInlineSnapshot(
  _ recordings: inout Recordings,
  _ context: Context
) throws -> Context {
  var sourceCodeLines = context.sourceCode
    .split(separator: "\n", omittingEmptySubsequences: false)

  let otherRecordings = recordings[context.fileName, default: []]
  let otherRecordingsAboveThisLine = otherRecordings.filter { $0.line < context.lineIndex }
  let offsetStartIndex = otherRecordingsAboveThisLine.reduce(context.lineIndex) { $0 + $1.difference }
  let functionLineIndex = offsetStartIndex - 1
  var lineCountDifference = 0

  // Convert `""` to multi-line literal
  if sourceCodeLines[functionLineIndex].hasSuffix(emptyStringLiteralWithCloseBrace) {
    // Convert:
    //    _assertInlineSnapshot(matching: value, as: .dump, with: "")
    // to:
    //    _assertInlineSnapshot(matching: value, as: .dump, with: """
    //    """)
    var functionCallLine = sourceCodeLines.remove(at: functionLineIndex)
    functionCallLine.removeLast(emptyStringLiteralWithCloseBrace.count)
    let indentText = indentation(of: functionCallLine)
    sourceCodeLines.insert(contentsOf: [
      functionCallLine + multiLineStringLiteralTerminator,
      indentText + multiLineStringLiteralTerminator + ")",
      ] as [String.SubSequence], at: functionLineIndex)
    lineCountDifference += 1
  }

  /// If they haven't got a multi-line literal by now, then just fail.
  guard sourceCodeLines[functionLineIndex].hasSuffix(multiLineStringLiteralTerminator) else {
    struct InlineError: LocalizedError {
      var errorDescription: String? {
        return """
To use inline snapshots, please convert the "with" argument to a multi-line literal.
"""
      }
    }
    throw InlineError()
  }

  /// Find the end of multi-line literal and replace contents with recording.
  if let multiLineLiteralEndIndex = sourceCodeLines[offsetStartIndex...].firstIndex(where: { $0.hasClosingMultilineStringDelimiter() }) {

    let diffableLines = context.diffable.split(separator: "\n")

    // Add #'s to the multiline string literal if needed
    let numberSigns: String
    if context.diffable.hasEscapedSpecialCharactersLiteral() {
      numberSigns = String(repeating: "#", count: context.diffable.numberOfNumberSignsNeeded())
    } else if nil != diffableLines.first(where: { $0.endsInBackslash() }) {
      // We want to avoid \ being interpreted as an escaped newline in the recorded inline snapshot
      numberSigns = "#"
    } else {
      numberSigns = ""
    }
    let multiLineStringLiteralTerminatorPre = numberSigns + multiLineStringLiteralTerminator
    let multiLineStringLiteralTerminatorPost = multiLineStringLiteralTerminator + numberSigns

    // Update opening (#...)"""
    sourceCodeLines[functionLineIndex].replaceFirstOccurrence(
      of: extendedOpeningStringDelimitersPattern,
      with: multiLineStringLiteralTerminatorPre
    )

    // Update closing """(#...)
    sourceCodeLines[multiLineLiteralEndIndex].replaceFirstOccurrence(
      of: extendedClosingStringDelimitersPattern,
      with: multiLineStringLiteralTerminatorPost
    )

    /// Convert actual value to Lines to insert
    let indentText = indentation(of: sourceCodeLines[multiLineLiteralEndIndex])
    let newDiffableLines = context.diffable
      .split(separator: "\n", omittingEmptySubsequences: false)
      .map { Substring(indentText + $0) }
    lineCountDifference += newDiffableLines.count - (multiLineLiteralEndIndex - offsetStartIndex)

    let fileRecording = FileRecording(line: context.lineIndex, difference: lineCountDifference)

    /// Insert the lines
    sourceCodeLines.replaceSubrange(offsetStartIndex..<multiLineLiteralEndIndex, with: newDiffableLines)

    recordings[context.fileName, default: []].append(fileRecording)
    return context.setSourceCode(sourceCodeLines.joined(separator: "\n"))
  }

  return context.setSourceCode(sourceCodeLines.joined(separator: "\n"))
}

internal struct FileRecording: Equatable {
  let line: Int
  let difference: Int
}

private func indentation<S: StringProtocol>(of str: S) -> String {
  var count = 0
  for char in str {
    guard char == " " else { break }
    count += 1
  }
  return String(repeating: " ", count: count)
}

fileprivate extension Substring {
  mutating func replaceFirstOccurrence(of pattern: String, with newString: String) {
    let newString = replacingOccurrences(of: pattern, with: newString, options: .regularExpression)
    self = Substring(newString)
  }

  func hasOpeningMultilineStringDelimiter() -> Bool {
    return range(of: extendedOpeningStringDelimitersPattern, options: .regularExpression) != nil
  }

  func hasClosingMultilineStringDelimiter() -> Bool {
    return range(of: extendedClosingStringDelimitersPattern, options: .regularExpression) != nil
  }

  func endsInBackslash() -> Bool {
    if let lastChar = last {
      return lastChar == Character(#"\"#)
    }
    return false
  }
}

private let emptyStringLiteralWithCloseBrace = "\"\")"
private let multiLineStringLiteralTerminator = "\"\"\""
private let extendedOpeningStringDelimitersPattern = #"#{0,}\"\"\""#
private let extendedClosingStringDelimitersPattern = ##"\"\"\"#{0,}"##

// When we modify a file, the line numbers reported by the compiler through #line are no longer
// accurate. With the FileRecording values we keep track of we modify the files so we can adjust
// line numbers.
private var recordings: Recordings = [:]
