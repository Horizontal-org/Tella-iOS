//
//  CameraZoomLevel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import CoreGraphics

struct CameraZoomLevel: Identifiable, Hashable {
    
    /// The levels the camera offers, kept only when the installed lenses can reach them.
    static let candidates: [CGFloat] = [0.5, 1, 2]
    
    let factor: CGFloat
    
    var id: CGFloat { factor }
}

extension CameraZoomLevel {
    
    /// Zooming lands slightly off the requested factor, so a level still counts as reached within this margin.
    private static let tolerance: CGFloat = 0.05
    
    /// ".5", "1", "2" — shown while the level is not the active one.
    var title: String {
        CameraZoomLevel.title(for: factor)
    }
    
    /// The level a zoom factor sits in: the highest one it has reached.
    static func active(for factor: CGFloat, in levels: [CameraZoomLevel]) -> CameraZoomLevel? {
        levels.last { factor + tolerance >= $0.factor } ?? levels.first
    }
    
    /// "1x", "1.7x" — shown on the active level, so pinching reads as a precise factor.
    static func activeTitle(for factor: CGFloat) -> String {
        title(for: factor) + "x"
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
