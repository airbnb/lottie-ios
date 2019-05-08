//
//  TextNode.swift
//  Lottie
//
//  Created by Nate de Jager on 2019-05-08.
//

import Foundation
import CoreGraphics
import QuartzCore

class TextNodeProperties: NodePropertyMap, KeypathSearchable {

    let keypathName: String

    init(attributedString: NSAttributedString) {
        self.keypathName = "Text"
        var properties = [String : AnyNodeProperty]()

        let attribString = AttributedString(attributedString: attributedString)
        let attributedStringProvider = AttributedStringValueProvider(attribString)
        let attributedStringNodeProperty = NodeProperty<AttributedString>(provider: attributedStringProvider)

        properties["AttributedString"] = attributedStringNodeProperty
        self.keypathProperties = properties
        self.properties = Array(keypathProperties.values)
    }

    private(set) var keypathProperties: [String : AnyNodeProperty]
    private(set) var properties: [AnyNodeProperty]
}
