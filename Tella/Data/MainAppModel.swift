//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

protocol AppModelFileManagerProtocol {
    
    func add(files: [URL], to parentFolder: VaultFile?, type: TellaFileType, folderPathArray:[VaultFile]) async throws -> [VaultFile]
    func add(audioFilePath: URL, to parentFolder: VaultFile?, type: TellaFileType, fileName:String, folderPathArray:[VaultFile]) async throws -> VaultFile?
    func add(folder: String, to parentFolder: VaultFile?, folderPathArray:[VaultFile])
    
    func move(files: [VaultFile], from originalParentFolder: VaultFile?, to newParentFolder: VaultFile?)
    func cancelImportAndEncryption()
    func delete(files: [VaultFile], from parentFolder: VaultFile?)
    func rename(file : VaultFile, parent: VaultFile?)
    func getFilesForShare(files: [VaultFile]) -> [Any]
    func clearTmpDirectory()
    func saveDataToTempFile(data:Data, pathExtension:String) -> URL?
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL?
    func load(files vaultFiles: [VaultFile]) -> [URL]
    func load(file vaultFile: VaultFile) -> Data?
    func loadFilesInfos(file vaultFile: VaultFile, offsetSize:Int ) -> VaultFileInfo?
    func sendAutoReportFile(file: VaultFile)
    func initFiles() -> AnyPublisher<Bool,Never>
    func initRoot()
    
}

let lockTimeoutStartDateKey = "LockTimeoutStartDate"

class MainAppModel: ObservableObject, AppModelFileManagerProtocol {
    
    
    enum Tabs: Hashable {
        case home
        case forms
        case camera
        case mic
    }
    
    enum ImportOption: CaseIterable {
        case keepOriginal
        case deleteOriginal
        var localizedValue: String {
            switch self {
            case .keepOriginal:
                return LocalizableVault.importDeleteKeepOriginal.localized
            case .deleteOriginal:
                return LocalizableVault.importDeleteDeleteOriginal.localized
            }
        }
    }
    
    @Published var settings: SettingsModel = SettingsModel()
    
    @Published var vaultManager: VaultManager = VaultManager()
    
    @Published var selectedTab: Tabs = .home
    
    @UserDefaultsProperty(key: lockTimeoutStartDateKey) private var lockTimeoutStartDate: Date?
    
    @Published var shouldSaveCurrentData: Bool = false
    @Published var shouldShowRecordingSecurityScreen: Bool = UIScreen.main.isCaptured
    @Published var shouldShowSecurityScreen: Bool = false
    @Published var appEnterInBackground: Bool = false
    @Published var importOption: ImportOption?
    var networkMonitor : NetworkMonitor
    
    @Published var shouldUpdateLanguage = true

    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(networkMonitor:NetworkMonitor) {
        self.networkMonitor = networkMonitor
        loadData()
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.object(forKey: "com.tella.settings") as? Data,
           let settings = try? decoder.decode(SettingsModel.self, from: data) {
            self.settings = settings
        }
    }
    
    func initFiles() -> AnyPublisher<Bool,Never> {
        return Deferred {
            Future <Bool,Never> {  [weak self] promise in
                guard let self = self else { return }
                self.vaultManager.initFiles()
                    .sink(receiveValue: { f in
                        self.sendReports()
                        promise(.success(f))
                    }).store(in: &self.cancellable)
                
            }
        }.eraseToAnyPublisher()
    }
    
    func initRoot() {
        vaultManager.initRoot()
        UploadService.shared.initAutoUpload(mainAppModel: self)
        
    }
    
    func resetVaultManager() {
        vaultManager.resetData()
        self.selectedTab = .home
    }
    
