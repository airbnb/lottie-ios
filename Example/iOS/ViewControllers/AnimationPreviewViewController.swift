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

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    displayLink?.invalidate()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let animation = LottieAnimation.named(animationName)

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

    engineLabel.font = .preferredFont(forTextStyle: .footnote)
    engineLabel.textColor = .secondaryLabel
    engineLabel.translatesAutoresizingMaskIntoConstraints = false
    engineLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    view.addSubview(engineLabel)

    NSLayoutConstraint.activate([
      animationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      animationView.bottomAnchor.constraint(equalTo: engineLabel.topAnchor, constant: -8),
      animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      engineLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
      engineLabel.bottomAnchor.constraint(equalTo: slider.topAnchor),
    ])

    /// Slider
    slider.heightAnchor.constraint(equalToConstant: 40).isActive = true
    slider.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
    slider.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
    slider.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -12).isActive = true
    slider.addTarget(self, action: #selector(updateAnimation(sender:)), for: .valueChanged)

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

    engineLabel.text = [
      animationView.currentRenderingEngine?.description,
      animationView.isAnimationPlaying ? "Playing" : "Paused",
    ].compactMap { $0 }.joined(separator: " · ")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateAnimation()
  }

  // MARK: Private

  private let animationName: String
  private let animationView = LottieAnimationView()
  private let slider = UISlider()
  private let engineLabel = UILabel()

  private var displayLink: CADisplayLink?

  private var loopMode = LottieLoopMode.autoReverse
  private var speed: CGFloat = 1
  private var fromProgress: AnimationProgressTime = 0
  private var toProgress: AnimationProgressTime = 1

  private func configureSettingsMenu() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Settings",
      image: UIImage(systemName: "repeat.circle")!,
      primaryAction: nil,
      menu: UIMenu(children: [
        UIMenu(
          title: "Loop Mode...",
          children: [
            UIAction(
              title: "Autoreverse",
              state: loopMode == .autoReverse ? .on : .off,
              handler: { [unowned self] _ in
                loopMode = .autoReverse
                updateAnimation()
              }),
            UIAction(
              title: "Loop",
              state: loopMode == .loop ? .on : .off,
              handler: { [unowned self] _ in
                loopMode = .loop
                updateAnimation()
              }),
            UIAction(
              title: "Play Once",
              state: loopMode == .playOnce ? .on : .off,
              handler: { [unowned self] _ in
                loopMode = .playOnce
                updateAnimation()
              }),
          ]),

        UIMenu(
          title: "Speed",
          children: [
            UIAction(
              title: "-100%",
              state: speed == -1 ? .on : .off,
              handler: { [unowned self] _ in
                speed = -1
                updateAnimation()
              }),
            UIAction(
              title: "-50%",
              state: speed == -0.5 ? .on : .off,
              handler: { [unowned self] _ in
                speed = -0.5
                updateAnimation()
              }),
            UIAction(
              title: "50%",
              state: speed == 0.5 ? .on : .off,
              handler: { [unowned self] _ in
                speed = 0.5
                updateAnimation()
              }),
            UIAction(
              title: "100%",
              state: speed == 1 ? .on : .off,
              handler: { [unowned self] _ in
                speed = 1
                updateAnimation()
              }),
          ]),

        UIMenu(
          title: "From Progress...",
          children: [
            UIAction(
              title: "0%",
              state: fromProgress == 0 ? .on : .off,
              handler: { [unowned self] _ in
                fromProgress = 0
                updateAnimation()
              }),
            UIAction(
              title: "25%",
              state: fromProgress == 0.25 ? .on : .off,
              handler: { [unowned self] _ in
                fromProgress = 0.25
                updateAnimation()
              }),
            UIAction(
              title: "50%",
              state: fromProgress == 0.5 ? .on : .off,
              handler: { [unowned self] _ in
                fromProgress = 0.5
                updateAnimation()
              }),
          ]),

        UIMenu(
          title: "To Progress...",
          children: [
            UIAction(
              title: "0%",
              state: toProgress == 0 ? .on : .off,
              handler: { [unowned self] _ in
                toProgress = 0
                updateAnimation()
              }),
            UIAction(
              title: "50%",
              state: toProgress == 0.5 ? .on : .off,
              handler: { [unowned self] _ in
                toProgress = 0.5
                updateAnimation()
              }),
            UIAction(
              title: "75%",
              state: toProgress == 0.75 ? .on : .off,
              handler: { [unowned self] _ in
                toProgress = 0.75
                updateAnimation()
              }),
            UIAction(
              title: "100%",
              state: toProgress == 1 ? .on : .off,
              handler: { [unowned self] _ in
                toProgress = 1
                updateAnimation()
              }),
          ]),
      ]))
  }

  private func updateAnimation() {
    animationView.play(fromProgress: fromProgress, toProgress: toProgress, loopMode: loopMode)
    animationView.animationSpeed = speed
    configureSettingsMenu()
  }

}
