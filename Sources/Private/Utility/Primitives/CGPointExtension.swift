//
//  CGPointExtension.swift
//  Lottie
//
//  Created by Marcelo Fabri on 5/5/22.
//

import CoreGraphics

extension CGPoint: AnyInitializable {

  init(value: Any) throws {
    if let dictionary = value as? [String: CGFloat] {
      let x: CGFloat = try dictionary.valueFor(key: "x")
      let y: CGFloat = try dictionary.valueFor(key: "y")
      self.init(x: x, y: y)
    } else if
      let array = value as? [CGFloat],
      array.count > 1
    {
      self.init(x: array[0], y: array[1])
    } else {
      throw InitializableError.invalidInput
    }
  }

}
