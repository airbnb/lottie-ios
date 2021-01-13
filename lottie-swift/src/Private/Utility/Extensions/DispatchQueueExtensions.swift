//
//  DispatchQueueExtensions.swift
//  Lottie
//
//  Created by Viktor Radulov on 12/31/20.
//  Copyright © 2020 YurtvilleProds. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static var global: DispatchQueue {
        if #available(macOS 10.12, iOS 8, *) {
            return DispatchQueue.global()
        } else {
            return DispatchQueue.global(priority: .default)
        }
    }
}
