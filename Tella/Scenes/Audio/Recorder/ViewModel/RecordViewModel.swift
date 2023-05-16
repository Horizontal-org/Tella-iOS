//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

class RecordViewModel: ObservableObject {
    
    @Published var state: RecordState = .ready
    @Published var fileName: String = ""
    @Published var time: String = ""
    @Published var shouldShowSettingsAlert: Bool = false
    //    @Published var showingRecoredrView: Bool = false
    var showingRecoredrView: Binding<Bool> = .constant(false)
    
    private var audioBackend: RecordingAudioManager
    private var cancellable: Set<AnyCancellable> = []
    var sourceView : SourceView = .tab
    
    
    init(mainAppModel: MainAppModel,
         rootFile: VaultFile,
         resultFile : Binding<[VaultFile]?>?,
         sourceView : SourceView,
         showingRecoredrView: Binding<Bool> ) {
        
        audioBackend = RecordingAudioManager()
        
        // Update the time
        audioBackend.currentTime.sink { value in
            self.time = value.stringFromTimeInterval()
        }.store(in: &cancellable)
        
        
        // Save the audio file and return the recorded file
        audioBackend.fileURL.sink { value in
            guard let value else { return }
            Task {
                do {
                    guard let file = try await mainAppModel.add(audioFilePath: value, to: rootFile, type: .audio, fileName: self.fileName) else {return}
                    DispatchQueue.main.async {
                        resultFile?.wrappedValue = [file]
                    }
                        
                    mainAppModel.sendAutoReportFile(file: file)
 
                }
            }
        }.store(in: &cancellable)
        
        
        // Init the file name
        self.fileName = self.initialFileName
        
        // Init the source view
        self.sourceView = sourceView
        self.showingRecoredrView = showingRecoredrView
        
        // Update the view while updating the permission
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
        DispatchQueue.main.async {
            self.state = .recording
        }
        
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
        return  LocalizableRecorder.suffixRecording.localized + " " + Date().getFormattedDateString(format: DateFormat.fileName.rawValue)
    }
}
