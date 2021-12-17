// Created by Cal Stephens on 12/10/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Lottie
import UIKit

class AnimationPreviewViewController: UIViewController {

  // MARK: Lifecycle

  init(_ animationName: String) {
    self.animationName = animationName
    super.init(nibName: nil, bundle: nil)
    title = animationName.components(separatedBy: "/").last!
    animationView.loopMode = .autoReverse
    configureSettingsMenu()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let animation = Animation.named(animationName)

    animationView.animation = animation
    animationView.contentMode = .scaleAspectFit
    view.addSubview(animationView)

    slider.translatesAutoresizingMaskIntoConstraints = false
    slider.minimumValue = 0
    slider.maximumValue = 1
    slider.value = 0
    view.addSubview(slider)

    animationView.backgroundBehavior = .pauseAndRestore
    animationView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      animationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      animationView.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -12),
      animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    /// Slider
    slider.heightAnchor.constraint(equalToConstant: 40).isActive = true
    slider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
    slider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
    slider.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -12).isActive = true
    slider.addTarget(self, action: #selector(updateAnimation(sender:)), for: .valueChanged)

    /// Play Animation

    /// Create a display link to make slider track with animation progress.
    displayLink = CADisplayLink(target: self, selector: #selector(animationCallback))
    displayLink?.add(
      to: .current,
      forMode: RunLoop.Mode.default)
  }

  @objc
  func updateAnimation(sender: UISlider) {
    animationView.currentProgress = CGFloat(sender.value)
  }

  @objc
  func animationCallback() {
    if animationView.isAnimationPlaying {
      slider.value = Float(animationView.realtimeAnimationProgress)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animationView.play(fromProgress: 0, toProgress: 1)
  }

  // MARK: Private

  private let animationName: String
  private let animationView = AnimationView()
  private let slider = UISlider()

  private var displayLink: CADisplayLink?

  private func configureSettingsMenu() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Settings",
      image: .init(systemName: "repeat.circle"),
      primaryAction: nil,
      menu: UIMenu(
        title: "Loop Mode",
        children: [
          UIAction(
            title: "Autoreverse",
            state: animationView.loopMode == .autoReverse ? .on : .off,
            handler: { [weak self] _ in
              self?.updateLoopMode(to: .autoReverse)
            }),
          UIAction(
            title: "Loop",
            state: animationView.loopMode == .loop ? .on : .off,
            handler: { [weak self] _ in
              self?.updateLoopMode(to: .loop)
            }),
          UIAction(
            title: "Play Once",
            state: animationView.loopMode == .playOnce ? .on : .off,
            handler: { [weak self] _ in
              self?.updateLoopMode(to: .playOnce)
            }),
        ]))
  }

  private func updateLoopMode(to loopMode: LottieLoopMode) {
    animationView.loopMode = loopMode
    animationView.play()
    configureSettingsMenu()
  }

}
