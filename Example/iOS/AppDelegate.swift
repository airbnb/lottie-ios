// Created by Cal Stephens on 12/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
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
