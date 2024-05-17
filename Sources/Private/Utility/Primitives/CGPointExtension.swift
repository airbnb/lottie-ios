//
//  CGPointExtension.swift
//  Lottie
//
//  Created by Marcelo Fabri on 5/5/22.
//

import CoreGraphics

extension CGPoint: AnyInitializable {
    // MARK: Breadcrumb

    private static var BreadcrumbEntityName: String {
        "CGPointExtension.swift, CGPoint(value: Any) custom initializer"
    }

    // MARK: Lifecycle

    init(value: Any) throws {
        FetchBreadcrumbTrialManager.shared.dropBreadcrumb(
            in: Self.BreadcrumbEntityName,
            at: "Start point",
            with: value
        )
        if let dictionary = value as? [String: CGFloat] {
            FetchBreadcrumbTrialManager.shared.dropBreadcrumb(
                in: Self.BreadcrumbEntityName,
                at: "value is [String: CGFloat] type, will start initializing CGFloat struct now",
                with: value
            )
            let x: CGFloat = try dictionary.value(for: CodingKeys.x)
            let y: CGFloat = try dictionary.value(for: CodingKeys.y)
            self.init(x: x, y: y)
            FetchBreadcrumbTrialManager.shared.dropBreadcrumb(
                in: Self.BreadcrumbEntityName,
                at: "CGFloat is successfully initialized"
            )
        } else if
            let array = value as? [CGFloat],
            array.count > 1
        {
            FetchBreadcrumbTrialManager.shared.dropBreadcrumb(
                in: Self.BreadcrumbEntityName,
                at: "value is [CGFloat] type, will start initializing CGFloat struct now",
                with: value
            )
            self.init(x: array[0], y: array[1])
            FetchBreadcrumbTrialManager.shared.dropBreadcrumb(
                in: Self.BreadcrumbEntityName,
                at: "CGFloat is successfully initialized"
            )
        } else {
            FetchBreadcrumbTrialManager.shared.dropBreadcrumb(
                in: Self.BreadcrumbEntityName,
                at: "CGFloat is throwing an invalidInput error"
            )
            throw InitializableError.invalidInput()
        }
    }

    // MARK: Private

    private enum CodingKeys: String {
        case x
        case y
    }
}
