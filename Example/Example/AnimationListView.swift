// Created by Cal Stephens on 7/11/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

import Lottie
import SwiftUI

// MARK: - AnimationListView

struct AnimationListView: View {

  // MARK: Internal

  enum Content: Hashable, Sendable {
    case directory(_ directory: String)
    case custom(name: String, items: [Item])
  }

  var content: Content

  var body: some View {
    List {
      ForEach(items, id: \.self) { item in
        NavigationLink(value: item) {
          switch item {
          case .animation, .remoteAnimations:
            HStack {
              LottieView {
                try await makeThumbnailAnimation(for: item)
              }
              .currentProgress(0.5)
              .imageProvider(.exampleAppSampleImages)
              .frame(width: 50, height: 50)
              .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

              Text(item.name)
            }

          case .animationList, .controlsDemo, .swiftUIInteroperability, .lottieViewLayoutDemo:
            Text(item.name)
              .frame(height: 50)
          }
        }
      }
    }
    .navigationTitle(content.name)
    .navigationDestination(for: Item.self) { item in
      switch item {
      case .animation(_, let animationPath):
        AnimationPreviewView(animationSource: .local(animationPath: animationPath))
      case .remoteAnimations(let name, let urls):
        AnimationPreviewView(animationSource: .remote(urls: urls, name: name))
      case .animationList(let listContent):
        AnimationListView(content: listContent)
      case .controlsDemo:
        ControlsDemoView()
      case .swiftUIInteroperability:
        SwiftUIInteroperabilityDemoView()
      case .lottieViewLayoutDemo:
        LottieViewLayoutDemoView()
      }
    }
  }

  func makeThumbnailAnimation(for item: Item) async throws -> LottieAnimationSource? {
    switch item {
    case .animation(let animationName, _):
      if animationName.hasSuffix(".lottie") {
        return try await DotLottieFile.named(animationName, subdirectory: directory).animationSource
      } else {
        return LottieAnimation.named(animationName, subdirectory: directory)?.animationSource
      }

    case .remoteAnimations(_, let urls):
      guard let url = urls.first else { return nil }
      return await LottieAnimation.loadedFrom(url: url)?.animationSource

    case .animationList, .controlsDemo, .swiftUIInteroperability, .lottieViewLayoutDemo:
      return nil
    }
  }

  // MARK: Private

  private var isTopLevel: Bool {
    directory == "Samples"
  }

  private var directory: String {
    switch content {
    case .directory(let directory):
      directory
    case .custom:
      "n/a"
    }
  }

}

extension AnimationListView {

  // MARK: Internal

  enum Item: Hashable, Sendable {
    case animationList(AnimationListView.Content)
    case animation(name: String, path: String)
    case remoteAnimations(name: String, urls: [URL])
    case controlsDemo
    case swiftUIInteroperability
    case lottieViewLayoutDemo
  }

  var items: [Item] {
    switch content {
    case .directory:
      animations.map { .animation(name: $0.name, path: $0.path) }
        + subdirectoryURLs.map { .animationList(.directory("\(directory)/\($0.lastPathComponent)")) }
        + customDemos

    case .custom(_, let items):
      items
    }
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

  private var customDemos: [Item] {
    guard isTopLevel else { return [] }

    return [
      .animationList(.remoteAnimationsDemo),
      .controlsDemo,
      .swiftUIInteroperability,
      .lottieViewLayoutDemo,
    ]
  }
}

extension AnimationListView.Item {
  var name: String {
    switch self {
    case .animation(let animationName, _), .remoteAnimations(let animationName, _):
      animationName
    case .animationList(let content):
      content.name
    case .controlsDemo:
      "Controls Demo"
    case .swiftUIInteroperability:
      "SwiftUI Interoperability Demo"
    case .lottieViewLayoutDemo:
      "LottieView Layout Demo"
    }
  }
}

extension AnimationListView.Content {
  static var remoteAnimationsDemo: AnimationListView.Content {
    .custom(
      name: "Remote Animations",
      items: [
        .remoteAnimations(
          name: "Rooms Animation",
          urls: [URL(string: "https://a0.muscache.com/pictures/96699af6-b73e-499f-b0f5-3c862ae7d126.json")!]),
        .remoteAnimations(
          name: "Multiple Animations",
          urls: [
            URL(string: "https://a0.muscache.com/pictures/a7c140ee-6818-4a8a-b3b1-0c785054a611.json")!,
            URL(string: "https://a0.muscache.com/pictures/96699af6-b73e-499f-b0f5-3c862ae7d126.json")!,
          ]),
      ])
  }

  var name: String {
    switch self {
    case .directory(let directory):
      directory.components(separatedBy: "/").last ?? directory
    case .custom(let name, _):
      name
    }
  }
}
