//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public enum CameraType: Hashable {
    case image
    case video
}

public enum CameraFlashMode: Hashable {
    case auto
    case on
    case off
}

public enum SourceView: Hashable {
    case tab
    case addFile
    case addReportFile // For report
}
