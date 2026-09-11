//
//  CameraShutterButton.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

enum CameraShutterMode {
    case photo
    case video
    case recording
}

struct CameraShutterButton: View {
    
    let mode: CameraShutterMode
    let action: () -> Void
    
    @State private var innerScale: CGFloat = 1
    
    var body: some View {
        Button(action: capture) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.4), lineWidth: 2)
                
                RoundedRectangle(cornerRadius: innerCornerRadius, style: .continuous)
                    .fill(innerColor)
                    .frame(width: innerDiameter, height: innerDiameter)
                    .scaleEffect(innerScale)
            }
            .frame(width: .largeIconSize,
                   height: .largeIconSize)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: CameraStyle.Animations.recording), value: mode)
    }
    
    private var innerDiameter: CGFloat {
        mode == .recording
        ? .smallMediumIconSize
        : .extraMediumIconSize
    }
    
    private var innerCornerRadius: CGFloat {
        mode == .recording
        ? .tinyCornerRadius
        : .extraMediumIconSize / 2
    }
    
    private var innerColor: Color {
        mode == .photo ? .white : Styles.Colors.red
    }
    
    private func capture() {
        action()
        
        guard mode == .photo else { return }
        
        withAnimation(.easeInOut(duration: CameraStyle.Animations.shutterDip)) {
            innerScale = CameraStyle.Animations.shutterDipScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CameraStyle.Animations.shutterDip) {
            withAnimation(.easeInOut(duration: CameraStyle.Animations.shutterDip)) {
                innerScale = 1
            }
        }
    }
}

struct CameraShutterButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            CameraShutterButton(mode: .photo) {}
            CameraShutterButton(mode: .video) {}
            CameraShutterButton(mode: .recording) {}
        }
        .padding()
        .background(Styles.Colors.backgroundGrey2)
    }
}
