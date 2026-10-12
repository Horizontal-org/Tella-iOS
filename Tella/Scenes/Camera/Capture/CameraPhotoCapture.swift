//
//  CameraPhotoCapture.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 12/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation

final class CameraPhotoCapture: NSObject {
    
    // MARK: - Output
    
    private(set) var photoOutput: AVCapturePhotoOutput?
    
    // MARK: - Capture callback
    
    var onPhotoCaptured: ((Int64, AVCapturePhoto?, Error?) -> Void)?
}

extension CameraPhotoCapture {
    
    // MARK: - Session configuration
    
    func attach(to session: AVCaptureSession) {
        guard photoOutput == nil else { return }
        
        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(photoOutput) else { return }
        
        session.addOutput(photoOutput)
        applyResolution(to: photoOutput, device: CameraSessionConfigurator.videoDevice(in: session))
        self.photoOutput = photoOutput
    }
    
    func reset() {
        photoOutput = nil
    }
    
    func applyResolution(device: AVCaptureDevice?) {
        guard let photoOutput else { return }
        applyResolution(to: photoOutput, device: device)
    }
    
    // MARK: - Photo settings
    
    func prepareCaptureSettings(flashMode: CameraFlashMode) {
        guard let photoOutput else { return }
        
        let settings = makeHEVCPhotoSettings(flashMode: flashMode.photoFlashMode)
        photoOutput.setPreparedPhotoSettingsArray([settings], completionHandler: nil)
    }
    
    func makeHEVCPhotoSettings(flashMode: AVCaptureDevice.FlashMode) -> AVCapturePhotoSettings {
        let settings: AVCapturePhotoSettings
        if photoOutput?.availablePhotoCodecTypes.contains(.hevc) ?? true {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings()
        }
        
        if let photoOutput {
            if #available(iOS 16.0, *) {
                settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions
            } else {
                settings.isHighResolutionPhotoEnabled = true
            }
            if photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }
        }
        
        return settings
    }
    
    // MARK: - Photo capture
    
    @discardableResult
    func takePhoto(orientation: AVCaptureVideoOrientation, settings: AVCapturePhotoSettings) -> Bool {
        guard let photoOutput, let connection = photoOutput.connection(with: .video),
              connection.isActive, connection.isEnabled else { return false }
        
        connection.videoOrientation = orientation
        photoOutput.capturePhoto(with: settings, delegate: self)
        return true
    }
}

private extension CameraPhotoCapture {
    
    // MARK: - Resolution configuration
    
    func applyResolution(to photoOutput: AVCapturePhotoOutput, device: AVCaptureDevice?) {
        if #available(iOS 16.0, *) {
            if let maxDimensions = device?.activeFormat.supportedMaxPhotoDimensions.last {
                photoOutput.maxPhotoDimensions = maxDimensions
            }
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }
    }
}

extension CameraPhotoCapture: AVCapturePhotoCaptureDelegate {
    
    // MARK: - Capture delegate callbacks
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error {
            debugLog("Unable to capture photo: \(error.localizedDescription)")
            onPhotoCaptured?(photo.resolvedSettings.uniqueID, nil, error)
            return
        }
        onPhotoCaptured?(photo.resolvedSettings.uniqueID, photo, nil)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        // Some failures end the request before a processed photo is delivered.
        if let error {
            onPhotoCaptured?(resolvedSettings.uniqueID, nil, error)
        }
    }
}
