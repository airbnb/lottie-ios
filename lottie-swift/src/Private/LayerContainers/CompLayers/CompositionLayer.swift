//
//  LayerContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation
import QuartzCore

protocol Composition: KeypathSearchable {
    var transformNode: LayerTransformNode { get }
    var renderScale: CGFloat { get set }
    
    var contentsLayer: CALayer { get }
    
    var matteType: MatteType? { get }
    var matteLayer: (CALayer & Composition)? { get set }
    
    var layerDelegate: CompositionLayerDelegate? { get set }
    
    func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool)
    func hideContentsWithFrame(frame: CGFloat, forceUpdates: Bool)
    func displayWithFrame(frame: CGFloat, forceUpdates: Bool)
    
    var layerDependencies: [CompositionLayerDependency] { get }
    
    func addDependency(_ dependency: CompositionLayerDependency)
}

/**
 The base class for a child layer of CompositionContainer
 */
class CompositionLayer: CALayer, Composition {
  
  weak var layerDelegate: CompositionLayerDelegate?
  
  let transformNode: LayerTransformNode
  
  let contentsLayer: CALayer
  
  let maskLayer: MaskContainerLayer?
  
  let matteType: MatteType?
  
  var renderScale: CGFloat = 1
    
  var effects: [Effect]?
  
  var layerDependencies = [CompositionLayerDependency]()
  
  var matteLayer: (CALayer & Composition)? {
    didSet {
      if let matte = matteLayer {
        if let type = matteType, type == .invert {
          mask = InvertedMatteLayer(inputMatte: matte)
        } else {
          mask = matte
        }
      } else {
        mask = nil
      }
    }
  }
  
  let inFrame: CGFloat
  let outFrame: CGFloat
  let startFrame: CGFloat
  let timeStretch: CGFloat
  
  init(layer: LayerModel, size: CGSize) {
    self.transformNode = LayerTransformNode(transform: layer.transform)
    if let masks = layer.masks {
      maskLayer = MaskContainerLayer(masks: masks)
    } else {
      maskLayer = nil
    }
    self.matteType = layer.matte
    self.inFrame = layer.inFrame.cgFloat
    self.outFrame = layer.outFrame.cgFloat
    self.timeStretch = layer.timeStretch.cgFloat
    self.startFrame = layer.startTime.cgFloat
    self.keypathName = layer.name
    self.effects = layer.effects
    self.childKeypaths = [transformNode.transformProperties]
    contentsLayer = CALayer()
    
    super.init()
    self.effects?.forEach { $0.setUp(layer: self) }
    self.anchorPoint = .zero
    self.actions = [
      "opacity" : NSNull(),
      "transform" : NSNull(),
      "bounds" : NSNull(),
      "anchorPoint" : NSNull(),
      "sublayerTransform" : NSNull()
    ]
    
    contentsLayer.anchorPoint = .zero
    contentsLayer.bounds = CGRect(origin: .zero, size: size)
    contentsLayer.actions = [
      "opacity" : NSNull(),
      "transform" : NSNull(),
      "bounds" : NSNull(),
      "anchorPoint" : NSNull(),
      "sublayerTransform" : NSNull(),
      "hidden" : NSNull()
    ]
    addSublayer(contentsLayer)
    
    if let maskLayer = maskLayer {
      contentsLayer.mask = maskLayer
    }
  }
  
  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? CompositionLayer else {
      fatalError("Wrong Layer Class")
    }
    self.transformNode = layer.transformNode
    self.matteType = layer.matteType
    self.inFrame = layer.inFrame
    self.outFrame = layer.outFrame
    self.timeStretch = layer.timeStretch
    self.startFrame = layer.startFrame
    self.keypathName = layer.keypathName
    self.childKeypaths = [transformNode.transformProperties]
    self.effects = layer.effects
    self.contentsLayer = layer.contentsLayer
    self.maskLayer = nil
    super.init(layer: layer)
    self.effects?.forEach { $0.setUp(layer: self) }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  final func displayWithFrame(frame: CGFloat, forceUpdates: Bool) {
    transformNode.updateTree(frame, forceUpdates: forceUpdates)
    let layerVisible = frame.isInRangeOrEqual(inFrame, outFrame)
    /// Only update contents if current time is within the layers time bounds.
    if layerVisible || forceUpdates {
      displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
      maskLayer?.updateWithFrame(frame: frame, forceUpdates: forceUpdates)
    } else {
        hideContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    contentsLayer.transform = transformNode.globalTransform
    contentsLayer.opacity = transformNode.opacity
    contentsLayer.isHidden = !layerVisible
    effects?.forEach { $0.apply(layer: self, frame: frame) }
    layerDelegate?.frameUpdated(frame: frame)
    layerDependencies.forEach { $0.layerUpdated(layer: notificationLayer) }
  }
  
  func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    /// To be overridden by subclass
  }
    
  func hideContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    /// To be overridden by subclass
  }
  
  func addDependency(_ dependency: CompositionLayerDependency) {
    layerDependencies.append(dependency)
  }
  
  // MARK: Keypath Searchable
  
  let keypathName: String
  
  var keypathProperties: [String : AnyNodeProperty] {
    return [:]
  }
  
  final var childKeypaths: [KeypathSearchable]
  
  var keypathLayer: CALayer? {
    return contentsLayer
  }
    
  var notificationLayer: CALayer {
    return contentsLayer
  }
}

