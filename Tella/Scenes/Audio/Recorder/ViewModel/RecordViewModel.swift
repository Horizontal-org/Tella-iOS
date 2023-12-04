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
//    @Published var shouldReloadVaultFiles = false

    //    @Published var showingRecoredrView: Bool = false
    var showingRecoredrView: Binding<Bool> = .constant(false)
    
    private var audioBackend: RecordingAudioManager
    private var cancellable: Set<AnyCancellable> = []
    var sourceView : SourceView = .tab
    
    private var mainAppModel: MainAppModel
    private var rootFile: VaultFileDB?
    private var resultFile: Binding<[VaultFileDB]?>?
    
    private var shouldReloadVaultFiles : Binding<Bool>?
    
    init(mainAppModel: MainAppModel,
         rootFile: VaultFileDB?,
         resultFile : Binding<[VaultFileDB]?>?,
         sourceView : SourceView,
         showingRecoredrView: Binding<Bool>,
         shouldReloadVaultFiles : Binding<Bool>?) {
        
        self.mainAppModel = mainAppModel
        self.rootFile = rootFile
        self.resultFile = resultFile
        self.shouldReloadVaultFiles = shouldReloadVaultFiles
        
        audioBackend = RecordingAudioManager()
        
        // Update the time
        audioBackend.currentTime.sink { value in
            self.time = value.stringFromTimeInterval()
        }.store(in: &cancellable)
        
        
        // Save the audio file and return the recorded file

        audioBackend.fileURL.sink { url in
            
            guard let url else { return }
            self.addVaultFile(fileURL: url)
        } .store(in: &self.cancellable)

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
    
    func addVaultFile(fileURL: URL) {

        mainAppModel.vaultFilesManager?.addVaultFile(filePaths: [fileURL], parentId: rootFile?.id)
                .sink { importVaultFileResult in
                    
                    switch importVaultFileResult {
                        
                    case .fileAdded(let vaultFiles):
                        guard let vaultFile = vaultFiles.first else { return  }
                        self.handleSuccessAddingFiles(vaultFile: vaultFile)
                    case .importProgress:
                        break
                    }
                    
                }.store(in: &self.cancellable)
    }
    
    private func handleSuccessAddingFiles(vaultFile:VaultFileDB) {
        self.updateResultFile(vaultFile: vaultFile)
        self.sendAutoReport(vaultFile: vaultFile)
        DispatchQueue.main.async {
            self.resetRecording()
        }
    }

    private func sendAutoReport(vaultFile:VaultFileDB)  {
        if self.sourceView != .addReportFile {
            self.mainAppModel.sendAutoReportFile(file: vaultFile)
        }
    }
    
    private func updateResultFile(vaultFile:VaultFileDB)  {
        DispatchQueue.main.async {
            self.resultFile?.wrappedValue = [vaultFile]
            self.shouldReloadVaultFiles?.wrappedValue = true
        }
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
        
        self.audioBackend.stopRecording(fileName: fileName)
    }
    
    private func resetRecording() {
        self.state = .ready
        
        self.fileName = self.initialFileName
        
        self.updateView()
    }
    
    func onDiscardRecording() {
        self.audioBackend.discardRecord()
        
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
