//
//  CameraStyle.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CameraStyle {
    
    struct Animations {
        
        
        /// How far the photo shutter shrinks before springing back.
        static let shutterDipScale: CGFloat = 0.78
        
        /// Photo shutter: shrink, then return to rest.
        static let shutterDip: TimeInterval = 0.1
        
        /// New capture growing out of the gallery button.
        static let galleryTransition: TimeInterval = 0.2
        
        /// Sliding the VIDEO / PHOTO , and fading when recording starts.
        static let modeChange: TimeInterval = 0.25
        
        /// Cropping the viewfinder between photo aspect ratios, matching the system Camera app.
        static let aspectRatio: TimeInterval = 0.35
        
        static let recording: TimeInterval = 0.2
        
        static let moreActions: TimeInterval = 0.2
        
        /// GRID ON / GRID OFF chips stay on screen, then fade.
        static let statusChip: TimeInterval = 2
    }
}
