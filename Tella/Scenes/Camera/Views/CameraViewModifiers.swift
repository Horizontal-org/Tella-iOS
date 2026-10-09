//
//  CameraViewModifiers.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

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
}
