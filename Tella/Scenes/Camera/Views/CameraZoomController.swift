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
    
    private var initialZoomFactor: CGFloat = 1.0
    
    func startZoom(device: AVCaptureDevice?) {
        initialZoomFactor = device?.videoZoomFactor ?? 1.0
    }
    
    /// Applies the pinch scale to the zoom captured at gesture start, clamped to the allowed range.
    func zoom(
        by pinchScale: CGFloat,
        device: AVCaptureDevice
    ) -> CGFloat {
        
        let desiredZoomFactor = initialZoomFactor * pinchScale
        let clampedZoomFactor = max(
            device.minAvailableVideoZoomFactor,
            min(desiredZoomFactor, maximumZoomFactor(for: device))
        )
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            device.videoZoomFactor = clampedZoomFactor
            return displayedZoomFactor(for: device)
        } catch {
            return displayedZoomFactor(for: device)
        }
    }
    
    /// Resets the camera to the "1x" wide lens whenever a new input is installed
    func applyDefaultZoom(device: AVCaptureDevice) -> CGFloat {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            device.videoZoomFactor = defaultZoomFactor(for: device)
        } catch {}
        
        return 1.0
    }
    
    /// Max zoom: the system's recommended range on iOS 18+, otherwise 5x the longest lens like the native Camera app
    private func maximumZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *),
           let range = device.activeFormat.systemRecommendedVideoZoomRange {
            return min(
                range.upperBound,
                device.maxAvailableVideoZoomFactor
            )
        }
        
        let longestLensZoomFactor =
        device.virtualDeviceSwitchOverVideoZoomFactors.last
            .map { CGFloat(truncating: $0) } ?? 1.0
        
        return min(
            longestLensZoomFactor * 5.0,
            device.maxAvailableVideoZoomFactor
        )
    }
    /// Converts the zoom factor into the user facing value, so the wide lens reads as 1x.
    private func displayedZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *) {
            return device.videoZoomFactor *
            device.displayVideoZoomFactorMultiplier
        }
        
        return device.videoZoomFactor / defaultZoomFactor(for: device)
    }
    
    /// The device's internal zoom factor for the main wide lens (what the user sees as "1x").
    private func defaultZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        guard
            device.constituentDevices.first?.deviceType == .builtInUltraWideCamera,
            let wideLensFactor = device.virtualDeviceSwitchOverVideoZoomFactors.first
        else {
            return 1.0
        }
        
        return CGFloat(truncating: wideLensFactor)
    }
}
