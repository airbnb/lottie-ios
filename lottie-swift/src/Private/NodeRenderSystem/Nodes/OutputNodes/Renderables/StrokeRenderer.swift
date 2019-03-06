//
//  StrokeRenderer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/30/19.
//

import Foundation
import QuartzCore

extension LineJoin {
  var cgLineJoin: CGLineJoin {
    switch self {
    case .bevel:
      return .bevel
    case .none:
      return .miter
    case .miter:
      return .miter
    case .round:
      return .round
    }
  }
  
  var caLineJoin: String {
    switch self {
    case .none:
      return kCALineJoinMiter
    case .miter:
      return kCALineJoinMiter
    case .round:
      return kCALineJoinRound
    case .bevel:
      return kCALineJoinBevel
    }
  }
}

extension LineCap {
  var cgLineCap: CGLineCap {
    switch self {
    case .none:
      return .butt
    case .butt:
      return .butt
    case .round:
      return .round
    case .square:
      return .square
    }
  }
  
  var caLineCap: String {
    switch self {
    case .none:
      return kCALineCapButt
    case .butt:
      return kCALineCapButt
    case .round:
      return kCALineCapRound
    case .square:
      return kCALineCapSquare
    }
  }
}

// MARK: - Renderer

/// A rendered that renders a stroke on a path.
class StrokeRenderer: PassThroughOutputNode, Renderable {
  
  var shouldRenderInContext: Bool = false
  
  var color: CGColor? {
    didSet {
      hasUpdate = true
    }
  }
  
  var opacity: CGFloat = 0 {
    didSet {
      hasUpdate = true
    }
  }
  
  var width: CGFloat = 0 {
    didSet {
      hasUpdate = true
    }
  }
  
  var miterLimit: CGFloat = 0 {
    didSet {
      hasUpdate = true
    }
  }
  
  var lineCap: LineCap = .none {
    didSet {
      hasUpdate = true
    }
  }
  
  var lineJoin: LineJoin = .none {
    didSet {
      hasUpdate = true
    }
  }
  
  var dashPhase: CGFloat? {
    didSet {
      hasUpdate = true
    }
  }
  
  var dashLengths: [CGFloat]? {
    didSet {
      hasUpdate = true
    }
  }
  
  func renderBoundsFor(_ boundingBox: CGRect) -> CGRect {
    return boundingBox.insetBy(dx: -width, dy: -width)
  }
  
  func setupForStroke(_ inContext: CGContext) {
    inContext.setLineWidth(width)
    inContext.setMiterLimit(miterLimit)
    inContext.setLineCap(lineCap.cgLineCap)
    inContext.setLineJoin(lineJoin.cgLineJoin)
    if let dashPhase = dashPhase, let lengths = dashLengths {
      inContext.setLineDash(phase: dashPhase, lengths: lengths)
    } else {
      inContext.setLineDash(phase: 0, lengths: [])
    }
  }
  
  func render(_ inContext: CGContext) {
    guard inContext.path != nil && inContext.path!.isEmpty == false else {
      return
    }
    guard let color = color else { return }
    hasUpdate = false
    setupForStroke(inContext)
    inContext.setAlpha(opacity)
    inContext.setStrokeColor(color)
    inContext.strokePath()
  }
  
  func updateShapeLayer(layer: CAShapeLayer) {
    layer.strokeColor = color
    layer.opacity = Float(opacity)
    layer.lineWidth = width
    layer.lineJoin = lineJoin.caLineJoin
    layer.lineCap = lineCap.caLineCap
    layer.lineDashPhase = dashPhase ?? 0
    layer.fillColor = nil
    if let dashPattern = dashLengths {
      layer.lineDashPattern = dashPattern.map({ NSNumber(value: Double($0))})
    }
  }
}
