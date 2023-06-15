//
//  LottieView.swift
//  lottie-swift-iOS
//
//  Created by vdotup on 14/06/2023.
//

import SwiftUI
/// SwiftUI UIViewRepresentable for LottieAnimationView.
public struct LottieView: UIViewRepresentable {
    
    public let name: String
    public let loopMode: LottieLoopMode
    public let animationSpeed: CGFloat
    public let contentMode: UIView.ContentMode
    public let animationView: LottieAnimationView
    
    public init(name: String, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.name = name
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
        self.contentMode = contentMode
        self.animationView = LottieAnimationView(name: name)
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(animationView)
        animationView.contentMode = contentMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
}
