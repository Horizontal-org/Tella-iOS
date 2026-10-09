//
//  CameraCaptureControlsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraCaptureControlsView: View {
    let mode: CameraCaptureMode
    let file: VaultFileDB?
    var rotation = CameraControlRotation()
    let onGallery: () -> Void
    let onCapture: () -> Void
    let onFlipCamera: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            galleryButton
            Spacer()
            CameraCaptureButton(mode: mode, action: onCapture)
            Spacer()
            flipCameraButton
        }
        .padding(.horizontal, .extraLarge)
        .frame(height: CameraViewfinderLayout.shutterHeight)
    }
    
    private var isRecording: Bool {
        mode == .recording
    }
    
    /// The gallery and flip buttons stay in the layout while recording, so the shutter does not move.
    private var galleryButton: some View {
        CameraGalleryButton(file: file, rotation: rotation, action: onGallery)
            .hiddenDuringRecording(isRecording)
    }
    
    private var flipCameraButton: some View {
        Button(action: onFlipCamera) {
            Image(.cameraFlipCamera)
                .frame(width: .mediumIconSize,
                       height: .mediumIconSize)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
        }
        .rotate(rotation)
        .hiddenDuringRecording(isRecording)
    }
}

struct CameraCaptureControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            preview(mode: .photo)
            preview(mode: .video)
            preview(mode: .recording)
        }
        .background(Styles.Colors.backgroundGrey1)
    }
    
    private static func preview(mode: CameraCaptureMode) -> some View {
        CameraCaptureControlsView(mode: mode,
                                  file: .stub(),
                                  rotation: CameraControlRotation(deviceOrientation: .portrait),
                                  onGallery: {},
                                  onCapture: {},
                                  onFlipCamera: {})
    }
}
