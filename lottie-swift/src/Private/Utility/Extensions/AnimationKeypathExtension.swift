//
//  KeypathSearchableExtension.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation
import QuartzCore

extension KeypathSearchable {
  
  func animatorNodes(for keyPath: AnimationKeypath) -> [AnimatorNode]? {
    // Make sure there is a current key path.
    guard let currentKey = keyPath.currentKey else { return nil }
    
    // Now try popping the keypath for wildcard / child search
    guard let nextKeypath = keyPath.popKey(keypathName) else {
      // We may be on the final keypath. Check for match.
      if let node = self as? AnimatorNode,
        currentKey.equalsKeypath(keypathName) {
        // This is the final keypath and matches self. Return.s
        return [node]
      }
      /// Nope. Stop Search
      return nil
    }
    
    var results: [AnimatorNode] = []
    
    if let node = self as? AnimatorNode,
      nextKeypath.currentKey == nil {
      // Keypath matched self and was the final keypath.
      results.append(node)
    }
    
    for child in childKeypaths {
      guard let childNode = child as? AnimatorNode else { continue }
      
      // Check if the child has any nodes matching the next keypath.
      if let foundNodes = childNode.animatorNodes(for: nextKeypath) {
        results.append(contentsOf: foundNodes)
      }
      
      // In this case the current key is fuzzy, and both child and self have the same name. Keep digging!
      if currentKey.keyPathType == .fuzzyWildcard,
        child.keypathName == keypathName,
        let foundNodes = childNode.animatorNodes(for: keyPath) {
        results.append(contentsOf: foundNodes)
      }
    }
    
    guard results.count > 0 else {
      return nil
    }
    
    return results
  }
  
  func nodeProperties(for keyPath: AnimationKeypath) -> [AnyNodeProperty]? {
    guard let nextKeypath = keyPath.popKey(keypathName) else {
      /// Nope. Stop Search
      return nil
    }
    
    /// Keypath matches in some way. Continue the search.
    var results: [AnyNodeProperty] = []
    
    /// Check if we have a property keypath yet
    if let propertyKey = nextKeypath.propertyKey,
      let property = keypathProperties[propertyKey] {
      /// We found a property!
      results.append(property)
    }
    
    if nextKeypath.nextKeypath != nil {
      /// Now check child keypaths.
      for child in childKeypaths {
        if let childProperties = child.nodeProperties(for: nextKeypath) {
          results.append(contentsOf: childProperties)
        }
      }
    }
    
    guard results.count > 0 else {
      return nil
    }
    
    return results
  }
  
  func layer(for keyPath: AnimationKeypath) -> CALayer? {
    if keyPath.currentKey == keypathName && keyPath.nextKeypath == nil {
      /// We found our layer!
      return keypathLayer
    }
    guard let nextKeypath = keyPath.popKey(keypathName) else {
      /// Nope. Stop Search
      return nil
    }
    
    if nextKeypath.nextKeypath != nil {
      /// Now check child keypaths.
      for child in childKeypaths {
        if let layer = child.layer(for: keyPath) {
          return layer
        }
      }
    }
    return nil
  }
  
  func logKeypaths(for keyPath: AnimationKeypath?) {
    let newKeypath: AnimationKeypath
    if let previousKeypath = keyPath {
      newKeypath = previousKeypath.appendingKey(keypathName)
    } else {
      newKeypath = AnimationKeypath(keys: [keypathName])
    }
    print(newKeypath.fullPath)
    for key in keypathProperties.keys {
      print(newKeypath.appendingKey(key).fullPath)
    }
    for child in childKeypaths {
      child.logKeypaths(for: newKeypath)
    }
  }
}

extension AnimationKeypath {
  var currentKey: String? {
    return keys.first
  }
  
  var nextKeypath: String? {
    guard keys.count > 1 else {
      return nil
    }
    return keys[1]
  }
  
  var propertyKey: String? {
    if nextKeypath == nil {
      /// There are no more keypaths. This is a property key.
      return currentKey
    }
    if keys.count == 2, currentKey?.keyPathType == .fuzzyWildcard {
      /// The next keypath is the last and the current is a fuzzy key.
      return nextKeypath
    }
    return nil
  }
  
  // Pops the top keypath from the stack if the keyname matches.
  func popKey(_ keyname: String) -> AnimationKeypath? {
    guard let currentKey = currentKey,
      currentKey.equalsKeypath(keyname),
      keys.count > 1 else {
        // Current key either doesnt match or we are on the last key.
        return nil
    }
    
    // Pop the keypath from the stack and return the new stack.
    let newKeys: [String]
    
    if currentKey.keyPathType == .fuzzyWildcard {
      /// Dont remove if current key is a fuzzy wildcard, and if the next keypath doesnt equal keypathname
      if nextKeypath == keyname {
        /// Remove next two keypaths. This keypath breaks the wildcard.
        var oldKeys = keys
        oldKeys.remove(at: 0)
        oldKeys.remove(at: 0)
        newKeys = oldKeys
      } else {
        newKeys = keys
      }
    } else {
      var oldKeys = keys
      oldKeys.remove(at: 0)
      newKeys = oldKeys
    }
    
    return AnimationKeypath(keys: newKeys)
  }
  
  var fullPath: String {
    return keys.joined(separator: ".")
  }
  
  func appendingKey(_ key: String) -> AnimationKeypath {
    var newKeys = keys
    newKeys.append(key)
    return AnimationKeypath(keys: newKeys)
  }
}



extension String {
  var keyPathType: KeyType {
    switch self {
    case "*":
      return .wildcard
    case "**":
      return .fuzzyWildcard
    default:
      return .specific
    }
  }
  
  func equalsKeypath(_ keyname: String) -> Bool {
    if keyPathType == .wildcard || keyPathType == .fuzzyWildcard {
      return true
    }
    if self == keyname {
      return true
    }
    return false
  }
}

enum KeyType {
  case specific
  case wildcard
  case fuzzyWildcard
}
