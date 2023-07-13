// Created by Cal Stephens on 7/11/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - AnimationListView

struct AnimationListView: View {

  let directory: String

  var body: some View {
    List {
      ForEach(items, id: \.self) { item in
        NavigationLink(value: item) {
          switch item {
          case .animation(let animationName, _):
            HStack {
              LottieView(animation: .named(animationName, subdirectory: directory))
                .currentProgress(0.5)
                .imageProvider(.exampleAppSampleImages)
                .frame(width: 50, height: 50)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

              Text(animationName)
            }

          case .subdirectory(let subdirectoryURL):
            Text(subdirectoryURL.lastPathComponent)
              .frame(height: 50)
          }
        }
        .navigationDestination(for: Item.self) { item in
          switch item {
          case .animation(_, let animationPath):
            AnimationPreviewView(animationName: animationPath)
          case .subdirectory(let subdirectoryURL):
            AnimationListView(directory: "\(directory)/\(subdirectoryURL.lastPathComponent)")
          }
        }
      }
    }.navigationTitle(directory)
  }

}

extension AnimationListView {

  // MARK: Internal

  enum Item: Hashable {
    case subdirectory(URL)
    case animation(name: String, path: String)
  }

  var items: [Item] {
    animations.map { .animation(name: $0.name, path: $0.path) }
      + subdirectoryURLs.map { .subdirectory($0) }
  }

  // MARK: Private

  /// All subdirectories within the current `directory`
  private var subdirectoryURLs: [URL] {
    let fileManager = FileManager()

    return ((try? fileManager.contentsOfDirectory(
      at: Bundle.main.resourceURL!.appendingPathComponent(directory),
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

  /// All Lottie animations within the current `directory`
  private var animations: [(name: String, path: String)] {
    animationURLs
      .map { $0.lastPathComponent.replacingOccurrences(of: ".json", with: "") }
      .sorted(by: { $0.localizedCompare($1) == .orderedAscending })
      .map { (name: $0, path: "\(directory)/\($0)") }
  }

  /// All Lottie animation URLs within the current `directory`
  private var animationURLs: [URL] {
    (Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: directory) ?? []) +
      (Bundle.main.urls(forResourcesWithExtension: "lottie", subdirectory: directory) ?? [])
  }
}
