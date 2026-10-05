//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import CoreGraphics

public enum CameraType: Hashable {
    case image
    case video
}

extension CameraType {
    
    var title: String {
        switch self {
        case .image:
            return LocalizableCamera.tabTitlePhoto.localized
        case .video:
            return LocalizableCamera.tabTitleVideo.localized
        }
    }
}

/// The direction of a one finger swipe across the viewfinder, used to move between capture modes.
public enum CameraSwipeDirection {
    case left
    case right
    
    static let threshold: CGFloat = 40
    
    var cameraType: CameraType {
        switch self {
        case .left:
            return .image
        case .right:
            return .video
        }
    }
    
    init?(translationX: CGFloat, translationY: CGFloat) {
        guard abs(translationX) > Self.threshold,
              abs(translationX) > abs(translationY) else { return nil }
        self = translationX < 0 ? .left : .right
    }
}

public enum CameraFlashMode: Hashable {
    case auto
    case on
    case off
    
    var next: CameraFlashMode {
        switch self {
        case .off:
            return .on
        case .on:
            return .auto
        case .auto:
            return .off
        }
    }
    
    var imageName: ImageResource {
        switch self {
        case .off:
            return .cameraFlashOff
        case .on:
            return .cameraFlashOn
        case .auto:
            return .cameraFlashAuto
        }
    }
    
    var title: String {
        switch self {
        case .off:
            return LocalizableCamera.flashOff.localized
        case .on:
            return LocalizableCamera.flashOn.localized
        case .auto:
            return LocalizableCamera.flashAuto.localized
        }
    }
}

public enum SourceView: Hashable {
    case tab
    case addFile
    case addReportFile // For report
}
