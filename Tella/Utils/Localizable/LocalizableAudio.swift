//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableRecorder: String, LocalizableDelegate {
    
    case tabBar = "Recorder_TabBar"
    
    case appBar = "Recorder_AppBar"
    case suffixRecording = "Recorder_SuffixRecording"
    
    // Device Time Left
    case deviceTimeLeft = "Recorder_DeviceTimeLeft"
    case deviceTimeLeftDay = "Recorder_DeviceTimeLeft_Day"
    case deviceTimeLeftDays = "Recorder_DeviceTimeLeft_Days"
    case deviceTimeLeftHour = "Recorder_DeviceTimeLeft_Hour"
    case deviceTimeLeftHours = "Recorder_DeviceTimeLeft_Hours"
    case deviceTimeLeftMinutes = "Recorder_DeviceTimeLeft_Minutes"
    
    case audioRecordingsAppBar = "Recorder_AudioRecordings_AppBar"
    
    case saveRecordingSheetTitle = "Recorder_SaveRecording_SheetTitle"
    case saveRecordingSheetExpl = "Recorder_SaveRecording_SheetExpl"
    case saveRecordingCancelSheetAction = "Recorder_SaveRecording_Cancel_SheetAction"
    case saveRecordingDiscardSheetAction = "Recorder_SaveRecording_Discard_SheetAction"
    case saveRecordingSaveSheetAction = "Recorder_SaveRecording_Save_SheetAction"
    
    case renameRecordingSheetTitle = "Recorder_RenameRecording_SheetTitle"
    case renameRecordingCancelSheetAction = "Recorder_RenameRecording_Cancel_SheetAction"
    case renameRecordingSaveSheetAction = "Recorder_RenameRecording_Save_SheetAction"
    
    case audioRecordingSavedToast = "Recorder_AudioRecordingSaved_Toast"
    
    case deniedAudioPermissionExpl = "Recorder_DeniedAudioPermission_Expl"
    case deniedAudioPermissionActionSettings = "Recorder_DeniedAudioPermission_Action_Settings"
    case deniedAudioPermissionActionCancel = "Recorder_DeniedAudioPermission_Action_Cancel"
}
