//
//  CameraZoomController.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import AVFoundation

struct CameraZoomCapabilities {
    let range: ClosedRange<CGFloat>
    let levels: [CameraZoomLevel]
    let lenses: [CameraZoomLens]
}

final class CameraZoomController {
    
    // MARK: - Stored properties
    
    private var initialZoomFactor: CGFloat = 1.0
}

extension CameraZoomController {
    
    // MARK: - Pinch zoom
    
    func startZoom(device: AVCaptureDevice?) {
        initialZoomFactor = device?.videoZoomFactor ?? 1.0
    }
    
    func zoom(by pinchScale: CGFloat, device: AVCaptureDevice) {
        guard pinchScale.isFinite, pinchScale > 0 else { return }
        configure(device, errorMessage: "Unable to configure the camera zoom") {
            device.videoZoomFactor = clampedZoomFactor(initialZoomFactor * pinchScale, for: device)
        }
    }
    
    // MARK: - Zoom selection
    
    /// Applies the displayed zoom immediately for preset taps and dial adjustments.
    func setZoomFactor(to factor: CGFloat, device: AVCaptureDevice) {
        guard factor.isFinite else { return }
        configure(device, errorMessage: "Unable to configure the camera zoom") {
            // Convert to device zoom; assigning the factor also cancels any zoom ramp.
            device.videoZoomFactor = clampedZoomFactor(factor / displayMultiplier(for: device), for: device)
        }
    }
    
    func applyDefaultZoom(device: AVCaptureDevice) {
        setZoomFactor(to: 1, device: device)
    }
    
    // MARK: - Zoom state
    
    func displayedZoomFactor(for device: AVCaptureDevice) -> CGFloat {
        device.videoZoomFactor * displayMultiplier(for: device)
    }
    
    func zoomCapabilities(for device: AVCaptureDevice?) -> CameraZoomCapabilities {
        let range = availableZoomRange(device: device)
        let levels = device == nil
        ? []
        : CameraZoomLevel.candidates.filter(range.contains).map { CameraZoomLevel(factor: $0) }
        let lenses = zoomLenses(device: device).filter { range.contains($0.factor) }
        return CameraZoomCapabilities(range: range, levels: levels, lenses: lenses)
    }
}

private extension CameraZoomController {
    
    // MARK: - Zoom capabilities and display scale
    
    /// Displayed values differ from AVFoundation values on virtual ultra-wide cameras.
    func availableZoomRange(device: AVCaptureDevice?) -> ClosedRange<CGFloat> {
        guard let device else { return 1.0...1.0 }
        let multiplier = displayMultiplier(for: device)
        let lowest = device.minAvailableVideoZoomFactor * multiplier
        let highest = maximumZoomFactor(for: device) * multiplier
        return lowest...max(lowest, highest)
    }
    
    /// Physical lens landmarks use the virtual camera's display scale, not each lens's scale.
    func zoomLenses(device: AVCaptureDevice?) -> [CameraZoomLens] {
        guard let device else { return [] }
        let lenses = device.isVirtualDevice ? device.constituentDevices : [device]
        let rawFactors: [CGFloat] = device.isVirtualDevice
        ? [1] + device.virtualDeviceSwitchOverVideoZoomFactors.map { CGFloat(truncating: $0) }
        : [1]
        let multiplier = displayMultiplier(for: device)
        
        return zip(lenses, rawFactors).compactMap { lens, rawFactor in
            let factor = rawFactor * multiplier
            guard factor.isFinite, factor > 0 else { return nil }
            return CameraZoomLens(factor: factor, focalLength: nominalFocalLength(of: lens))
        }
    }
    
    func nominalFocalLength(of device: AVCaptureDevice) -> CGFloat? {
        guard #available(iOS 26.0, *) else { return nil }
        let nominal = CGFloat(device.nominalFocalLengthIn35mmFilm)
        return nominal.isFinite && nominal > 0 ? nominal : nil
    }
    
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
        let preferredMaximum: CGFloat
        if #available(iOS 18.0, *),
           let range = device.activeFormat.systemRecommendedVideoZoomRange {
            preferredMaximum = range.upperBound
        } else {
            // Older systems have no recommended range. Allow fivefold digital zoom beyond
            // the longest installed lens, using device factors until display conversion.
            let longestLensZoomFactor = device.virtualDeviceSwitchOverVideoZoomFactors.last
                .map { CGFloat(truncating: $0) } ?? 1.0
            preferredMaximum = longestLensZoomFactor * 5.0
        }
        return max(device.minAvailableVideoZoomFactor,
                   min(preferredMaximum, device.maxAvailableVideoZoomFactor))
    }
    
    // MARK: - Device configuration
    
    func configure(_ device: AVCaptureDevice, errorMessage: String, _ body: () -> Void) {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            body()
        } catch {
            debugLog("\(errorMessage): \(error.localizedDescription)")
        }
    }
}
