//
//  CameraViewModifiers.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import UIKit

extension View {
    func cameraFrame(_ frame: CGRect) -> some View {
        self
            .frame(width: frame.width, height: frame.height)
            .position(x: frame.midX, y: frame.midY)
    }
    
    /// Keeps the control in the layout while recording so the shutter does not shift, then fades it out.
    func hiddenDuringRecording(_ isRecording: Bool) -> some View {
        self
            .opacity(isRecording ? 0 : 1)
            .disabled(isRecording)
            .animation(.easeInOut(duration: CameraStyle.Animations.recording),
                       value: isRecording)
    }
    
    /// Covers the live preview while the other camera starts, then fades the blur away.
    func cameraFlipBlur(_ isFlipping: Bool) -> some View {
        modifier(CameraFlipBlurModifier(isFlipping: isFlipping))
    }
}

private struct CameraFlipBlurModifier: ViewModifier {
    let isFlipping: Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            CameraFlipBlurBackdrop(isActive: isFlipping)
                .allowsHitTesting(false)
        }
    }
}

private struct CameraFlipBlurBackdrop: UIViewRepresentable {
    let isActive: Bool
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: nil)
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        let isShowing = uiView.effect != nil
        guard isActive != isShowing else { return }
        let apply = {
            uiView.effect = isActive ? UIBlurEffect(style: .dark) : nil
        }
        if isActive {
            apply()
        } else {
            UIView.animate(withDuration: CameraStyle.Animations.cameraFlip, animations: apply)
        }
    }
}
