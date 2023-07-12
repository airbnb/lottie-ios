// Created by eric_horacek on 3/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

/// A generic result builder that enables a DSL for building arrays of Epoxy models.
@resultBuilder
internal enum EpoxyModelArrayBuilder<Model> {
  internal typealias Expression = Model
  internal typealias Component = [Model]

  internal static func buildExpression(_ expression: Expression) -> Component {
    [expression]
  }

  internal static func buildExpression(_ expression: Component) -> Component {
    expression
  }

  internal static func buildExpression(_ expression: Expression?) -> Component {
    if let expression = expression {
      return [expression]
    }
    return []
  }

  internal static func buildBlock(_ children: Component...) -> Component {
    children.flatMap { $0 }
  }

  internal static func buildBlock(_ component: Component) -> Component {
    component
  }

  internal static func buildOptional(_ children: Component?) -> Component {
    children ?? []
  }

  internal static func buildEither(first child: Component) -> Component {
    child
  }

  internal static func buildEither(second child: Component) -> Component {
    child
  }

  internal static func buildArray(_ components: [Component]) -> Component {
    components.flatMap { $0 }
  }
}
