// Created by Cal Stephens on 1/4/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Epoxy
import Lottie
import UIKit

// MARK: - AnimatedSwitchRow

final class AnimatedSwitchRow: UIView, EpoxyableView {

  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    group.install(in: self)
    group.constrainToMarginsWithHighPriorityBottom()
    backgroundColor = .systemBackground
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  struct Content: Equatable {
    var animationName: String
    var title: String
    var onTimeRange: ClosedRange<CGFloat>
    var offTimeRange: ClosedRange<CGFloat>
    var colorValueProviders: [String: [Keyframe<Color>]] = [:]
  }

  func setContent(_ content: Content, animated _: Bool) {
    self.content = content
    updateGroup()
  }

  // MARK: Private

  private enum DataID {
    case animatedSwitch
    case title
  }

  private var content: Content?
  private let group = HGroup(alignment: .fill, spacing: 24)

  private var isEnabled = false {
    didSet {
      updateGroup()
    }
  }

  private func updateGroup() {
    guard let content = content else { return }

    group.setItems {
      if let animationName = content.animationName {
        GroupItem<AnimatedSwitch>(
          dataID: DataID.animatedSwitch,
          content: content,
          make: {
            let animatedSwitch = AnimatedSwitch()
            animatedSwitch.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
              animatedSwitch.widthAnchor.constraint(equalToConstant: 80),
              animatedSwitch.heightAnchor.constraint(equalToConstant: 80),
            ])

            animatedSwitch.addTarget(self, action: #selector(self.switchWasToggled), for: .touchUpInside)
            return animatedSwitch
          },
          setContent: { context, content in
            context.constrainable.animation = .named(animationName)
            context.constrainable.contentMode = .scaleAspectFit

            context.constrainable.setProgressForState(
              fromProgress: content.offTimeRange.lowerBound,
              toProgress: content.offTimeRange.upperBound,
              forOnState: false)

            context.constrainable.setProgressForState(
              fromProgress: content.onTimeRange.lowerBound,
              toProgress: content.onTimeRange.upperBound,
              forOnState: true)

            for (keypath, color) in content.colorValueProviders {
              context.constrainable.animationView.setValueProvider(
                ColorValueProvider(color),
                keypath: AnimationKeypath(keypath: keypath))
            }
          })
      }

      GroupItem<UILabel>(
        dataID: DataID.title,
        content: isEnabled,
        make: {
          let label = UILabel()
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
        },
        setContent: { context, _ in
          context.constrainable.text = "\(content.title): \(self.isEnabled ? "On" : "Off")"
        })
    }
  }

  @objc
  private func switchWasToggled(_ sender: AnimatedSwitch) {
    isEnabled = sender.isOn
  }

}
