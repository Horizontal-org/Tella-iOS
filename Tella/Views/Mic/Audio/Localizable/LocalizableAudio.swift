//
//  LocalizableAudio.swift
//  Tella
//
//  Created by Amine Info on 4/2/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableAudio: String, LocalizableDelegate {
    
    case recorderTitle = "AudioRecorderTitle"
    
    case  saveRecordingTitle = "AudioSaveRecordingTitle"
    case  saveRecordingMessage = "AudioSaveRecordingMessage"

    var tableName: String? {
        return "Audio"
    }
}


