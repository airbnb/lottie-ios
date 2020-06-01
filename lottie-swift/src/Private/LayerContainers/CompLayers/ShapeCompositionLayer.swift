//
//  ShapeLayerContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import Foundation
import QuartzCore

protocol ShapeComposition: Composition {
    var renderContainer: ShapeContainerLayer? { get }
}

/**
 A CompositionLayer responsible for initializing and rendering shapes
 */
class ShapeCompositionLayer: CompositionLayer, ShapeComposition {
  
  let rootNode: AnimatorNode?
  let renderContainer: ShapeContainerLayer?
  let shape: ShapeLayerModel?
  var fakeLayer = CALayer()
    override var notificationLayer: CALayer {
        fakeLayer.isHidden = contentsLayer.isHidden
        fakeLayer.opacity = contentsLayer.opacity
        fakeLayer.transform = contentsLayer.transform
        return fakeLayer
    }
  
  override var renderScale: CGFloat {
    didSet {
      renderContainer?.renderScale = renderScale
    }
  }
  
  init(shapeLayer: ShapeLayerModel) {
    let results = shapeLayer.items.initializeNodeTree()
    let renderContainer = ShapeContainerLayer()
    self.renderContainer = renderContainer
    self.rootNode = results.rootNode
    self.shape = shapeLayer
    super.init(layer: shapeLayer, size: .zero)
    contentsLayer.addSublayer(renderContainer)
    for container in results.renderContainers {
      renderContainer.insertRenderLayer(container)
    }
    rootNode?.updateTree(0, forceUpdates: true)
    self.childKeypaths.append(contentsOf: results.childrenNodes)
  }
  
