// Created by Cal Stephens on 12/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Lottie
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    // We don't ever want a single animation to crash the Example app,
    // so we stub out `assert` and `assertionFailure` to just `print`.
    LottieLogger.shared = .printToConsole

    Configuration.applyCurrentConfiguration()

    let window = UIWindow(frame: UIScreen.main.bounds)

    let navigationController = UINavigationController(
      rootViewController: SampleListViewController(directory: "Samples"))

    navigationController.navigationBar.prefersLargeTitles = true
    window.rootViewController = navigationController

    window.makeKeyAndVisible()
    self.window = window
    return true
  }

}
