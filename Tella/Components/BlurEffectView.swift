//
//  BlurEffectView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct BlurEffectView: UIViewRepresentable {
    
    var style: UIBlurEffect.Style = .light
    var intensity: CGFloat = 0.2
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        view.isUserInteractionEnabled = false
        
        let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak view] in
            view?.effect = UIBlurEffect(style: style)
        }
        animator.pausesOnCompletion = true
        animator.startAnimation()
        animator.pauseAnimation()
        animator.fractionComplete = min(1, max(0.01, intensity))
        context.coordinator.animator = animator
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    
    static func dismantleUIView(_ uiView: UIVisualEffectView, coordinator: Coordinator) {
        coordinator.animator?.stopAnimation(true)
        coordinator.animator = nil
    }
    
    final class Coordinator {
        var animator: UIViewPropertyAnimator?
    }
}
