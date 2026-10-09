//
//  CameraFlashController.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation

enum CameraFlashController {
    static func applyVideoTorch(
        device: AVCaptureDevice?,
        flashMode: CameraFlashMode,
        isRecording: Bool = false
    ) {
        let torchMode: AVCaptureDevice.TorchMode
        switch flashMode {
        case .auto:
            torchMode = isRecording ? .auto : .off
        case .on:
            torchMode = .on
        case .off:
            torchMode = .off
        }
        setTorchMode(torchMode, device: device)
    }

    static func turnOffTorch(device: AVCaptureDevice?) {
        setTorchMode(.off, device: device)
    }

    private static func setTorchMode(_ mode: AVCaptureDevice.TorchMode, device: AVCaptureDevice?) {
        guard let device,
              device.hasTorch,
              device.isTorchModeSupported(mode) else { return }

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.torchMode = mode
        } catch {
            debugLog("Unable to configure the camera torch: \(error.localizedDescription)")
        }
    }
}

extension CameraFlashMode {
    var photoFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .auto:
            return .auto
        case .on:
            return .on
        case .off:
            return .off
        }
    }
}
