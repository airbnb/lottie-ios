//
//  CGPointExtensions.swift
//  Lottie
//
//  Created by Zak Forrest on 6/17/21.
//  Copyright © 2021 YurtvilleProds. All rights reserved.
//

import CoreGraphics

extension CGPoint: AnyInitializable {
  
  init(value: Any) throws {
    if let dictionary = value as? [String: CGFloat] {
      let x: CGFloat = try dictionary.valueFor(key: "x")
      let y: CGFloat = try dictionary.valueFor(key: "y")
      self.init(x: x, y: y)
    } else if let array = value as? [CGFloat],
              array.count > 1 {
      self.init(x: array[0], y: array[1])
    } else {
      throw InitializableError.invalidInput
    }
  }
  
}
