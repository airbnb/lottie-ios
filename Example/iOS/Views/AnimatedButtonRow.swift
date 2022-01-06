// Created by Cal Stephens on 1/4/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import Epoxy
import Lottie
import UIKit

// MARK: - AnimatedButtonRow

final class AnimatedButtonRow: UIView, EpoxyableView {

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
    var playRanges: [PlayRange]

    struct PlayRange: Equatable {
      let fromMarker: String
      let toMarker: String
      let event: UIControl.Event
    }
  }

  func setContent(_ content: Content, animated _: Bool) {
    self.content = content
    updateGroup()
  }

  // MARK: Private

  private enum DataID {
    case animatedButton
    case title
  }

  private var content: Content?
  private let group = HGroup(alignment: .fill, spacing: 24)

  private func updateGroup() {
    guard let content = content else { return }

    group.setItems {
      if let animationName = content.animationName {
        GroupItem<AnimatedButton>(
          dataID: DataID.animatedButton,
          content: content,
          make: {
            let animatedButton = AnimatedButton()
            animatedButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
              animatedButton.widthAnchor.constraint(equalToConstant: 80),
              animatedButton.heightAnchor.constraint(equalToConstant: 80),
            ])

            return animatedButton
          },
          setContent: { context, content in
            context.constrainable.animation = .named(animationName)
            context.constrainable.contentMode = .scaleAspectFit

            for playRange in content.playRanges {
              context.constrainable.setPlayRange(
                fromMarker: playRange.fromMarker,
                toMarker: playRange.toMarker,
                event: playRange.event)
            }
          })
      }

      GroupItem<UILabel>(
        dataID: DataID.title,
        content: content.title,
        make: {
          let label = UILabel()
          label.translatesAutoresizingMaskIntoConstraints = false
          return label
        },
        setContent: { context, content in
          context.constrainable.text = content
        })
    }
  }

}
