// Created by Cal Stephens on 12/9/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import Epoxy
import EpoxyCollectionView
import Lottie
import SwiftUI
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
    (
      (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: directory) ?? []) +
        (Bundle.main.urls(forResourcesWithExtension: "lottie", subdirectory: directory) ?? []))
      .map { $0.lastPathComponent.replacingOccurrences(of: ".json", with: "") }
      .sorted(by: { $0.localizedCompare($1) == .orderedAscending })
      .map { (name: $0, path: "\(directory)/\($0)") }
      .compactMap { animationName, animationPath in
        // Samples can be excluded from the example app directory
        // by prefixing their filename with an _
        if animationName.hasPrefix("_") {
          return nil
        }

        return LinkView.itemModel(
          dataID: animationName,
          content: .init(
            animationName: animationPath,
            title: animationName))
          .didSelect { [weak self] context in
            let previewViewController: UIViewController
            switch Configuration.previewImplementation {
            case .swiftUI:
              previewViewController = UIHostingController(
                rootView: AnimationPreviewView(animationName: animationPath))

            case .uiKit:
              previewViewController = AnimationPreviewViewController(animationPath)
            }

            self?.show(previewViewController, sender: context.view)
          }
      }
  }

  @ItemModelBuilder
  private var subdirectoryLinks: [ItemModeling] {
    subdirectoryURLs.map { subdirectoryURL in
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
      image: UIImage(systemName: "gear")!,
      primaryAction: nil,
      menu: UIMenu(children: [
        UIMenu(
          title: "Rendering Engine",
          options: .displayInline,
          children: [
            action(for: .automatic),
            action(for: .mainThread),
            action(for: .coreAnimation),
          ]),
        UIMenu(
          title: "Framework",
          options: .displayInline,
          children: [
            action(for: .swiftUI),
            action(for: .uiKit),
          ]),
      ]))
  }

  private func action(for renderingEngineOption: RenderingEngineOption) -> UIAction {
    UIAction(
      title: renderingEngineOption.rawValue,
      state: Configuration.renderingEngineOption == renderingEngineOption ? .on : .off,
      handler: { [weak self] _ in
        Configuration.renderingEngineOption = renderingEngineOption
        self?.configureSettingsMenu()
      })
  }

  private func action(for previewImplementation: AnimationPreviewImplementation) -> UIAction {
    UIAction(
      title: previewImplementation.rawValue,
      state: Configuration.previewImplementation == previewImplementation ? .on : .off,
      handler: { [weak self] _ in
        Configuration.previewImplementation = previewImplementation
        self?.configureSettingsMenu()
      })
  }

}
