//
//  FetchBreadcrumbTrialManager.swift
//  Lottie-iOS
//
//  Created by Omar Masri on 5/17/24.
//

import Foundation

/// Used to leave BreadcrumbTrial in some of Lottie operation we do
public final class FetchBreadcrumbTrialManager {
    public static let shared: FetchBreadcrumbTrialManager = .init()

    private var traceLeaver: (any FetchBreadcrumbTrialLeaver)?

    init(traceLeaver: (any FetchBreadcrumbTrialLeaver)? = nil) {
        self.traceLeaver = traceLeaver
    }

    /// Configure the traceLeaver value that will be used to leave breadcrumbs
    /// - Parameter traceLeaver: any FetchBreadcrumbTrialLeaver
    public func configure(with traceLeaver: any FetchBreadcrumbTrialLeaver) {
        self.traceLeaver = traceLeaver
    }

    func dropBreadcrumb(in entity: String, at point: String, with value: Any? = nil) {
        traceLeaver?.leaveTrace(in: entity, at: point, with: value)
    }
}
