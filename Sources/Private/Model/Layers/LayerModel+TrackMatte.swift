// Copyright © 2026 Airbnb Inc. All rights reserved.

// MARK: - TrackMattePairing

/// The result of resolving the track mattes of a z-ordered array of `LayerModel`s.
struct TrackMattePairing {
  /// Maps the offset of a matted layer to the offset of the layer providing its track matte.
  let matteOffsets: [Int: Int]

  /// The offsets of the layers that are used as a track matte,
  /// which are never rendered on their own.
  let matteSourceOffsets: Set<Int>
}

extension Collection<LayerModel> {

  /// Resolves the track matte of each layer in this collection.
  ///
  /// A layer that uses a track matte carries a `MatteType` (`tt`). The layer providing the matte
  /// is either referenced explicitly by index through `matteParent` (`tp`), or, when that key is
  /// absent, is the layer directly above the matted layer in the original layer list.
  /// A layer used as a track matte is never rendered on its own.
  ///
  ///  - Assumes the layers are sorted in z-axis order.
  func resolveTrackMattes() -> TrackMattePairing {
    let layers = Array(self)

    /// The offset of the layer with each `index`. Matching `CALayer.setupLayerHierarchy`,
    /// the first layer wins if several layers share the same `index`.
    var offsetsByIndex = [Int: Int]()
    for (offset, layer) in layers.enumerated() where offsetsByIndex[layer.index] == nil {
      offsetsByIndex[layer.index] = offset
    }

    var matteOffsets = [Int: Int]()
    var matteSourceOffsets = Set<Int>()

    /// Explicit `matteParent` references are unambiguous and can point anywhere
    /// in the layer list, so they're resolved before falling back to adjacency.
    for (offset, layer) in layers.enumerated() {
      guard
        layer.usesTrackMatte,
        let matteParent = layer.matteParent,
        let matteOffset = offsetsByIndex[matteParent],
        matteOffset != offset,
        !matteSourceOffsets.contains(matteOffset)
      else { continue }

      matteOffsets[offset] = matteOffset
      matteSourceOffsets.insert(matteOffset)
    }

    /// Layers are listed front to back, so the layer directly above a matted layer
    /// in the original layer list is the following layer in z-axis order.
    ///  - A layer that was already consumed as a track matte is skipped entirely,
    ///    so that a run of consecutive matted layers pairs up two at a time.
    ///  - A `matteParent` that doesn't reference any layer in this list falls back to
    ///    adjacency as well, so an unresolvable reference behaves as if it wasn't present.
    for offset in layers.indices {
      guard
        !matteSourceOffsets.contains(offset),
        matteOffsets[offset] == nil,
        layers[offset].usesTrackMatte
      else { continue }

      let matteOffset = layers.index(after: offset)
      guard
        layers.indices.contains(matteOffset),
        !matteSourceOffsets.contains(matteOffset)
      else { continue }

      matteOffsets[offset] = matteOffset
      matteSourceOffsets.insert(matteOffset)
    }

    /// A layer can also be flagged as a track matte by `isMatteTarget` (`td`) without being
    /// resolved above, e.g. if the layer referencing it was dropped because its type or asset
    /// isn't supported. Such a layer is a matte source, so it isn't rendered on its own either.
    for (offset, layer) in layers.enumerated() where layer.isMatteTarget {
      matteSourceOffsets.insert(offset)
    }

    return TrackMattePairing(
      matteOffsets: matteOffsets,
      matteSourceOffsets: matteSourceOffsets
    )
  }

  /// Pairs each `LayerModel` within this collection with the `LayerModel`
  /// providing its track matte, if applicable. Layers used as a track matte
  /// are omitted, since they're not rendered on their own.
  ///  - Assumes the layers are sorted in z-axis order.
  func pairedLayersAndMattes()
    -> [(layer: LayerModel, matte: (model: LayerModel, matteType: MatteType)?)]
  {
    let layers = Array(self)
    let pairing = resolveTrackMattes()

    return layers.indices.compactMap { offset in
      guard !pairing.matteSourceOffsets.contains(offset) else { return nil }
      let layer = layers[offset]

      guard
        let matteOffset = pairing.matteOffsets[offset],
        let matteType = layer.matte
      else { return (layer: layer, matte: nil) }

      return (layer: layer, matte: (model: layers[matteOffset], matteType: matteType))
    }
  }
}

extension LayerModel {
  /// Whether or not this layer is masked by a track matte.
  var usesTrackMatte: Bool {
    guard let matte else { return false }
    return matte != .none
  }
}
