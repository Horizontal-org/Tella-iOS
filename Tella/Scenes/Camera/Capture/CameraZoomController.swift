//
//  CameraZoomController.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation

final class CameraZoomController {
    
    // MARK: - Constants
    
    private static let rampRate: Float = 8.0
    
    // MARK: - Stored properties
    
    private var initialZoomFactor: CGFloat = 1.0
}

extension CameraZoomController {
    
    // MARK: - Pinch zoom
    
    func startZoom(device: AVCaptureDevice?) {
        if let device, device.isRampingVideoZoom {
            configure(device, errorMessage: "Unable to cancel the camera zoom ramp") {
                device.cancelVideoZoomRamp()
            }
        }
        initialZoomFactor = device?.videoZoomFactor ?? 1.0
    }
    
    
    func zoom(by pinchScale: CGFloat, device: AVCaptureDevice) -> CGFloat {
        configure(device, errorMessage: "Unable to configure the camera zoom") {
            device.videoZoomFactor = clampedZoomFactor(initialZoomFactor * pinchScale, for: device)
        }
        return displayedZoomFactor(for: device)
    }
    
    // MARK: - Preset zoom
    
    func setZoom(to level: CameraZoomLevel, device: AVCaptureDevice) -> CGFloat {
        let multiplier = displayMultiplier(for: device)
        // Presets use displayed zoom; AVFoundation expects device zoom.
        let zoomFactor = clampedZoomFactor(level.factor / multiplier, for: device)
        
        let didConfigure = configure(device, errorMessage: "Unable to configure the camera zoom") {
            device.cancelVideoZoomRamp()
            device.ramp(toVideoZoomFactor: zoomFactor, withRate: Self.rampRate)
        }
        return didConfigure ? zoomFactor * multiplier : displayedZoomFactor(for: device)
    }
    
    
    func applyDefaultZoom(device: AVCaptureDevice) -> CGFloat {
        configure(device, errorMessage: "Unable to reset the camera zoom") {
            device.videoZoomFactor = clampedZoomFactor(1.0 / displayMultiplier(for: device), for: device)
        }
        return displayedZoomFactor(for: device)
    }
    
    // MARK: - Displayed zoom
    
    func availableZoomLevels(device: AVCaptureDevice?) -> [CameraZoomLevel] {
        guard let device else { return [] }
        
        let multiplier = displayMultiplier(for: device)
        let lowest = device.minAvailableVideoZoomFactor * multiplier
        let highest = maximumZoomFactor(for: device) * multiplier
        
        return CameraZoomLevel.candidates
            .filter { $0 >= lowest && $0 <= highest }
            .map { CameraZoomLevel(factor: $0) }
    }
    
    func displayedZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        device.videoZoomFactor * displayMultiplier(for: device)
    }
}

private extension CameraZoomController {
    
    // MARK: - Zoom scale conversion
    
    func displayMultiplier(for device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *), device.displayVideoZoomFactorMultiplier > 0 {
            return device.displayVideoZoomFactorMultiplier
        }
        
        // On older systems, use the first lens switch-over value to display the wide lens as 1x.
        guard device.constituentDevices.first?.deviceType == .builtInUltraWideCamera,
              let wideLensFactor = device.virtualDeviceSwitchOverVideoZoomFactors.first else {
            return 1.0
        }
        return 1.0 / CGFloat(truncating: wideLensFactor)
    }
    
    // MARK: - Zoom limits
    
    func clampedZoomFactor(_ factor: CGFloat, for device: AVCaptureDevice) -> CGFloat {
        max(device.minAvailableVideoZoomFactor, min(factor, maximumZoomFactor(for: device)))
    }
    
    func maximumZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *),
           let range = device.activeFormat.systemRecommendedVideoZoomRange {
            return min(range.upperBound, device.maxAvailableVideoZoomFactor)
        }
        
        let longestLensZoomFactor = device.virtualDeviceSwitchOverVideoZoomFactors.last
            .map { CGFloat(truncating: $0) } ?? 1.0
        return min(longestLensZoomFactor * 5.0, device.maxAvailableVideoZoomFactor)
    }
    
    // MARK: - Device configuration
    
    @discardableResult
    func configure(_ device: AVCaptureDevice, errorMessage: String, _ body: () -> Void) -> Bool {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            body()
            return true
        } catch {
            debugLog("\(errorMessage): \(error.localizedDescription)")
            return false
        }
    }
}
