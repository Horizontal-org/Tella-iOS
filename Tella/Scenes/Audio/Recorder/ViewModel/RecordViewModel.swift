//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

class RecordViewModel: ObservableObject {
    
    @Published var state: RecordState = .ready
    @Published var fileName: String = ""
    @Published var time: String = ""
    @Published var shouldShowSettingsAlert: Bool = false

    private var audioBackend: RecordingAudioManager
    private var cancellable: Set<AnyCancellable> = []

    init(mainAppModel: MainAppModel, rootFile: VaultFile) {
        audioBackend = RecordingAudioManager(mainAppModel: mainAppModel, rootFile: rootFile)
        
        audioBackend.currentTime.sink { value in
            self.time = value.stringFromTimeInterval()
        }.store(in: &cancellable)
        
        self.fileName = self.initialFileName
        
        audioBackend.$audioPermission.sink { permission in
            switch permission {
            case .notDetermined:
                break
            case .authorized:
                self.onStartRecording()
            case .denied, .restricted:
                self.shouldShowSettingsAlert = true
            }
        }.store(in: &cancellable)
    }
    
    // Record audio
    func checkCameraAccess() {
        audioBackend.checkMicrophonePermission()
    }
    
    func onStartRecording() {
        
        self.state = .recording
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.002) {
            self.audioBackend.startRecording()
            self.updateView()
        }
    }
    
    func onPauseRecord() {
        
        self.audioBackend.pauseRecording()
        
        self.state = .paused
        
        self.updateView()
        
    }
    
    func onResumeRecording() {
        
        self.state = .recording
        
        self.audioBackend.startRecording()
        
        self.updateView()
    }
    
    func onStopRecording() {
        
        if self.state == .recording {
            self.audioBackend.pauseRecording()
        }
        
        self.state = .ready
        
        self.audioBackend.stopRecording(fileName: fileName)
        
        self.fileName = self.initialFileName
        
        self.updateView()
    }
    
    func onResetRecording() {
        self.audioBackend.resetRecorder()
        
    }
    
    // Play audio
    func onPlayRecord() {
        self.audioBackend.playRecord()
    }
    
    func onStopRecord() {
        self.audioBackend.pauseRecord()
    }
    
    
    fileprivate func updateView() {
        self.objectWillChange.send()
    }
    
    /// - Returns: "Recording 2020.06.24-16.45"
    var initialFileName: String {
        return  LocalizableAudio.suffixRecordingName.localized + " " + Date().getFormattedDateString(format: DateFormat.fileName.rawValue)
    }
}
