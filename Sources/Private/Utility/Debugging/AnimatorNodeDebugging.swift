//
//  AnimatorNodeDebugging.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/18/19.
//

import Foundation

extension AnimatorNode {

  func printNodeTree() {
    parentNode?.printNodeTree()
    LottieLogger.shared.print(String(describing: type(of: self)))

    if let group = self as? GroupNode {
      LottieLogger.shared.print("* |Children")
      group.rootNode?.printNodeTree()
      LottieLogger.shared.print("*")
    } else {
      LottieLogger.shared.print("|")
    }
  }

}
