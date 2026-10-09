//
//  CameraAspectRatio.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import CoreGraphics
import ImageIO
import UIKit

enum CameraAspectRatio: Hashable, CaseIterable {
    case threeByFour
    case nineBySixteen
    case oneByOne
    case full
    
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
    
    static func cropped(_ image: CGImage,
                        orientation: CGImagePropertyOrientation,
                        portraitAspectRatio: CGFloat) -> CGImage {
        let upright = image.oriented(to: orientation) ?? image
        // Ratios are presented in portrait, but captures follow the device orientation.
        // Check the normalized pixels so rotated and mirrored metadata behave alike.
        let aspect = upright.width > upright.height ? 1 / portraitAspectRatio : portraitAspectRatio
        return upright.centerCropped(to: aspect) ?? upright
    }
}

/// Shared geometry keeps photo framing independent of the fixed control rows.
struct CameraViewfinderLayout {
    static let headerHeight: CGFloat = 56
    static let zoomHeight: CGFloat = 52
    static let shutterHeight: CGFloat = 85
    static let modeHeight: CGFloat = 60

    let headerFrame: CGRect
    let zoomFrame: CGRect
    let shutterFrame: CGRect
    let modeFrame: CGRect
    let previewFrame: CGRect
    let optionsFrame: CGRect
    let overlaysHeader: Bool
    let overlaysZoom: Bool
    let overlaysShutter: Bool
    let overlaysMode: Bool

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

private extension CGImagePropertyOrientation {
    var uiImageOrientation: UIImage.Orientation {
        switch self {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        }
    }
}

private extension CGImage {
    func oriented(to orientation: CGImagePropertyOrientation) -> CGImage? {
        let image = UIImage(cgImage: self, scale: 1, orientation: orientation.uiImageOrientation)
        if image.imageOrientation == .up { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }.cgImage
    }
    
    func centerCropped(to aspectRatio: CGFloat) -> CGImage? {
        let imageWidth = CGFloat(width)
        let imageHeight = CGFloat(height)
        let currentAspect = imageWidth / imageHeight
        
        guard abs(currentAspect - aspectRatio) > 0.01 else { return self }
        
        let cropRect: CGRect
        if currentAspect > aspectRatio {
            let cropWidth = imageHeight * aspectRatio
            cropRect = CGRect(x: (imageWidth - cropWidth) / 2,
                              y: 0,
                              width: cropWidth,
                              height: imageHeight)
        } else {
            let cropHeight = imageWidth / aspectRatio
            cropRect = CGRect(x: 0,
                              y: (imageHeight - cropHeight) / 2,
                              width: imageWidth,
                              height: cropHeight)
        }
        return cropping(to: cropRect.integral)
    }
}