class TransformCompositionLayer: CATransformLayer, Composition {
  
  weak var layerDelegate: CompositionLayerDelegate?
  
  let transformNode: LayerTransformNode
  
    var contentsLayer: CALayer {
        didSet {
            contentsLayer.anchorPoint = .zero
            contentsLayer.bounds = oldValue.bounds
            contentsLayer.actions = [
              "opacity" : NSNull(),
              "transform" : NSNull(),
              "bounds" : NSNull(),
              "anchorPoint" : NSNull(),
              "sublayerTransform" : NSNull(),
              "hidden" : NSNull()
            ]
            oldValue.removeFromSuperlayer()
            addSublayer(contentsLayer)
            
            if let maskLayer = maskLayer {
              contentsLayer.mask = maskLayer
            }
        }
    }
  
  let maskLayer: MaskContainerLayer?
  
  let matteType: MatteType?
  
  var renderScale: CGFloat = 1
    
  var effects: [Effect]?
  
  var layerDependencies = [CompositionLayerDependency]()
  
  var matteLayer: (CALayer & Composition)? {
    didSet {
      if let matte = matteLayer {
        if let type = matteType, type == .invert {
          mask = InvertedMatteLayer(inputMatte: matte)
        } else {
          mask = matte
        }
      } else {
        mask = nil
      }
    }
  }
  
  let inFrame: CGFloat
  let outFrame: CGFloat
  let startFrame: CGFloat
  let timeStretch: CGFloat
  
  init(layer: LayerModel, size: CGSize) {
    self.transformNode = LayerTransformNode(transform: layer.transform)
    if let masks = layer.masks {
      maskLayer = MaskContainerLayer(masks: masks)
    } else {
      maskLayer = nil
    }
    self.matteType = layer.matte
    self.inFrame = layer.inFrame.cgFloat
    self.outFrame = layer.outFrame.cgFloat
    self.timeStretch = layer.timeStretch.cgFloat
    self.startFrame = layer.startTime.cgFloat
    self.keypathName = layer.name
    self.effects = layer.effects
    self.childKeypaths = [transformNode.transformProperties]
    
    contentsLayer = CALayer()
    
    super.init()
    self.effects?.forEach { $0.setUp(layer: self) }
    self.anchorPoint = .zero
    self.actions = [
      "opacity" : NSNull(),
      "transform" : NSNull(),
      "bounds" : NSNull(),
      "anchorPoint" : NSNull(),
      "sublayerTransform" : NSNull()
    ]
    
    contentsLayer.anchorPoint = .zero
    contentsLayer.bounds = CGRect(origin: .zero, size: size)
    contentsLayer.actions = [
      "opacity" : NSNull(),
      "transform" : NSNull(),
      "bounds" : NSNull(),
      "anchorPoint" : NSNull(),
      "sublayerTransform" : NSNull(),
      "hidden" : NSNull()
    ]
    addSublayer(contentsLayer)
    
    if let maskLayer = maskLayer {
      contentsLayer.mask = maskLayer
    }
  }
  
  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? CompositionLayer else {
      fatalError("Wrong Layer Class")
    }
    self.transformNode = layer.transformNode
    self.matteType = layer.matteType
    self.inFrame = layer.inFrame
    self.outFrame = layer.outFrame
    self.timeStretch = layer.timeStretch
    self.startFrame = layer.startFrame
    self.keypathName = layer.keypathName
    self.childKeypaths = [transformNode.transformProperties]
    self.effects = layer.effects
    self.contentsLayer = layer.contentsLayer
    self.maskLayer = nil
    super.init(layer: layer)
    self.effects?.forEach { $0.setUp(layer: self) }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  final func displayWithFrame(frame: CGFloat, forceUpdates: Bool) {
    transformNode.updateTree(frame, forceUpdates: forceUpdates)
    let layerVisible = frame.isInRangeOrEqual(inFrame, outFrame)
    /// Only update contents if current time is within the layers time bounds.
    if layerVisible || forceUpdates {
      displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
      maskLayer?.updateWithFrame(frame: frame, forceUpdates: forceUpdates)
    } else {
        hideContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    contentsLayer.transform = transformNode.globalTransform
    contentsLayer.opacity = transformNode.opacity
    contentsLayer.isHidden = !layerVisible
    effects?.forEach { $0.apply(layer: self, frame: frame) }
    layerDelegate?.frameUpdated(frame: frame)
    layerDependencies.forEach { $0.layerUpdated(layer: notificationLayer) }
  }
  
  func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    /// To be overridden by subclass
  }
    
  func hideContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    /// To be overridden by subclass
  }
  
  func addDependency(_ dependency: CompositionLayerDependency) {
    layerDependencies.append(dependency)
  }
  
  // MARK: Keypath Searchable
  
  let keypathName: String
  
  var keypathProperties: [String : AnyNodeProperty] {
    return [:]
  }
  
  final var childKeypaths: [KeypathSearchable]
  
  var keypathLayer: CALayer? {
    return contentsLayer
  }
    
  var notificationLayer: CALayer {
    return contentsLayer
  }
}

protocol CompositionLayerDelegate: class {
  func frameUpdated(frame: CGFloat)
}

