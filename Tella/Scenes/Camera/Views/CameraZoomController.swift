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
    
    private static let rampRate: Float = 8.0
    
    private var initialZoomFactor: CGFloat = 1.0
    
    func startZoom(device: AVCaptureDevice?) {
        if let device = device, device.isRampingVideoZoom {
            cancelZoomRamp(device: device)
        }
        
        initialZoomFactor = device?.videoZoomFactor ?? 1.0
    }
    
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
    
    /// The fixed zoom levels the installed lenses can reach, in user facing values.
    func availableZoomLevels(device: AVCaptureDevice?) -> [CameraZoomLevel] {
        guard let device = device else { return [] }
        
        let lowest = displayedZoomFactor(forDeviceFactor: device.minAvailableVideoZoomFactor,
                                         device: device)
        let highest = displayedZoomFactor(forDeviceFactor: maximumZoomFactor(for: device),
                                          device: device)
        
        return CameraZoomLevel.candidates
            .filter { $0 >= lowest && $0 <= highest }
            .map { CameraZoomLevel(factor: $0) }
    }
    
    /// Ramps to one of the fixed zoom levels, returning the user facing factor it settles on.
    func setZoom(to level: CameraZoomLevel, device: AVCaptureDevice) -> CGFloat {
        let desiredZoomFactor = deviceZoomFactor(forDisplayedFactor: level.factor, device: device)
        let clampedZoomFactor = max(
            device.minAvailableVideoZoomFactor,
            min(desiredZoomFactor, maximumZoomFactor(for: device))
        )
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            
            device.cancelVideoZoomRamp()
            device.ramp(toVideoZoomFactor: clampedZoomFactor, withRate: Self.rampRate)
        } catch {}
        
        return displayedZoomFactor(forDeviceFactor: clampedZoomFactor, device: device)
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
        displayedZoomFactor(forDeviceFactor: device.videoZoomFactor, device: device)
    }
    
    private func displayedZoomFactor(forDeviceFactor deviceFactor: CGFloat,
                                     device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *) {
            return deviceFactor * device.displayVideoZoomFactorMultiplier
        }
        
        return deviceFactor / defaultZoomFactor(for: device)
    }
    
    /// The reverse of `displayedZoomFactor(forDeviceFactor:device:)`, for zooming to a requested level.
    private func deviceZoomFactor(forDisplayedFactor displayedFactor: CGFloat,
                                  device: AVCaptureDevice) -> CGFloat {
        if #available(iOS 18.0, *) {
            let multiplier = device.displayVideoZoomFactorMultiplier
            guard multiplier > 0 else { return displayedFactor }
            
            return displayedFactor / multiplier
        }
        
        return displayedFactor * defaultZoomFactor(for: device)
    }
    
    private func cancelZoomRamp(device: AVCaptureDevice) {
        guard (try? device.lockForConfiguration()) != nil else { return }
        defer { device.unlockForConfiguration() }
        
        device.cancelVideoZoomRamp()
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
