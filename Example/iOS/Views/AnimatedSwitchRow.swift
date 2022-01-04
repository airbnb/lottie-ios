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
    var onTimeRange: (from: CGFloat, to: CGFloat)
    var offTimeRange: (from: CGFloat, to: CGFloat)

    static func == (lhs: Content, rhs: Content) -> Bool {
      lhs.animationName == rhs.animationName
        && lhs.title == rhs.title
        && lhs.onTimeRange == rhs.onTimeRange
        && lhs.offTimeRange == rhs.offTimeRange
    }
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
              fromProgress: content.offTimeRange.from,
              toProgress: content.offTimeRange.to,
              forOnState: false)

            context.constrainable.setProgressForState(
              fromProgress: content.onTimeRange.from,
              toProgress: content.onTimeRange.to,
              forOnState: true)
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
