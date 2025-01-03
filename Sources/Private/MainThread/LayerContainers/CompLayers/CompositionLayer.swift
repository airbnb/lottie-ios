//
//  LayerContainer.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/22/19.
//

import QuartzCore

// MARK: - CompositionLayer

/// The base class for a child layer of CompositionContainer
class CompositionLayer: CALayer, KeypathSearchable {

  // MARK: Lifecycle

  init(layer: LayerModel, size: CGSize) {
    transformNode = LayerTransformNode(transform: layer.transform)
    if let masks = layer.masks?.filter({ $0.mode != .none }), !masks.isEmpty {
      maskLayer = MaskContainerLayer(masks: masks)
    } else {
      maskLayer = nil
    }
    matteType = layer.matte
    inFrame = layer.inFrame.cgFloat
    outFrame = layer.outFrame.cgFloat
    timeStretch = layer.timeStretch.cgFloat
    startFrame = layer.startTime.cgFloat
    keypathName = layer.name
    childKeypaths = [transformNode.transformProperties]
    super.init()
    anchorPoint = .zero
    actions = [
      "opacity": NSNull(),
      "transform": NSNull(),
      "bounds": NSNull(),
      "anchorPoint": NSNull(),
      "sublayerTransform": NSNull(),
      "shadowOpacity": NSNull(),
      "shadowOffset": NSNull(),
      "shadowColor": NSNull(),
      "shadowRadius": NSNull(),
    ]

    contentsLayer.anchorPoint = .zero
    contentsLayer.bounds = CGRect(origin: .zero, size: size)
    contentsLayer.actions = [
      "opacity": NSNull(),
      "transform": NSNull(),
      "bounds": NSNull(),
      "anchorPoint": NSNull(),
      "sublayerTransform": NSNull(),
      "hidden": NSNull(),
    ]
    compositingFilter = layer.blendMode.filterName
    addSublayer(contentsLayer)

    if let maskLayer {
      contentsLayer.mask = maskLayer
    }

    // There are two different drop shadow schemas, either using `DropShadowEffect` or `DropShadowStyle`.
    // If both happen to be present, prefer the `DropShadowEffect` (which is the drop shadow schema
    // supported on other platforms).
    let dropShadowEffect = layer.effects.first(where: { $0 is DropShadowEffect }) as? DropShadowModel
    let dropShadowStyle = layer.styles.first(where: { $0 is DropShadowStyle }) as? DropShadowModel
    if let dropShadowModel = dropShadowEffect ?? dropShadowStyle {
      layerEffectNodes.append(DropShadowNode(model: dropShadowModel))
    }
    name = layer.name
  }

  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? CompositionLayer else {
      fatalError("Wrong Layer Class")
    }
    transformNode = layer.transformNode
    matteType = layer.matteType
    inFrame = layer.inFrame
    outFrame = layer.outFrame
    timeStretch = layer.timeStretch
    startFrame = layer.startFrame
    keypathName = layer.keypathName
    childKeypaths = [transformNode.transformProperties]
    maskLayer = nil
    layerEffectNodes = layer.layerEffectNodes
    super.init(layer: layer)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  weak var layerDelegate: CompositionLayerDelegate?

  let transformNode: LayerTransformNode

  let contentsLayer = CALayer()

  let maskLayer: MaskContainerLayer?

  let matteType: MatteType?

  let inFrame: CGFloat
  let outFrame: CGFloat
  let startFrame: CGFloat
  let timeStretch: CGFloat

  var layerEffectNodes: [LayerEffectNode] = []

  // MARK: Keypath Searchable

  let keypathName: String

  final var childKeypaths: [KeypathSearchable]

  var renderScale: CGFloat = 1 {
    didSet {
      updateRenderScale()
    }
  }

  var matteLayer: CompositionLayer? {
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

  var keypathProperties: [String: AnyNodeProperty] {
    [:]
  }

  var keypathLayer: CALayer? {
    contentsLayer
  }

  final func displayWithFrame(frame: CGFloat, forceUpdates: Bool) {
    transformNode.updateTree(frame, forceUpdates: forceUpdates)
    let layerVisible = frame.isInRangeOrEqual(inFrame, outFrame)
    /// Only update contents if current time is within the layers time bounds.
    if layerVisible {
      displayContentsWithFrame(frame: frame, forceUpdates: forceUpdates)
      maskLayer?.updateWithFrame(frame: frame, forceUpdates: forceUpdates)
    }
    contentsLayer.transform = transformNode.globalTransform
    contentsLayer.opacity = transformNode.opacity
    contentsLayer.isHidden = !layerVisible
    layerDelegate?.frameUpdated(frame: frame)

    for layerEffectNode in layerEffectNodes {
      layerEffectNode.updateWithFrame(layer: self, frame: frame)
    }
  }

  func displayContentsWithFrame(frame _: CGFloat, forceUpdates _: Bool) {
    /// To be overridden by subclass
  }

  func updateRenderScale() {
    contentsScale = renderScale
  }
}

// MARK: - CompositionLayerDelegate

protocol CompositionLayerDelegate: AnyObject {
  func frameUpdated(frame: CGFloat)
}
