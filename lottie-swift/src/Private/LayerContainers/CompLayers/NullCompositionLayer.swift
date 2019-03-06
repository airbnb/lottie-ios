//
//  NullCompositionLayer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/25/19.
//

import Foundation

class NullCompositionLayer: CompositionLayer {
  
  init(layer: LayerModel) {
    super.init(layer: layer, size: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
