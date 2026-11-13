//
//  CameraAspectRatio.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import CoreGraphics
import UIKit

enum CameraAspectRatio: Hashable, CaseIterable {
    case threeByFour
    case nineBySixteen
    case oneByOne
    case full
    
    // MARK: - Display properties
    
    var title: String {
        switch self {
        case .threeByFour:
            return "3:4"
        case .nineBySixteen:
            return "9:16"
        case .oneByOne:
            return "1:1"
        case .full:
            return LocalizableCamera.aspectFull.localized
        }
    }
    
    var next: CameraAspectRatio {
        switch self {
        case .threeByFour:
            return .nineBySixteen
        case .nineBySixteen:
            return .oneByOne
        case .oneByOne:
            return .full
        case .full:
            return .threeByFour
        }
    }
    
    // MARK: - Framing
    
    /// Displayed width / height.
    var widthOverHeight: CGFloat {
        switch self {
        case .threeByFour:
            return 3.0 / 4.0
        case .nineBySixteen:
            return 9.0 / 16.0
        case .oneByOne:
            return 1.0
        case .full:
            // Full follows the portrait screen shape even when the device rotates.
            let screenBounds = UIScreen.main.bounds
            let width = min(screenBounds.width, screenBounds.height)
            let height = max(screenBounds.width, screenBounds.height)
            guard width > 0, height > 0 else { return CameraAspectRatio.nineBySixteen.widthOverHeight }
            return width / height
        }
    }
    
    func visibleRect(in bounds: CGRect) -> CGRect {
        guard bounds.width > 0, bounds.height > 0 else { return bounds }
        
        let aspect = widthOverHeight
        let boundsAspect = bounds.width / bounds.height
        if boundsAspect > aspect {
            let width = bounds.height * aspect
            return CGRect(x: bounds.midX - width / 2,
                          y: bounds.minY,
                          width: width,
                          height: bounds.height)
        }
        
        let height = bounds.width / aspect
        return CGRect(x: bounds.minX,
                      y: bounds.midY - height / 2,
                      width: bounds.width,
                      height: height)
    }
    
    // MARK: - Image cropping
    
    static func cropRect(width: Int, height: Int, portraitAspectRatio: CGFloat) -> CGRect {
        // A centered crop commutes with rotation and mirroring. Keep the capture's orientation tag.
        let aspectRatio = width > height ? 1 / portraitAspectRatio : portraitAspectRatio
        let cropWidth = min(width, max(1, Int((CGFloat(height) * aspectRatio).rounded())))
        let cropHeight = min(height, max(1, Int((CGFloat(width) / aspectRatio).rounded())))
        return CGRect(x: (width - cropWidth) / 2,
                      y: (height - cropHeight) / 2,
                      width: cropWidth,
                      height: cropHeight)
    }
}

// MARK: - Viewfinder layout

/// Shared geometry keeps photo framing independent of the fixed control rows.
struct CameraViewfinderLayout {
    static let headerHeight: CGFloat = 56
    static let zoomHeight: CGFloat = 52
    static let shutterHeight: CGFloat = 85
    static let modeHeight: CGFloat = 60
    
    let headerFrame: CGRect
    let zoomFrame: CGRect
    let zoomDialFrame: CGRect
    let shutterFrame: CGRect
    let modeFrame: CGRect
    let previewFrame: CGRect
    let sourceFrame: CGRect
    let optionsFrame: CGRect
    let overlaysHeader: Bool
    let overlaysZoom: Bool
    let overlaysShutter: Bool
    let overlaysMode: Bool
    
    var zoomDialBackgroundBottom: CGFloat {
        if overlaysMode { return previewFrame.maxY }
        return overlaysShutter ? shutterFrame.maxY : zoomDialFrame.maxY
    }
    
    init(bounds: CGRect,
         aspectRatio: CameraAspectRatio,
         safeAreaInsets: UIEdgeInsets = .zero) {
        let modeTop = max(bounds.minY, bounds.maxY - Self.modeHeight)
        let shutterTop = max(bounds.minY, modeTop - Self.shutterHeight)
        let zoomTop = max(bounds.minY, shutterTop - Self.zoomHeight)
        let headerBottom = min(bounds.minY + Self.headerHeight, zoomTop)
        
        func row(from top: CGFloat, to bottom: CGFloat) -> CGRect {
            CGRect(x: bounds.minX, y: top, width: max(0, bounds.width), height: max(0, bottom - top))
        }
        
        zoomFrame = row(from: zoomTop, to: shutterTop)
        shutterFrame = row(from: shutterTop, to: modeTop)
        modeFrame = row(from: modeTop, to: bounds.maxY)
        
        let available = row(from: headerBottom, to: zoomTop)
        let photoHeight = max(0, bounds.width) / CameraAspectRatio.threeByFour.widthOverHeight
        let fullWidthPhoto = row(from: shutterTop - photoHeight, to: shutterTop)
        let hasRoom = available.width > 0 && available.height > 0
        let photoWithZoom = hasRoom
        && fullWidthPhoto.minY >= headerBottom
        && fullWidthPhoto.minY <= zoomTop
        let photoFrame = photoWithZoom
        ? fullWidthPhoto
        : CameraAspectRatio.threeByFour.visibleRect(in: available)
        sourceFrame = photoFrame
        
        let expanded = aspectRatio == .nineBySixteen || aspectRatio == .full
        switch aspectRatio {
        case .threeByFour:
            previewFrame = photoFrame
        case .oneByOne:
            // Keep the square centered on the same scene as the approved 3:4 layout.
            previewFrame = aspectRatio.visibleRect(in: photoFrame)
        case .nineBySixteen:
            // Width is fixed to the device. Short screens clip the excess at the top,
            // while tall screens leave grey above the picture. Never add side gutters.
            let height = max(0, bounds.width) / aspectRatio.widthOverHeight
            previewFrame = row(from: modeTop - height, to: modeTop)
        case .full:
            previewFrame = row(from: bounds.minY - max(0, safeAreaInsets.top),
                               to: bounds.maxY + max(0, safeAreaInsets.bottom))
        }
        
        // The square preview ends above the fixed zoom row; keep the expanded dial inside it.
        zoomDialFrame = aspectRatio == .oneByOne
        ? CGRect(x: previewFrame.minX,
                 y: min(previewFrame.maxY, zoomFrame.maxY) - zoomFrame.height,
                 width: previewFrame.width, height: zoomFrame.height)
        : zoomFrame
        
        headerFrame = row(from: bounds.minY, to: headerBottom)
        overlaysHeader = expanded
        overlaysZoom = expanded || (aspectRatio == .threeByFour && photoWithZoom)
        overlaysShutter = expanded
        overlaysMode = aspectRatio == .full
        // Bottom menus replace the zoom controls and stay above the shutter.
        optionsFrame = row(from: max(headerFrame.maxY, previewFrame.minY),
                           to: shutterTop)
    }
}
