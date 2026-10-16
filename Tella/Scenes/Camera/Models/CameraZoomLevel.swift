//
//  CameraZoomLevel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct CameraZoomLevel: Identifiable, Hashable {
    
    /// The levels the camera offers, kept only when the installed lenses can reach them.
    static let candidates: [CGFloat] = [0.5, 1, 2]
    
    let factor: CGFloat
    
    var id: CGFloat { factor }
}

// MARK: - Zoom presets

extension CameraZoomLevel {
    
    /// Zooming lands slightly off the requested factor, so a level still counts as reached within this margin.
    private static let tolerance: CGFloat = 0.05
    
    /// ".5", "1", "2" — the fixed label for each zoom preset.
    var title: String {
        CameraZoomLevel.title(for: factor)
    }
    
    /// Select a preset only while the camera is at its zoom factor.
    static func active(for factor: CGFloat, in levels: [CameraZoomLevel]) -> CameraZoomLevel? {
        levels.first { abs(factor - $0.factor) <= tolerance }
    }
    
    private static func title(for factor: CGFloat) -> String {
        let rounded = (factor * 10).rounded() / 10
        
        // ".5" rather than "0.5", to keep the label inside the pill.
        if rounded < 1 {
            return String(format: "%.1f", rounded).replacingOccurrences(of: "0.", with: ".")
        }
        
        return rounded.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(rounded))
        : String(format: "%.1f", rounded)
    }
}

// MARK: - Lens landmarks

/// A physical lens landmark and its nominal 35mm-equivalent focal length, when available.
struct CameraZoomLens: Equatable {
    let factor: CGFloat
    let focalLength: CGFloat?
    
    var focalLengthTitle: String? {
        guard let focalLength, focalLength.isFinite, focalLength > 0 else { return nil }
        return String(format: "%.0fMM", Double(focalLength))
    }
}

// MARK: - Dial scale

/// A logarithmic scale keeps each doubling of the camera's zoom equally spaced on the dial.
struct CameraZoomScale {
    private static let radiansPerLogUnit: CGFloat = 0.68
    private static let tickStep: CGFloat = 0.1
    
    let range: ClosedRange<CGFloat>
    
    init(range: ClosedRange<CGFloat>) {
        let minimum = range.lowerBound.isFinite && range.lowerBound > 0 ? range.lowerBound : 1
        let maximum = range.upperBound.isFinite && range.upperBound >= minimum ? range.upperBound : minimum
        self.range = minimum...maximum
    }
    
    // MARK: - Zoom conversion
    
    func clampedFactor(_ factor: CGFloat) -> CGFloat {
        guard !factor.isNaN else { return range.lowerBound }
        return min(max(factor, range.lowerBound), range.upperBound)
    }
    
    /// The mark's angular offset from the fixed selection indicator.
    func angle(for factor: CGFloat, relativeTo current: CGFloat) -> CGFloat {
        (logarithm(clampedFactor(factor)) - logarithm(clampedFactor(current))) * Self.radiansPerLogUnit
    }
    
    /// Rotating the wheel moves its marks past the indicator in the opposite direction.
    func factor(from initial: CGFloat, angleDelta: CGFloat) -> CGFloat {
        let initial = clampedFactor(initial)
        guard !angleDelta.isNaN else { return initial }
        let logarithmicFactor = logarithm(initial) - angleDelta / Self.radiansPerLogUnit
        if logarithmicFactor <= logarithmicMinimum { return range.lowerBound }
        if logarithmicFactor >= logarithm(range.upperBound) { return range.upperBound }
        return clampedFactor(exponential(logarithmicFactor))
    }
    
    // MARK: - Dial ticks and labels
    
    /// Equal zoom increments grow denser as zoom increases around the logarithmic wheel.
    var tickFactors: [CGFloat] {
        guard range.lowerBound < range.upperBound else { return [range.lowerBound] }
        let ticksPerFactor = 1 / Self.tickStep
        let firstIndex = floor(range.lowerBound * ticksPerFactor) + 1
        let interiorCount = ceil(range.upperBound * ticksPerFactor) - firstIndex
        // Protect allocation and integer conversion even for an unexpectedly large range.
        guard interiorCount.isFinite, interiorCount > 0, interiorCount <= 10_000 else {
            return [range.lowerBound, range.upperBound]
        }
        let interior = (0..<Int(interiorCount)).compactMap { offset -> CGFloat? in
            let factor = (firstIndex + CGFloat(offset)) / ticksPerFactor
            guard factor > range.lowerBound, factor < range.upperBound else { return nil }
            return factor
        }
        return [range.lowerBound] + interior + [range.upperBound]
    }
    
    /// The installed lenses and camera limits move around the wheel with their own labels.
    func labelFactors(for lenses: [CameraZoomLens]) -> [CGFloat] {
        let factors = ([range.lowerBound, range.upperBound] + lenses.map(\.factor).filter(range.contains)).sorted()
        var unique: [CGFloat] = []
        for factor in factors where unique.last.map({ abs($0 - factor) > 0.001 }) ?? true {
            unique.append(factor)
        }
        return unique
    }
    
    /// Dial labels retain the leading zero; the compact preset pills have their own format.
    func zoomTitle(for factor: CGFloat) -> String {
        let title = String(format: "%.1f", Double(clampedFactor(factor)))
        return title.hasSuffix(".0") ? String(title.dropLast(2)) : title
    }
    
    /// The focal caption follows the same displayed precision as the selected zoom number.
    func selectedLens(for factor: CGFloat, in lenses: [CameraZoomLens]) -> CameraZoomLens? {
        let title = zoomTitle(for: factor)
        return lenses.first { range.contains($0.factor) && zoomTitle(for: $0.factor) == title }
    }
    
    // MARK: - Scale helpers
    
    private var logarithmicMinimum: CGFloat { logarithm(range.lowerBound) }
    
    private func logarithm(_ factor: CGFloat) -> CGFloat {
        CGFloat(log(Double(factor)))
    }
    
    private func exponential(_ value: CGFloat) -> CGFloat {
        CGFloat(exp(Double(value)))
    }
}
