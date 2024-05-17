//
//  FetchBreadcrumbTrialManager.swift
//  Lottie-iOS
//
//  Created by Omar Masri on 5/17/24.
//

import Foundation

/// A protocol that needs to be implemented by the main app and it's value must be passed to `FetchBreadcrumbTrialManager.shared` thorough the `configure(:any FetchBreadcrumbTrialLeaver)` method
/// no providing this value will make the`FetchBreadcrumbTrialManager` useless.
public protocol FetchBreadcrumbTrialLeaver {

    /// Called to leave a breadcrumb in the execution path of the Lottie sdk
    /// - Parameters:
    ///   - entity: The name of the entity (class, struct, enum, actor) this method id triggered at
    ///   - point: Any string that can indicate the exact line/process being executed.
    ///   - value: an optional `Any` that represent a specific value that we were trying to process.
    func leaveTrace(
        in entity: String,
        at point: String,
        with value: Any?
    )
}