  override init(layer: Any) {
    guard let layer = layer as? ShapeCompositionLayer else {
      fatalError("init(layer:) wrong class.")
    }
    self.rootNode = nil
    self.renderContainer = nil
    self.shape = nil
    super.init(layer: layer)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    rootNode?.updateTree(frame, forceUpdates: forceUpdates)
    renderContainer?.markRenderUpdates(forFrame: frame)
    if let shape = shape {
        updateSize(fromShapeItems: shape.items, frame: frame)
        applyTransform(transform: shape.transform, frame: frame)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
    func updateSize(fromShapeItems shapeItems: [ShapeItem], frame: CGFloat) {
        for shape in shapeItems {
            if let measurable = shape as? MeasurableShape {
                let size = KeyframeInterpolator(keyframes: measurable.size.keyframes)
                let position = KeyframeInterpolator(keyframes: measurable.position.keyframes)
                if let size = size.value(frame: frame) as? Vector3D,
                   let position = position.value(frame: frame) as? Vector3D {
                    var origin: CGPoint
                    if position.pointValue == .zero {
                        origin = self.contentsLayer.frame.origin
                    } else {
                        origin = position.pointValue.flatPoint
                    }
                    
                    fakeLayer.frame = CGRect(origin: origin, size: size.sizeValue)
                }
            } else if let group = shape as? Group {
                updateSize(fromShapeItems: group.items, frame: frame)
            } else if let transform = shape as? ShapeTransform {
                applyTransform(transform: transform, frame: frame)
            }
        }
    }
    
    func applyTransform(transform: Transformable, frame: CGFloat) {
        guard let positionKeyframes = transform.position else { return }
        
        let position = KeyframeInterpolator(keyframes: positionKeyframes.keyframes)
        let scale = KeyframeInterpolator(keyframes: transform.scale.keyframes)
        
        if let position = position.value(frame: frame) as? Vector3D,
           let scale = scale.value(frame: frame) as? Vector3D {
            var frame = fakeLayer.frame
            frame.origin.x = position.pointValue.x
            frame.origin.y = position.pointValue.y
            frame.size.width *= CGFloat(scale.x / 100.0)
            frame.size.height *= CGFloat(scale.y / 100.0)
            frame.origin.x -= frame.size.width / 2.0
            frame.origin.y -= frame.size.height / 2.0
        
            fakeLayer.frame = frame
        }
    }
}

class ShapeTransformCompositionLayer: TransformCompositionLayer, ShapeComposition {
  
  let rootNode: AnimatorNode?
  let renderContainer: ShapeContainerLayer?
  let shape: ShapeLayerModel?
  var fakeLayer = CALayer()
    override var notificationLayer: CALayer {
        fakeLayer.isHidden = contentsLayer.isHidden
        fakeLayer.opacity = contentsLayer.opacity
        fakeLayer.transform = contentsLayer.transform
        return fakeLayer
    }
  
  override var renderScale: CGFloat {
    didSet {
      renderContainer?.renderScale = renderScale
    }
  }
  
  init(shapeLayer: ShapeLayerModel) {
    let results = shapeLayer.items.initializeNodeTree()
    let renderContainer = ShapeContainerLayer()
    self.renderContainer = renderContainer
    self.rootNode = results.rootNode
    self.shape = shapeLayer
    super.init(layer: shapeLayer, size: .zero)
    contentsLayer.addSublayer(renderContainer)
    for container in results.renderContainers {
      renderContainer.insertRenderLayer(container)
    }
    rootNode?.updateTree(0, forceUpdates: true)
    self.childKeypaths.append(contentsOf: results.childrenNodes)
  }
  
  override init(layer: Any) {
    guard let layer = layer as? ShapeCompositionLayer else {
      fatalError("init(layer:) wrong class.")
    }
    self.rootNode = nil
    self.renderContainer = nil
    self.shape = nil
    super.init(layer: layer)
  }
  
  override func displayContentsWithFrame(frame: CGFloat, forceUpdates: Bool) {
    rootNode?.updateTree(frame, forceUpdates: forceUpdates)
    renderContainer?.markRenderUpdates(forFrame: frame)
    if let shape = shape {
        updateSize(fromShapeItems: shape.items, frame: frame)
        applyTransform(transform: shape.transform, frame: frame)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
    func updateSize(fromShapeItems shapeItems: [ShapeItem], frame: CGFloat) {
        for shape in shapeItems {
            if let measurable = shape as? MeasurableShape {
                let size = KeyframeInterpolator(keyframes: measurable.size.keyframes)
                let position = KeyframeInterpolator(keyframes: measurable.position.keyframes)
                if let size = size.value(frame: frame) as? Vector3D,
                   let position = position.value(frame: frame) as? Vector3D {
                    var origin: CGPoint
                    if position.pointValue == .zero {
                        origin = self.contentsLayer.frame.origin
                    } else {
                        origin = position.pointValue.flatPoint
                    }
                    
                    fakeLayer.frame = CGRect(origin: origin, size: size.sizeValue)
                }
            } else if let group = shape as? Group {
                updateSize(fromShapeItems: group.items, frame: frame)
            } else if let transform = shape as? ShapeTransform {
                applyTransform(transform: transform, frame: frame)
            }
        }
    }
    
    func applyTransform(transform: Transformable, frame: CGFloat) {
        guard let positionKeyframes = transform.position else { return }
        
        let position = KeyframeInterpolator(keyframes: positionKeyframes.keyframes)
        let scale = KeyframeInterpolator(keyframes: transform.scale.keyframes)
        
        if let position = position.value(frame: frame) as? Vector3D,
           let scale = scale.value(frame: frame) as? Vector3D {
            var frame = fakeLayer.frame
            frame.origin.x = position.pointValue.x
            frame.origin.y = position.pointValue.y
            frame.size.width *= CGFloat(scale.x / 100.0)
            frame.size.height *= CGFloat(scale.y / 100.0)
            frame.origin.x -= frame.size.width / 2.0
            frame.origin.y -= frame.size.height / 2.0
        
            fakeLayer.frame = frame
        }
    }
}
