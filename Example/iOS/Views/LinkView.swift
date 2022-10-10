// Created by Cal Stephens on 12/10/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import Lottie
import UIKit

// MARK: - LinkView

final class LinkView: UIView, EpoxyableView {

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
    var animationName: String?
    var title: String
    var subtitle: String?
  }

  func setContent(_ content: Content, animated _: Bool) {
    group.setItems {
      if let animationName = content.animationName {
        GroupItem<LottieAnimationView>(
          dataID: DataID.animationPreview,
          content: content.animationName,
          make: {
            let animationView = LottieAnimationView()
            animationView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
              animationView.widthAnchor.constraint(equalToConstant: 50),
              animationView.heightAnchor.constraint(equalToConstant: 50),
            ])

            return animationView
          },
          setContent: { context, _ in
            context.constrainable.animation = .named(animationName)
            context.constrainable.contentMode = .scaleAspectFit
            context.constrainable.currentProgress = 0.5
          })
      }

      VGroupItem(
        dataID: DataID.titleSubtitleGroup,
        style: .init(spacing: 4))
      {
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

        if let subtitle = content.subtitle {
          GroupItem<UILabel>(
            dataID: DataID.subtitle,
            content: subtitle,
            make: {
              let label = UILabel()
              label.textColor = .secondaryLabel
              label.font = .preferredFont(forTextStyle: .caption2)
              label.translatesAutoresizingMaskIntoConstraints = false
              return label
            },
            setContent: { context, content in
              context.constrainable.text = content
            })
        }
      }
    }
  }

  // MARK: Private

  private enum DataID {
    case animationPreview
    case titleSubtitleGroup
    case title
    case subtitle
  }

  private let group = HGroup(alignment: .center, spacing: 24)
}

// MARK: HighlightableView

extension LinkView: HighlightableView {
  func didHighlight(_ isHighlighted: Bool) {
    UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
      self.backgroundColor = isHighlighted ? .systemFill : .systemBackground
    }
  }
}