    func saveSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "com.tella.settings")
        }
    }
    
    func resetSettings() {
        settings.unlockAttempts = 0
        settings.deleteAfterFail = .off
        settings.quickDelete = false
        settings.offlineMode = false
        settings.deleteServerSettings = false
        settings.showRecentFiles = false
        settings.lockTimeout = .immediately
        settings.screenSecurity = true
        settings.deleteVault = false
        
        saveSettings()
    }
    
    func saveLockTimeoutStartDate()  {
        lockTimeoutStartDate = Date()
    }
    
    func shouldResetApp() -> Bool {
        guard let startDate = lockTimeoutStartDate else { return false }
        let elapsedTime = Date().timeIntervalSince(startDate)
        return  TimeInterval(self.settings.lockTimeout.time) <  elapsedTime
    }
    
    func removeAllFiles() {
        vaultManager.removeAllFiles()
        publishUpdates()
    }
    
    func deleteAfterMaxAttempts() {
        resetSettings()
        
        vaultManager.deleteContainerDirectory()
    }
    
    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
    
    @discardableResult
    func add(files: [URL], to parentFolder: VaultFile?, type: TellaFileType, folderPathArray:[VaultFile] = []) async throws -> [VaultFile] {
        
        vaultManager.progress.progress.sink { [weak self] value in
            self?.publishUpdates()
        }.store(in: &cancellable)
        
        vaultManager.progress.progressFile.sink { [weak self] value in
            self?.publishUpdates()
        }.store(in: &cancellable)
        
        let files = try await self.vaultManager.importFile(files: files, to: parentFolder, type: type, folderPathArray: folderPathArray) ?? []
        self.publishUpdates()
        return files
    }
    
    func add(audioFilePath: URL, to parentFolder: VaultFile?, type: TellaFileType, fileName:String, folderPathArray:[VaultFile] = []) async throws -> VaultFile? {
        let file = try await   self.vaultManager.importFile(audioFilePath: audioFilePath, to: parentFolder, type: type, fileName: fileName, folderPathArray: folderPathArray)
        self.publishUpdates()
        return file
        
    }
    
    func add(folder: String, to parentFolder: VaultFile?,  folderPathArray:[VaultFile] = []) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.createNewFolder(name: folder, parent: parentFolder, folderPathArray: folderPathArray)
            self.publishUpdates()
        }
    }
    
    func move( files: [VaultFile], from originalParentFolder: VaultFile?, to newParentFolder: VaultFile?) {
        self.vaultManager.move(files: files, from: originalParentFolder, to: newParentFolder)
    }
    
    func cancelImportAndEncryption() {
        self.vaultManager.shouldCancelImportAndEncryption.send(true)
    }
    
    func delete(files: [VaultFile], from parentFolder: VaultFile?) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.delete(files: files, parent: parentFolder)
            self.publishUpdates()
        }
    }
    
    func rename(file: VaultFile, parent: VaultFile?) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.rename(file: file, parent: parent)
            self.publishUpdates()
        }
    }
    
    func getFilesForShare(files: [VaultFile]) -> [Any] {
        return vaultManager.load(files: files)
    }
    
    //    func loadFilesInfos(files vaultFiles: [VaultFile], offsetSize :Int) -> [VaultFileInfo] {
    //        return vaultManager.loadFilesInfos(files: vaultFiles, offsetSize: offsetSize)
    //    }
    
    func loadFilesInfos(file vaultFile: VaultFile, offsetSize:Int ) -> VaultFileInfo? {
        return vaultManager.loadFilesInfos(file: vaultFile, offsetSize: offsetSize)
    }
    
    func saveDataToTempFile(data:Data, pathExtension:String) -> URL? {
        return vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension)
    }
    
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL? {
        return vaultManager.saveDataToTempFile(data: data, fileName: fileName, pathExtension: pathExtension)
    }
    
    func clearTmpDirectory() {
        vaultManager.clearTmpDirectory()
    }
    
    func load(files vaultFiles: [VaultFile]) -> [URL] {
        vaultManager.load(files: vaultFiles)
    }
    
    func load(file vaultFile: VaultFile) -> Data? {
        vaultManager.load(file: vaultFile)
    }
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    
}

///   MainAppModel extension contains the methods used to manage reports

extension MainAppModel {
    
    func sendAutoReportFile(file: VaultFile) {
        if vaultManager.tellaData?.getAutoUploadServer() != nil {
            UploadService.shared.addAutoUpload(file: file)
        }
    }
    
    func sendReports() {
        UploadService.shared.initAutoUpload(mainAppModel: self)
        UploadService.shared.sendUnsentReports(mainAppModel: self)
    }
    
    func deleteReport(reportId:Int?) {
        
        UploadService.shared.cancelSendingReport(reportId: reportId)
        
        do {
            try _ = vaultManager.tellaData?.deleteReport(reportId: reportId)
        } catch {
        }
    }
}

extension MainAppModel {
    static func stub() -> MainAppModel {
        return MainAppModel(networkMonitor: NetworkMonitor())
    }
}

