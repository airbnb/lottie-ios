//
//  FetchBreadcrumbTrialManagerTests.swift
//  LottieTests
//
//  Created by Omar Masri on 5/17/24.
//

import XCTest
@testable import Lottie

final class FetchBreadcrumbTrialManagerTests: XCTestCase {

    typealias SUT = FetchBreadcrumbTrialManager

    private var sut: SUT!
    private var trialLeaver: FetchBreadcrumbTrialLeaverMock!

    override func setUp() {
        super.setUp()

        sut = .init()
        trialLeaver = FetchBreadcrumbTrialLeaverMock()
    }

    override func tearDown() {
        sut = nil
        trialLeaver = nil
        super.tearDown()
    }

    func test_dropBreadcrumb() {
        sut.configure(with: trialLeaver)

        sut.dropBreadcrumb(in: "some-entity", at: "some-point", with: ["value"])

        XCTAssertEqual(trialLeaver._leaveTraceLastInvocation?.entity, "some-entity")
        XCTAssertEqual(trialLeaver._leaveTraceLastInvocation?.point, "some-point")
        XCTAssertEqual(trialLeaver._leaveTraceLastInvocation?.value as? [String], ["value"])
    }

    func test_updateManagerConfig() {
        sut.configure(with: trialLeaver)
        sut.dropBreadcrumb(in: "some-entity", at: "some-point", with: ["value"])

        XCTAssertEqual(trialLeaver._leaveTraceInvocationCount, 1)

        let updatedTrialLeaver = FetchBreadcrumbTrialLeaverMock()
        sut.configure(with: updatedTrialLeaver)

        XCTAssertEqual(updatedTrialLeaver._leaveTraceInvocationCount, 0)

        sut.dropBreadcrumb(in: "some-entity", at: "some-point", with: ["value"])
        XCTAssertEqual(updatedTrialLeaver._leaveTraceInvocationCount, 1)
    }
}

fileprivate final class FetchBreadcrumbTrialLeaverMock: FetchBreadcrumbTrialLeaver {

    var _leaveTraceLastInvocation: (entity: String, point: String, value: Any?)?
    var _leaveTraceInvocationCount = 0

    func leaveTrace(in entity: String, at point: String, with value: Any?) {
        _leaveTraceInvocationCount += 1
        _leaveTraceLastInvocation = (entity, point, value)
    }
}
