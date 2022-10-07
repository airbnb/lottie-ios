//
//  AnimatedButton.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
import UIKit
/// An interactive button that plays an animation when pressed.
open class AnimatedButton: AnimatedControl {

  // MARK: Lifecycle

  public override init(
    animation: LottieAnimation,
    configuration: LottieConfiguration = .shared)
  {
    super.init(animation: animation, configuration: configuration)
    isAccessibilityElement = true
  }

  public override init() {
    super.init()
    isAccessibilityElement = true
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    isAccessibilityElement = true
  }

  // MARK: Open

  open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let _ = super.beginTracking(touch, with: event)
    let touchEvent = UIControl.Event.touchDown
    if let playrange = rangesForEvents[touchEvent.rawValue] {
      animationView.play(fromProgress: playrange.from, toProgress: playrange.to, loopMode: LottieLoopMode.playOnce)
    }
    return true
  }

  open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    let touchEvent: UIControl.Event
    if let touch = touch, bounds.contains(touch.location(in: self)) {
      touchEvent = UIControl.Event.touchUpInside
    } else {
      touchEvent = UIControl.Event.touchUpOutside
    }

    if let playrange = rangesForEvents[touchEvent.rawValue] {
      animationView.play(fromProgress: playrange.from, toProgress: playrange.to, loopMode: LottieLoopMode.playOnce)
    }
  }

  // MARK: Public

  public override var accessibilityTraits: UIAccessibilityTraits {
    set { super.accessibilityTraits = newValue }
    get { super.accessibilityTraits.union(.button) }
  }

  /// Sets the play range for the given UIControlEvent.
  public func setPlayRange(fromProgress: AnimationProgressTime, toProgress: AnimationProgressTime, event: UIControl.Event) {
    rangesForEvents[event.rawValue] = (from: fromProgress, to: toProgress)
  }

  /// Sets the play range for the given UIControlEvent.
  public func setPlayRange(fromMarker fromName: String, toMarker toName: String, event: UIControl.Event) {
    if
      let start = animationView.progressTime(forMarker: fromName),
      let end = animationView.progressTime(forMarker: toName)
    {
      rangesForEvents[event.rawValue] = (from: start, to: end)
    }
  }

  // MARK: Private

  private var rangesForEvents: [UInt : (from: CGFloat, to: CGFloat)] =
    [UIControl.Event.touchUpInside.rawValue : (from: 0, to: 1)]
}
#endif
