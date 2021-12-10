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
  }

  // MARK: Internal

  var items: [ItemModeling] {
    var items = [ItemModeling]()

    // Create an link for each sample .json in the current directory
    let animationsNames = (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: directory) ?? [])
      .map { $0.lastPathComponent.replacingOccurrences(of: ".json", with: "") }
      .sorted(by: { $0.localizedCompare($1) == .orderedAscending })

    for animationName in animationsNames {
      let animationPath = "\(directory)/\(animationName)"

      items += [
        LinkView.itemModel(
          dataID: animationName,
          content: .init(
            animationName: animationPath,
            title: animationName))
          .didSelect { [weak self] context in
            self?.show(
              AnimationPreviewViewController(animationPath),
              sender: context.view)
          },
      ]
    }

    // Create a link for each subdirectory in the current directory
    let fileManager = FileManager()

    let subdirectoryURLs = ((try? fileManager.contentsOfDirectory(
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

    for subdirectoryURL in subdirectoryURLs {
      items += [
        LinkView.itemModel(
          dataID: subdirectoryURL,
          content: .init(animationName: nil, title: subdirectoryURL.lastPathComponent))
          .didSelect { [weak self] context in
            guard let self = self else { return }

            self.show(
              SampleListViewController(directory: "\(self.directory)/\(subdirectoryURL.lastPathComponent)"),
              sender: context.view)
          },
      ]
    }

    return items
  }

  // MARK: Private

  private let directory: String

}
