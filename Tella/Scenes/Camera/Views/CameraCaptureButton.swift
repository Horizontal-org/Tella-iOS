//
//  CameraCaptureButton.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

enum CameraCaptureMode {
    case photo
    case video
    case recording
}

struct CameraCaptureButton: View {
    
    let mode: CameraCaptureMode
    let action: () -> Void
    
    @State private var innerScale: CGFloat = 1
    @State private var pulseID = UUID()
    
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
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: CameraStyle.Animations.recording), value: mode)
        .onChange(of: mode) { _ in resetPulse() }
        .onDisappear(perform: resetPulse)
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

        let currentPulseID = UUID()
        pulseID = currentPulseID
        
        withAnimation(.easeInOut(duration: CameraStyle.Animations.shutterDip)) {
            innerScale = CameraStyle.Animations.shutterDipScale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + CameraStyle.Animations.shutterDip) {
            guard pulseID == currentPulseID else { return }
            withAnimation(.easeInOut(duration: CameraStyle.Animations.shutterDip)) {
                innerScale = 1
            }
        }
    }

    private func resetPulse() {
        pulseID = UUID()
        withoutAnimation {
            innerScale = 1
        }
    }
}

struct CameraCaptureButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            CameraCaptureButton(mode: .photo) {}
            CameraCaptureButton(mode: .video) {}
            CameraCaptureButton(mode: .recording) {}
        }
        .padding()
        .background(Styles.Colors.backgroundGrey2)
    }
}
