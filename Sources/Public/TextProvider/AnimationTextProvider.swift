//
//  AnimationTextProvider.swift
//  Lottie_iOS
//
//  Created by Alexandr Goncharov on 07/06/2019.
//

import Foundation

// MARK: - AnimationTextProvider

/// Text provider is a protocol that is used to supply text to `LottieAnimationView`.
public protocol AnimationTextProvider: AnyObject {
  /// The text to use for the text layer with the given keypath name.
  ///  - `keypathName` is specifically the last component of the layer's full path,
  ///    so for a layer at `CompositionName.TextLayerName`, the value of `keypathName`
  ///    would be `"TextLayerName"`.
  func textFor(keypathName: String, sourceText: String) -> String
}

// MARK: - DictionaryTextProvider

/// Text provider that simply map values from dictionary
public final class DictionaryTextProvider: AnimationTextProvider {

  // MARK: Lifecycle

  public init(_ values: [String: String]) {
    self.values = values
  }

  // MARK: Public

  public func textFor(keypathName: String, sourceText: String) -> String {
    values[keypathName] ?? sourceText
  }

  // MARK: Internal

  let values: [String: String]
}

// MARK: - DefaultTextProvider

/// Default text provider. Uses text in the animation file
public final class DefaultTextProvider: AnimationTextProvider {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func textFor(keypathName _: String, sourceText: String) -> String {
    sourceText
  }
}
