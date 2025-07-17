//
//  AnimationImageProvider.swift
//  Lottie_iOS
//
//  Created by Alexandr Goncharov on 07/06/2019.
//

import Foundation

// MARK: - AnimationKeypathTextProvider
public struct TextRangeData {
    
    // ① 属性改为 public（可读即可）
    public let start: Int?
    public let end: Int?
    public let rangeOpacity: CGFloat?
    public let rangeUnit: TextRangeUnit?
    public let rangeColor: CGColor?
    public let rangeFont: UIFont?
    public let strokeColor: CGColor?
    public let strokeFineness: Double?
    public let shadow: TextShadowData?
    // ② 初始化器改为 public
    public init(start: Int? = nil,
                end: Int? = nil,
                rangeOpacity: CGFloat? = 1,
                rangeUnit: TextRangeUnit? = .index,
                rangeColor: CGColor? = nil,
                rangeFont: UIFont? = nil,
                strokeColor: CGColor? = nil,
                strokeFineness: Double? = nil,
                shadow: TextShadowData? = nil) {
        self.start        = start
        self.end          = end
        self.rangeOpacity = rangeOpacity
        self.rangeUnit    = rangeUnit
        self.rangeColor   = rangeColor
        self.rangeFont    = rangeFont
        self.strokeColor = strokeColor
        self.strokeFineness = strokeFineness
        self.shadow = shadow
    }
}

public struct TextBackgroundData {
    public let color: CGColor?
    public let radius: Double?
    public let offset: CGPoint?
    public let enlarge: CGPoint?
    public init(color: CGColor?, radius: Double?, offset: CGPoint?, enlarge: CGPoint?) {
        self.color = color
        self.radius = radius
        self.offset = offset
        self.enlarge = enlarge
    }
}

public struct TextShadowData {
    public let shadowColor: CGColor?
    public let shadowOpacity: Double?
    public let shadowBlur: Double?
    public let shadowDistance: Double?
    public let shadowAngle: Double?
    public init(shadowColor: CGColor?, shadowOpacity: Double?, shadowBlur: Double?, shadowDistance: Double?, shadowAngle: Double?) {
        self.shadowColor = shadowColor
        self.shadowOpacity = shadowOpacity
        self.shadowBlur = shadowBlur
        self.shadowDistance = shadowDistance
        self.shadowAngle = shadowAngle
    }
}

/// Protocol for providing dynamic text to for a Lottie animation.
public protocol AnimationKeypathTextProvider: AnyObject {
    /// The text to display for the given `AnimationKeypath`.
    /// If `nil` is returned, continues using the existing default text value.
    func text(for keypath: AnimationKeypath, sourceText: String) -> String?
    
    func updateLineHieght(_ lineHeight:Double) -> Double?
    
    func updateWorldSpacing(_ worldSpace:Double) -> Double?
    
    func updateTextFillColor(_ fillColor:CGColor?)-> CGColor?
    
    func updateTextShadowColor()-> TextShadowData?
    
    func updateTextStrokeColor(_ strokeColor:CGColor?)-> CGColor?
    
    func updateTextBackgroundColor()-> TextBackgroundData?
    
    func updateTextStrokeWidth(_ strokeWidth:Double?)-> Double?
        
    func updateRangeText() -> TextRangeData?
    
    func updateTextAlinment() -> NSTextAlignment?
    
    func updateShowUnderLine() -> Bool?
    
}

// MARK: - AnimationKeypathTextProvider

/// Legacy protocol for providing dynamic text for a Lottie animation.
/// Instead prefer conforming to `AnimationKeypathTextProvider`.
@available(*, deprecated, message: """
  `AnimationKeypathTextProvider` has been deprecated and renamed to `LegacyAnimationTextProvider`. \
  Instead, conform to `AnimationKeypathTextProvider` instead or conform to `LegacyAnimationTextProvider` explicitly.
  """)
public typealias AnimationTextProvider = LegacyAnimationTextProvider

// MARK: - LegacyAnimationTextProvider

/// Legacy protocol for providing dynamic text for a Lottie animation.
/// Instead prefer conforming to `AnimationKeypathTextProvider`.
public protocol LegacyAnimationTextProvider: AnimationKeypathTextProvider {
  /// Legacy method to look up the text to display for the given keypath.
  /// Instead, prefer implementing `AnimationKeypathTextProvider.`
  /// The behavior of this method depends on the current rendering engine:
  ///  - The Core Animation rendering engine always calls this method
  ///    with the full keypath (e.g. `MY_LAYER.text_value`).
  ///  - The Main Thread rendering engine always calls this method
  ///    with the final component of the key path (e.g. just `text_value`).
  func textFor(keypathName: String, sourceText: String) -> String
}

