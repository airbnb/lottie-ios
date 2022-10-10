//
//  ParsingTests.swift
//  Lottie
//
//  Created by Marcelo Fabri on 5/5/22.
//

import Difference
import Foundation
import Lottie
import XCTest

// MARK: - ParsingTests

final class ParsingTests: XCTestCase {

  func testParsingIsTheSameForBothImplementations() throws {
    for url in Samples.sampleAnimationURLs {
      do {
        let data = try Data(contentsOf: url)
        let codableAnimation = try LottieAnimation.from(data: data, strategy: .codable)
        let dictAnimation = try LottieAnimation.from(data: data, strategy: .dictionaryBased)

        XCTAssertNoDiff(codableAnimation, dictAnimation)
      } catch {
        XCTFail("Error for \(url.lastPathComponent): \(error)")
      }
    }
  }
}

func XCTAssertNoDiff<T>(
  _ expected: @autoclosure () throws -> T,
  _ received: @autoclosure () throws -> T,
  file: StaticString = #filePath,
  line: UInt = #line) rethrows
{
  let expected = try expected()
  let received = try received()
  let diff = diff(expected, received)
  let isEqual = diff.isEmpty || diff.allSatisfy(\.isEmpty)
  XCTAssertTrue(isEqual, "Found difference for \n" + diff.joined(separator: ", "), file: file, line: line)
}
