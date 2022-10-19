//
//  AnimationCacheProviderTests.swift
//  LottieTests
//
//  Created by Marcelo Fabri on 10/18/22.
//

import XCTest

@testable import Lottie

final class AnimationCacheProviderTests: XCTestCase {

  func testCaches() throws {
    let cache = DefaultAnimationCache()
    let animation1 = try XCTUnwrap(Samples.animation(named: "Boat_Loader"))
    let animation2 = try XCTUnwrap(Samples.animation(named: "TwitterHeart"))

    XCTAssertNil(cache.animation(forKey: "animation1"))
    cache.setAnimation(animation1, forKey: "animation1")
    XCTAssertNoDiff(cache.animation(forKey: "animation1"), animation1)

    XCTAssertNil(cache.animation(forKey: "animation2"))
    cache.setAnimation(animation2, forKey: "animation2")
    XCTAssertNoDiff(cache.animation(forKey: "animation2"), animation2)
    XCTAssertNoDiff(cache.animation(forKey: "animation1"), animation1)
  }

  func testClearCache() throws {
    let cache = DefaultAnimationCache()
    let animation = try XCTUnwrap(Samples.animation(named: "Boat_Loader"))

    XCTAssertNil(cache.animation(forKey: "animation"))
    cache.setAnimation(animation, forKey: "animation")
    XCTAssertNotNil(cache.animation(forKey: "animation"))

    cache.clearCache()
    XCTAssertNil(cache.animation(forKey: "animation"))
  }
}