extension LegacyAnimationTextProvider {
  public func text(for _: AnimationKeypath, sourceText _: String) -> String? {
    nil
  }
}

// MARK: - TextContentScaleProvider

/// `AnimationKeypathTextProvider` that can additionally customize the content scale of the rendered text
public protocol TextContentsScaleProvider: AnimationKeypathTextProvider {
  /// The `contentsScale` value to use when rendering text for the given layer keypath.
  /// Customizing the `contentsScale` can help reduce aliasing caused by text resizing.
  func contentsScale(for keypath: AnimationKeypath) -> CGFloat?
}

// MARK: - DictionaryTextProvider

/// Text provider that simply map values from dictionary.
///  - The dictionary keys can either be the full layer keypath string (e.g. `MY_LAYER.text_value`)
///    or simply the final path component of the keypath (e.g. `text_value`).
public final class DictionaryTextProvider: AnimationKeypathTextProvider, LegacyAnimationTextProvider {
    public func updateLineHieght(_ lineHeight: Double) -> Double? {
        return lineHeight
    }
    public func updateWorldSpacing(_ worldSpace:Double) -> Double? {
        return worldSpace
    }
    public func updateTextFillColor(_ fillColor:CGColor?)-> CGColor? {
        return fillColor
    }
    
    public func updateTextShadowColor()-> TextShadowData? {
        return nil
    }
    public func updateTextStrokeColor(_ strokeColor:CGColor?)-> CGColor? {
        return strokeColor
    }
    
    public func updateShowUnderLine() -> Bool? {
        return false
    }
    
    public func updateTextStrokeWidth(_ strokeWidth:Double?)-> Double? {
        return strokeWidth
    }
    
    public func updateTextBackgroundColor()-> TextBackgroundData? {
        return nil
    }
    
    public func updateRangeText() -> TextRangeData? {
        
        return nil
    }
    
    public func updateTextAlinment() -> NSTextAlignment? {
        return nil
    }

  // MARK: Lifecycle

  public init(_ values: [String: String]) {
    self.values = values
  }

  // MARK: Public

  public func text(for keypath: AnimationKeypath, sourceText: String) -> String? {
    if let valueForFullKeypath = values[keypath.fullPath] {
      valueForFullKeypath
    }

    else if
      let lastKeypathComponent = keypath.keys.last,
      let valueForLastComponent = values[lastKeypathComponent]
    {
      valueForLastComponent
    }

    else {
      sourceText
    }
  }

  /// Never called directly by Lottie, but we continue to implement this conformance for backwards compatibility.
  public func textFor(keypathName: String, sourceText: String) -> String {
    values[keypathName] ?? sourceText
  }

  // MARK: Internal

  let values: [String: String]
}

// MARK: Equatable

extension DictionaryTextProvider: Equatable {
  public static func ==(_ lhs: DictionaryTextProvider, _ rhs: DictionaryTextProvider) -> Bool {
    lhs.values == rhs.values
  }
}

// MARK: - DefaultTextProvider

/// Default text provider. Uses text in the animation file
public final class DefaultTextProvider: AnimationKeypathTextProvider, LegacyAnimationTextProvider {
    public func updateLineHieght(_ lineHeight: Double) -> Double? {
        return lineHeight
    }
    
    public func updateWorldSpacing(_ worldSpace:Double) -> Double? {
        return worldSpace
    }
    
    public func updateTextFillColor(_ fillColor:CGColor?)-> CGColor? {
        return fillColor
    }
    
    public func updateTextShadowColor()-> TextShadowData? {
        return nil
    }
    
    public func updateTextStrokeColor(_ strokeColor:CGColor?)-> CGColor? {
        return strokeColor
    }
    
    public func updateTextStrokeWidth(_ strokeWidth:Double?)-> Double? {
        return strokeWidth
    }
    
    public func updateShowUnderLine() -> Bool? {
        return false
    }
    
    public func updateTextBackgroundColor()-> TextBackgroundData? {
        return nil
    }

    public func updateRangeText() -> TextRangeData? {
        
        return nil
    }
    public func updateTextAlinment() -> NSTextAlignment? {
        return nil
    }
  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func textFor(keypathName _: String, sourceText: String) -> String {
    sourceText
  }

  public func text(for _: AnimationKeypath, sourceText: String) -> String {
    sourceText
  }
}

// MARK: Equatable

extension DefaultTextProvider: Equatable {
  public static func ==(_: DefaultTextProvider, _: DefaultTextProvider) -> Bool {
    true
  }
}
