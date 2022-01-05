// Created by Cal Stephens on 12/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import Lottie
import UIKit

/// Displays a list of all of the sample Lottie animations
/// available to be previews in this app's bundle
final class SampleListViewController: CollectionViewController {

  // MARK: Lifecycle

  init(directory: String) {
    self.directory = directory

    let layout = UICollectionViewCompositionalLayout.list(
      using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))

    super.init(layout: layout)
    setItems(items, animated: false)

    title = directory
    configureSettingsMenu()
  }

  // MARK: Private

  private let directory: String

  private var isTopLevel: Bool {
    directory == "Samples"
  }

  /// All subdirectories within the current `directory`
  private var subdirectoryURLs: [URL] {
    let fileManager = FileManager()

    return ((try? fileManager.contentsOfDirectory(
      at: Bundle.main.bundleURL.appendingPathComponent(directory),
      includingPropertiesForKeys: [.isDirectoryKey],
      options: [])) ?? [])
      .filter { url in
        var isDirectory = ObjCBool(false)
        fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
      }
      .sorted(by: {
        $0.lastPathComponent.localizedCompare($1.lastPathComponent) == .orderedAscending
      })
  }

  @ItemModelBuilder
  private var items: [ItemModeling] {
    sampleAnimationLinks
    subdirectoryLinks

    if isTopLevel {
      demoLinks
    }
  }

  @ItemModelBuilder
  private var sampleAnimationLinks: [ItemModeling] {
    let animationsNames = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: directory) ?? [])
      .map { $0.lastPathComponent.replacingOccurrences(of: ".json", with: "") }
      .sorted(by: { $0.localizedCompare($1) == .orderedAscending })

    for animationName in animationsNames {
      let animationPath = "\(directory)/\(animationName)"

      LinkView.itemModel(
        dataID: animationName,
        content: .init(
          animationName: animationPath,
          title: animationName))
        .didSelect { [weak self] context in
          self?.show(
            AnimationPreviewViewController(animationPath),
            sender: context.view)
        }
    }
  }

  @ItemModelBuilder
  private var subdirectoryLinks: [ItemModeling] {
    for subdirectoryURL in subdirectoryURLs {
      LinkView.itemModel(
        dataID: subdirectoryURL,
        content: .init(animationName: nil, title: subdirectoryURL.lastPathComponent))
        .didSelect { [weak self] context in
          guard let self = self else { return }

          self.show(
            SampleListViewController(directory: "\(self.directory)/\(subdirectoryURL.lastPathComponent)"),
            sender: context.view)
        }
    }
  }

  @ItemModelBuilder
  private var demoLinks: [ItemModeling] {
    LinkView.itemModel(
      dataID: "Controls Demo",
      content: .init(animationName: nil, title: "Controls Demo"))
      .didSelect { [weak self] context in
        self?.show(ControlsDemoViewController(), sender: context.view)
      }
  }

  private func configureSettingsMenu() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Settings",
      image: .init(systemName: "gear"),
      primaryAction: nil,
      menu: UIMenu(
        title: "Rendering Engine",
        children: [
          UIAction(
            title: "Standard",
            state: Configuration.useNewRenderingEngine ? .off : .on,
            handler: { [weak self] _ in
              Configuration.useNewRenderingEngine = false
              self?.configureSettingsMenu()
            }),
          UIAction(
            title: "Experimental",
            state: Configuration.useNewRenderingEngine ? .on : .off,
            handler: { [weak self] _ in
              Configuration.useNewRenderingEngine = true
              self?.configureSettingsMenu()
            }),
        ]))
  }

}
