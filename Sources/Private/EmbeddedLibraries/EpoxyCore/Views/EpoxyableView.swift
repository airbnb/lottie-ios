#if !os(macOS)
// Created by eric_horacek on 1/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

/// A `UIView` that can be declaratively configured via a concrete `EpoxyableModel` instance.
internal typealias EpoxyableView = StyledView & ContentConfigurableView & BehaviorsConfigurableView
#endif
