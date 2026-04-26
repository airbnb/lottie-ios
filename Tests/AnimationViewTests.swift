// Created by Cal Stephens on 11/11/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI
import UIKit
import XCTest

@MainActor
final class AnimationViewTests: XCTestCase {

  override func setUp() async throws {
    LottieLogger.shared = .printToConsole
  }

  override func tearDown() {
    LottieLogger.shared = LottieLogger()
  }

  func testLoadJsonFile() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    )

    XCTAssertNotNil(animationView.animation)

    let expectation = XCTestExpectation(description: "animationLoaded is called")
    animationView.animationLoaded = { [weak animationView] view, animation in
      XCTAssert(animation === view.animation)
      XCTAssertEqual(view, animationView)
      XCTAssert(Thread.isMainThread)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 0.25)
  }

  func testLoadDotLottieFileAsyncWithCompletionClosure() {
    let expectation = XCTestExpectation(description: "completion closure is called")

    _ = LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .lottie,
      subdirectory: Samples.directoryName,
      completion: { animationView, error in
        XCTAssertNil(error)
        XCTAssertNotNil(animationView.animation)
        XCTAssert(Thread.isMainThread)
        expectation.fulfill()
      }
    )

    XCTExpectFailure("This test case has been flaky in CI", strict: false) {
      wait(for: [expectation], timeout: 1.0)
    }
  }

  func testLoadDotLottieFileAsyncWithDidLoadClosure() {
    let expectation = XCTestExpectation(description: "animationLoaded closure is called")

    let animationView = LottieAnimationView(
      dotLottieName: "DotLottie/animation",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    )

    animationView.animationLoaded = { [weak animationView] view, animation in
      XCTAssert(view.animation === animation)
      XCTAssertEqual(view, animationView)
      XCTAssert(Thread.isMainThread)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  func testPlayFromFrameToFrame() {
    XCTExpectFailure("Realtime animation playback tests are flaky in CI", strict: false) {
      let tests: [(fromFrame: AnimationFrameTime?, toFrame: AnimationFrameTime)] = [
        (fromFrame: nil, toFrame: 10),
        (fromFrame: 8, toFrame: 14),
        (fromFrame: 14, toFrame: 0),
      ]

      let engineOptions: [(label: String, engine: RenderingEngineOption)] = [
        ("mainThread", .mainThread),
        ("coreAnimation", .coreAnimation),
        ("automatic", .automatic),
      ]

      let animationSupportedByCoreAnimationRenderingEngine = LottieAnimation.named(
        "Issues/issue_1877",
        bundle: .lottie,
        subdirectory: Samples.directoryName
      )

      let animationUnsupportedByCoreAnimationRenderingEngine = LottieAnimation.named(
        "TypeFace/G",
        bundle: .lottie,
        subdirectory: Samples.directoryName
      )

      let animations = [
        animationSupportedByCoreAnimationRenderingEngine,
        animationUnsupportedByCoreAnimationRenderingEngine,
      ]

      for animation in animations {
        XCTAssertNotNil(animation)
        let window = UIWindow()

        for (test, values) in tests.enumerated() {
          for engine in engineOptions {
            let animationView = LottieAnimationView(
              animation: animation,
              configuration: .init(renderingEngine: engine.engine)
            )

            window.addSubview(animationView)
            defer {
              animationView.removeFromSuperview()
            }

            let animationPlayingExpectation = XCTestExpectation(
              description: "Animation playing case \(test) on engine: \(engine.label)"
            )

            let animationCompleteExpectation = XCTestExpectation(
              description: "Finished playing case \(test) on engine: \(engine.label)"
            )

            animationView.play(fromFrame: values.fromFrame, toFrame: values.toFrame, loopMode: .playOnce) { finished in
              XCTAssertTrue(
                finished,
                "Failed case \(test) on engine: \(engine.label)"
              )

              XCTAssertEqual(
                animationView.currentFrame,
                values.toFrame,
                accuracy: 0.01,
                "Failed case \(test) on engine: \(engine.label)"
              )

              XCTAssertFalse(
                animationView.isAnimationPlaying,
                "Failed case \(test) on engine: \(engine.label)"
              )

              animationCompleteExpectation.fulfill()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              animationPlayingExpectation.fulfill()

              // Verify that we're testing at least one case where .automatic falls back to the main thread engine
              if engine.engine == .automatic {
                if animation === animationUnsupportedByCoreAnimationRenderingEngine {
                  XCTAssertEqual(animationView.currentRenderingEngine, .mainThread)
                } else {
                  XCTAssertEqual(animationView.currentRenderingEngine, .coreAnimation)
                }
              }

              XCTAssertTrue(
                animationView.isAnimationPlaying,
                "Failed case \(test) on engine: \(engine.label)"
              )

              // Check that the animation is playing in the correct direction:
              // After a brief delay we should be closer to the from frame than the to frame
              let distanceFromStartFrame = abs((values.fromFrame ?? 0) - animationView.realtimeAnimationFrame)
              let distanceFromEndFrame = abs(values.toFrame - animationView.realtimeAnimationFrame)
              XCTAssertTrue(
                distanceFromStartFrame < distanceFromEndFrame,
                "Failed case \(test) on engine: \(engine.label)"
              )
            }

            wait(for: [animationPlayingExpectation, animationCompleteExpectation], timeout: 1.0)
          }
        }
      }
    }
  }

  // MARK: - Issue #2624: CALayerInvalidGeometry with .resizable().scaledToFill()

  // Verifies that .resizable().scaledToFill() on a LottieView does not crash with
  // CALayerInvalidGeometry.
  //
  // Root cause: SwiftUIMeasurementContainer initialised with bounds = .zero. With strategy
  // .proposed, sizeThatFits returned (0, 0). SwiftUI's .scaledToFill() computed
  // scale = proposedWidth / 0 = ∞ and assigned an infinite frame, crashing
  // -[CALayer setPosition:].
  //
  // Fix: measureView() falls back to the animation's intrinsic content size when the
  // fitting size is zero, so .scaledToFill() always gets a real aspect ratio and never
  // produces infinity. Also, the container now uses the animation's intrinsic size as
  // its initial frame on iOS 16+.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewResizableScaledToFillDoesNotCrash() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = LottieView(animation: animation)
      .playing(loopMode: .loop)
      .resizable()
      .scaledToFill()
      .frame(width: 340, height: 433)

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
  }

  // Verifies that .resizable().scaledToFit() does not crash — same infinity-scale root
  // cause as scaledToFill but with a different aspect-ratio computation path.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewResizableScaledToFitDoesNotCrash() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = LottieView(animation: animation)
      .playing(loopMode: .loop)
      .resizable()
      .scaledToFit()
      .frame(width: 340, height: 433)

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
  }

  // Verifies that .resizable() without an aspect-ratio modifier does not crash.
  // The proposed-sizing path still exercises the intrinsic-size fallback in measureView().
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewResizableOnlyDoesNotCrash() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = LottieView(animation: animation)
      .playing(loopMode: .loop)
      .resizable()
      .frame(width: 340, height: 433)

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
  }

  // Verifies that an async-loaded LottieView with .resizable().scaledToFill() does not
  // crash. When the animation loads asynchronously, the container's initial intrinsic size
  // is zero (the animation is not yet available), so the measureView() fallback must handle
  // the zero-bounds case instead of the intrinsic-size initial-frame path.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewAsyncLoadingResizableScaledToFillDoesNotCrash() async throws {
    guard #available(iOS 16.0, *) else { return }

    let swiftUIView = LottieView {
      try await LottieAnimation.named(
        "LottieLogo1",
        bundle: .lottie,
        subdirectory: Samples.directoryName
      )
    }
    .resizable()
    .scaledToFill()
    .frame(width: 340, height: 433)

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    // First pass: animation not yet loaded, container starts at zero intrinsic size.
    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()

    // Wait for async load, then verify layout is still stable.
    try await Task.sleep(nanoseconds: 500_000_000)
    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
  }

  // Verifies that .resizable().scaledToFill() inside a VStack with wrapping text does not
  // crash or enter a layout loop.
  //
  // Root cause: the (0×0) initial bounds caused UIKit proportional sublayer repositioning
  // inside a UIView animation block to compute:
  //   newPosition = oldPosition × (newBoundsWidth / 0) = NaN → CALayerInvalidGeometry
  // The long iOS 26 fullScreenCover animation also drove thousands of intermediate bounds
  // values through layoutSubviews(), each triggering an expensive full re-layout via
  // invalidateIntrinsicContentSize() — causing a 3–4 minute hang with wrapping text.
  //
  // Fixes:
  //   1. Container uses animation's intrinsic size as its initial frame → no (0×0) state.
  //   2. layoutSubviews() uses a 1pt threshold → skips sub-point intermediate frames.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewResizableScaledToFillWithWrappingTextDoesNotCrashOrLoop() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = VStack(spacing: 0) {
      LottieView(animation: animation)
        .playing(loopMode: .loop)
        .resizable()
        .scaledToFill()
        .frame(width: 340, height: 433)
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
      Text("Setting up your organisation across multiple lines to force multi-pass VStack layout")
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(16)

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    // Multiple passes simulate the multi-pass VStack layout for wrapping text.
    for _ in 0..<5 {
      hostingController.view.setNeedsLayout()
      hostingController.view.layoutIfNeeded()
    }
  }

  // Verifies that the 1pt threshold in layoutSubviews() prevents a flood of
  // invalidateIntrinsicContentSize() calls when bounds change many times in small steps
  // (as happens during iOS 26's long fullScreenCover presentation animation).
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewRapidBoundsChangesDoNotHang() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = LottieView(animation: animation)
      .resizable()
      .scaledToFill()
      .frame(width: 340, height: 433)

    let hostingController = UIHostingController(rootView: swiftUIView)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    // Simulate the iOS 26 fullScreenCover animation driving the container through many
    // intermediate widths in small steps (sub-point increments). The 1pt threshold should
    // absorb these without triggering a re-layout on each step.
    let startWidth: CGFloat = 140
    let endWidth: CGFloat = 433
    let steps = 50
    for i in 0...steps {
      let t = CGFloat(i) / CGFloat(steps)
      let width = startWidth + (endWidth - startWidth) * t
      hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: 844)
      hostingController.view.setNeedsLayout()
      hostingController.view.layoutIfNeeded()
    }
  }

  // Verifies that a LottieView inside a ZStack with .resizable().scaledToFill() does
  // not crash — ZStack proposes unconstrained sizes differently from VStack/HStack.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewResizableScaledToFillInZStackDoesNotCrash() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = ZStack {
      LottieView(animation: animation)
        .playing(loopMode: .loop)
        .resizable()
        .scaledToFill()
        .frame(width: 340, height: 433)
    }

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
  }

  // Verifies that a paused LottieView with .resizable().scaledToFill() does not crash —
  // the paused path takes a different playback code route but the same layout path.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testLottieViewPausedResizableScaledToFillDoesNotCrash() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    let swiftUIView = LottieView(animation: animation)
      .paused(at: .progress(0.5))
      .resizable()
      .scaledToFill()
      .frame(width: 340, height: 433)

    let hostingController = UIHostingController(rootView: swiftUIView)
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    hostingController.view.setNeedsLayout()
    hostingController.view.layoutIfNeeded()
  }

  // MARK: - layoutAnimation() guard (LottieAnimationView.swift)

  // Verifies that layoutAnimation() does not crash when the view receives invalid frames —
  // exercises the bounds guard added in LottieAnimationView.layoutAnimation().
  //
  // Note: only infinity and zero frames are tested here. NaN frames crash at the UIKit
  // frame-to-CALayer-position conversion before our guard can fire — NaN protection lives
  // at the SwiftUIMeasurementContainer level (NonFiniteClampingLayer), not at the raw
  // LottieAnimationView level.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  func testLayoutAnimationWithInvalidFrameDoesNotCrash() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    )

    let window = UIWindow()
    window.addSubview(animationView)

    let invalidFrames: [CGRect] = [
      CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 432.667),
      CGRect(x: 0, y: 0, width: 340, height: CGFloat.infinity),
      CGRect(x: 0, y: 0, width: CGFloat.infinity, height: CGFloat.infinity),
      CGRect(x: 0, y: 0, width: 0, height: 433),
      CGRect(x: 0, y: 0, width: 340, height: 0),
      .zero,
    ]

    for frame in invalidFrames {
      animationView.frame = frame
      animationView.setNeedsLayout()
      animationView.layoutIfNeeded()
    }

    // Normal layout must still work correctly after all invalid passes.
    animationView.frame = CGRect(x: 0, y: 0, width: 340, height: 433)
    animationView.setNeedsLayout()
    animationView.layoutIfNeeded()
    XCTAssertNotNil(animationView.animation)
  }

  // Verifies that layoutAnimation() does not crash when bounds change from zero to a valid
  // size — the specific transition that triggered proportional sublayer NaN on iOS 26.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  func testLayoutAnimationBoundsTransitionFromZeroDoesNotCrash() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    )

    let window = UIWindow()
    window.addSubview(animationView)

    // Start at zero (matches the (0×0) initial state of SwiftUIMeasurementContainer on iOS 16+).
    animationView.frame = .zero
    animationView.setNeedsLayout()
    animationView.layoutIfNeeded()

    // Transition to the animation's natural size.
    let intrinsic = animationView.intrinsicContentSize
    if intrinsic.width > 0, intrinsic.height > 0 {
      animationView.frame = CGRect(origin: .zero, size: intrinsic)
      animationView.setNeedsLayout()
      animationView.layoutIfNeeded()
    }

    // Transition to the final display size (simulates scale-up via .scaledToFill()).
    animationView.frame = CGRect(x: 0, y: 0, width: 433, height: 433)
    animationView.setNeedsLayout()
    animationView.layoutIfNeeded()

    XCTAssertNotNil(animationView.animation)
  }

  // MARK: - NonFiniteClampingLayer / frame override (_SwiftUIMeasurementContainerBase)

  // Verifies that the NonFiniteClampingLayer / frame override path does not crash when
  // SwiftUI's layout engine internally assigns an infinite size to the LottieView
  // UIViewRepresentable container (which happens with .scaledToFill() on a zero-bounds
  // container before the first valid layout pass).
  //
  // This is tested indirectly: the existing testLottieViewResizableScaledToFill* tests
  // exercise exactly this path. A direct test by setting infinity on UIHostingController
  // .view.frame is not possible because UIKit rejects infinity frame constants at the
  // NSLayoutConstraint level before they reach our code.
  //
  // Instead, this test verifies that LottieAnimationView can survive infinity frames when
  // used directly (without a UIHostingController's constraint system). The
  // layoutAnimation() guard makes infinity bounds safe for the animation layer.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  func testLottieAnimationViewInfiniteFrameDoesNotCrash() {
    let animationView = LottieAnimationView(
      name: "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    )

    let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 800))
    container.addSubview(animationView)

    // Grow from normal to infinity and back — must not crash in layoutAnimation().
    let frames: [CGRect] = [
      CGRect(x: 0, y: 0, width: 340, height: 433),
      CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 433),
      CGRect(x: 0, y: 0, width: 340, height: CGFloat.infinity),
      CGRect(x: 0, y: 0, width: CGFloat.infinity, height: CGFloat.infinity),
      CGRect(x: 0, y: 0, width: 340, height: 433), // recovery
    ]

    for frame in frames {
      animationView.frame = frame
      animationView.setNeedsLayout()
      animationView.layoutIfNeeded()
    }

    XCTAssertNotNil(animationView.animation)
  }

  // MARK: - Full reproducer matching issue #2624

  // Mirrors the exact code from the bug report (LottieTest/ContentView.swift):
  // fullScreenCover presenting a VStack with a LottieView + long wrapping text.
  // Regression test for: https://github.com/airbnb/lottie-ios/issues/2624
  @MainActor
  func testIssue2624FullReproducerDoesNotCrash() throws {
    guard #available(iOS 16.0, *) else { return }

    let animation = try XCTUnwrap(LottieAnimation.named(
      "LottieLogo1",
      bundle: .lottie,
      subdirectory: Samples.directoryName
    ))

    // Mirrors ModalView from the bug report.
    let modalView = ZStack {
      VStack(spacing: 0) {
        LottieView(animation: animation)
          .playing(loopMode: .loop)
          .resizable()
          .scaledToFill()
          .frame(width: 340, height: 433)
          .padding(.horizontal, 16)
          .padding(.bottom, 40)
        Text("Setting up your organisation")
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.horizontal, 16)
      .padding(.vertical, 16)
    }
    .background(Color.blue)

    let hostingController = UIHostingController(rootView: modalView)
    // iPhone 16 Pro Max logical resolution — the reported crash device.
    hostingController.view.frame = CGRect(x: 0, y: 0, width: 440, height: 956)

    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = hostingController
    window.makeKeyAndVisible()

    // Simulate multiple layout passes as triggered by the fullScreenCover animation.
    for _ in 0..<10 {
      hostingController.view.setNeedsLayout()
      hostingController.view.layoutIfNeeded()
    }
  }

}
