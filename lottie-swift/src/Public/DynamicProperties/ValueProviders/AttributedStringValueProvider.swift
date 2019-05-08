//
//  AttributedStringValueProvider.swift
//  Lottie_iOS
//
//  Created by Nate de Jager on 2019-05-08.
//

import Foundation
import CoreGraphics
import QuartzCore
import CoreText

/// A `ValueProvider` that returns a NSAttributedString Value
public final class AttributedStringValueProvider: AnyValueProvider {

    /// The attributed string value of the provider
    public var attributedString: AttributedString {
        didSet {
            hasUpdate = true
        }
    }

    /// Initializes with a single attributed string.
    public init(_ attributedString: AttributedString) {
        self.attributedString = attributedString
        hasUpdate = true
    }

    // MARK: ValueProvider Protocol

    public var valueType: Any.Type {
        return AttributedString.self
    }

    public func hasUpdate(frame: CGFloat) -> Bool {
        return hasUpdate
    }

    public func value(frame: AnimationFrameTime) -> Any {
        return attributedString
    }

    // MARK: Private

    private var hasUpdate: Bool = true
}
