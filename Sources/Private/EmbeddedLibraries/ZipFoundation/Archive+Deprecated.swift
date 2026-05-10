//
//  Archive+Deprecated.swift
//  ZIPFoundation
//
//  Created by Thomas Zoechling on 06.02.23.
//

import Foundation

extension Archive {

    @available(*, deprecated, message: "Please use the throwing initializer.")
    convenience init?(url: URL, accessMode mode: AccessMode, preferredEncoding: String.Encoding? = nil) {
        try? self.init(url: url, accessMode: mode, pathEncoding: preferredEncoding)
    }

#if swift(>=5.0)
    @available(*, deprecated, message: "Please use the throwing initializer.")
    convenience init?(data: Data = Data(), accessMode mode: AccessMode, preferredEncoding: String.Encoding? = nil) {
        try? self.init(data: data, accessMode: mode, pathEncoding: preferredEncoding)
    }
#endif
}
