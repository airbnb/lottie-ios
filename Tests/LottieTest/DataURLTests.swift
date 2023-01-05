// Created by Nicholas Mata on 2/23/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Foundation
import XCTest

@testable import Lottie

// MARK: - DataURLTests

// Tests are based on implementation found here
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs
final class DataURLTests: XCTestCase {

  let red5x5 =
    "%89%50%4e%47%0d%0a%1a%0a%00%00%00%0d%49%48%44%52%00%00%00%05%00%00%00%05%08%06%00%00%00%8d%6f%26%e5%00%00%00%12%49%44%41%54%78%da%63%fc%cf%c0%00%44%a8%80%91%06%82%00%5c%65%09%fc%86%fe%00%b0%00%00%00%00%49%45%4e%44%ae%42%60%82"

  let red5x5Base64 = "iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAEklEQVR42mP8z8AARKiAkQaCAFxlCfyG/gCwAAAAAElFTkSuQmCC"

  func testValidDataURL() {
    let dataString = "data:image/png;base64,\(red5x5Base64)"

    let data = Data(dataString: dataString)
    XCTAssertNotNil(data, "Data should not be nil if valid base64 string")
    let image = UIImage(data: data!)
    XCTAssertNotNil(image, "Should be valid image")

    // Since legacy options will print nil host logs
    let legacyData = Data(dataString: dataString, options: .legacy)
    XCTAssertNotNil(legacyData, "Data should not be nil if valid base64 string")
    let legacyImage = UIImage(data: legacyData!)
    XCTAssertNotNil(legacyImage, "Should be valid image")

    XCTAssertEqual(data, legacyData)
  }

  func testValidDataURLWithoutBase64() {
    let dataString = "data:image/png,\(red5x5)"
    // Since ;base64 is missing still prints nil host warnings.
    // If we can figure out how to turn red5x5 into Data properly
    // like Data(contentsOf:) does then we can avoid the warning.
    let data = Data(dataString: dataString)
    XCTAssertNotNil(data, "Data should not be nil since format is valid data URL")

    let image = UIImage(data: data!)
    XCTAssertNotNil(image, "Should be valid image. Since missing ';base64' the data is valid just not base64 encoded")
  }

  func testInvalidDataURLWithBadBase64() {
    let dataString = "data:image/png;base64,INVALIDBASE64"

    let data = Data(dataString: dataString)
    let legacyData = Data(dataString: dataString, options: .legacy)
    XCTAssertNil(data, "Data should be nil because 'INVALIDBASE64' is not valid base64 string.")
    XCTAssertNil(legacyData, "Data should be nil because 'INVALIDBASE64' is not valid base64 string.")
  }

  func testInvalidDataURL() {
    let dataString = "ImageAssetName"

    let data = Data(dataString: dataString)
    XCTAssertNil(data, "Data should be nil as valid Data URL starts with 'data:'")
  }
}
