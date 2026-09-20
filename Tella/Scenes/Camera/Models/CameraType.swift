//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

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
}

public enum CameraFlashMode: Hashable {
    case auto
    case on
    case off
    
    var next: CameraFlashMode {
        switch self {
        case .auto:
            return .on
        case .on:
            return .off
        case .off:
            return .auto
        }
    }
}

public enum SourceView: Hashable {
    case tab
    case addFile
    case addReportFile // For report
}
