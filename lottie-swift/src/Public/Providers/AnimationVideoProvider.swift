//
//  AnimationVideoProvider.swift
//  Lottie_iOS
//
//  Created by Viktor Radulov on 11/30/19.
//

import Foundation

public protocol AnimationVideoProvider: AnyObject {
    func urlFor(keypathName: String, file: (name: String, extension: String)) -> URL?
}

/// Text provider that simply map values from dictionary
public final class DictionaryVideoProvider: AnimationVideoProvider {
    
    public init(_ values: [String: URL]) {
        self.values = values
    }
    
    let values: [String: URL]
    
    public func urlFor(keypathName: String, file: (name: String, extension: String)) -> URL? {
        return values[keypathName]
    }
}

/// Default text provider. Uses text in the animation file
public final class DefaultVideoProvider: AnimationVideoProvider {
    public func urlFor(keypathName: String, file: (name: String, extension: String)) -> URL? {
        return Bundle.main.url(forResource: file.name, withExtension: file.extension)
    }
    
    public init() {}
}
