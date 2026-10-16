//
//  CameraHeaderControlsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraHeaderControlsView: View {
    
    let isRecording: Bool
    let flashMode: CameraFlashMode
    let isFlashAvailable: Bool
    let gridIsOn: Bool
    var rotation = CameraControlRotation()
    let onClose: () -> Void
    let onFlashOptions: () -> Void
    let onToggleGrid: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            closeButton
            Spacer(minLength: 0)
            flashButton
            gridButton
        }
    }
    
    @ViewBuilder
    private var closeButton: some View {
        if !isRecording {
            Button(action: onClose) {
                Image(.close)
                    .padding(.normal)
            }
            .rotate(rotation)
        }
    }
    
    private var flashButton: some View {
        Button(action: onFlashOptions) {
            CameraFlashIcon(mode: flashMode,
                            isHighlighted: flashMode != .off)
            .padding(.normal)
        }
        .disabled(!isFlashAvailable)
        .opacity(isFlashAvailable ? 1 : 0.4)
        .rotate(rotation)
        .accessibilityLabel(LocalizableCamera.moreActionFlash.localized)
        .accessibilityValue(flashMode.title)
    }
    
    private var gridButton: some View {
        Button(action: onToggleGrid) {
            CameraGridIcon(isOn: gridIsOn)
                .padding(.normal)
        }
        .rotate(rotation)
        .accessibilityLabel(gridIsOn
                            ? LocalizableCamera.hideGrid.localized
                            : LocalizableCamera.showGrid.localized)
    }
}

struct CameraHeaderControlsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(isRecording: false).previewDisplayName("Idle")
            preview(isRecording: true).previewDisplayName("Recording")
        }
        .background(Styles.Colors.backgroundGrey1)
        .previewLayout(.sizeThatFits)
    }
    
    private static func preview(isRecording: Bool) -> CameraHeaderControlsView {
        CameraHeaderControlsView(isRecording: isRecording,
                                 flashMode: .off,
                                 isFlashAvailable: true,
                                 gridIsOn: false,
                                 onClose: {},
                                 onFlashOptions: {},
                                 onToggleGrid: {})
    }
}
