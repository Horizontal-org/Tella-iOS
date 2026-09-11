//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum CameraState {
    case readyTakingImage
    case readyRecordingVideo
    case recordingVideo
}

extension CameraState {

    /// The capture mode the state belongs to, so the mode selector follows the state instead of tracking it separately.
    var cameraType: CameraType {
        self == .readyTakingImage ? .image : .video
    }

    var isRecording: Bool {
        self == .recordingVideo
    }

    init(cameraType: CameraType) {
        self = cameraType == .image ? .readyTakingImage : .readyRecordingVideo
    }
}
