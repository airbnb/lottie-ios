//
//  CompositionLayerDependecy.swift
//  Lottie_iOS
//
//  Created by Volodimir Moskaliuk on 10/23/19.
//  Copyright © 2019 YurtvilleProds. All rights reserved.
//

import QuartzCore

public protocol CompositionLayerDependency {
  func layerUpdated(layer: CALayer)
  func layerAnimationRemoved(layer: CALayer)
}
