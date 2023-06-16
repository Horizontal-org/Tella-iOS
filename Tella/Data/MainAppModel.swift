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
    
    @Published var vaultManager: VaultManager = VaultManager(cryptoManager: CryptoManager.shared, fileManager: DefaultFileManager(), rootFileName: "root", containerPath: "Containers", progress: ImportProgress())
    
    @Published var selectedTab: Tabs = .home
    
    @UserDefaultsProperty(key: lockTimeoutStartDateKey) private var lockTimeoutStartDate: Date?
    
    @Published var shouldUpdateLanguage:Bool = true
    @Published var shouldSaveCurrentData: Bool = false
    @Published var shouldShowRecordingSecurityScreen: Bool = UIScreen.main.isCaptured
    @Published var shouldShowSecurityScreen: Bool = false
    @Published var appEnterInBackground: Bool = false
    @Published var importOption: ImportOption?
    
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    private var cancellable: Set<AnyCancellable> = []
    
    init() {
        loadData()
        //        UploadService.shared.initAutoUpload(mainAppModel: self)
        sendUnsentReports()
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.object(forKey: "com.tella.settings") as? Data,
           let settings = try? decoder.decode(SettingsModel.self, from: data) {
            self.settings = settings
        }
    }
    
    func saveSettings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "com.tella.settings")
        }
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
    
    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
    
    func add(files: [URL], to parentFolder: VaultFile?, type: TellaFileType, folderPathArray:[VaultFile] = []) async throws -> [VaultFile] {
        
        vaultManager.progress.progress.sink { [weak self] value in
            self?.publishUpdates()
        }.store(in: &cancellable)
        
        vaultManager.progress.progressFile.sink { [weak self] value in
            self?.publishUpdates()
        }.store(in: &cancellable)
        
        let files = try await self.vaultManager.importFile(files: files, to: parentFolder, type: type, folderPathArray: folderPathArray)
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
    
    func sendAutoReportFile(file: VaultFile) {
        //        if vaultManager.tellaData.getAutoUploadServer() != nil {
        //            UploadService.shared.addAutoUpload(file: file)
        //        }
    }
    
    func sendUnsentReports() {
        UploadService.shared.sendUnsentReports(mainAppModel: self)
    }
    
    func initFiles() -> AnyPublisher<Bool,Never> {
       return vaultManager.initFiles()
    }
    
    func initRoot() {
        vaultManager.initRoot()

    }

}

class SettingsModel: ObservableObject, Codable {
    
    @Published var offLineMode = false
    @Published var quickDelete: Bool = false
    @Published var deleteVault: Bool = false
    @Published var deleteForms: Bool = false
    @Published var deleteServerSettings: Bool = false
    @Published var showRecentFiles: Bool = false
    @Published var lockTimeout: LockTimeoutOption = .immediately
    @Published var screenSecurity: Bool = true
    
    enum CodingKeys: CodingKey {
        case offLineMode
        case quickDelete
        case deleteVault
        case deleteForms
        case deleteServerSettings
        case showRecentFiles
        case lockTimeout
        case screenSecurity
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offLineMode = try container.decode(Bool.self, forKey: .offLineMode)
        quickDelete = try container.decode(Bool.self, forKey: .quickDelete)
        deleteVault = try container.decode(Bool.self, forKey: .deleteVault)
        deleteForms = try container.decode(Bool.self, forKey: .deleteForms)
        deleteServerSettings = try container.decode(Bool.self, forKey: .deleteServerSettings)
        showRecentFiles = try container.decode(Bool.self, forKey: .showRecentFiles)
        
        let lockTimeoutString = try container.decode(String.self, forKey: .lockTimeout)
        lockTimeout = LockTimeoutOption(rawValue: lockTimeoutString) ?? .immediately
        screenSecurity = try container.decode(Bool.self, forKey: .screenSecurity)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offLineMode, forKey: .offLineMode)
        try container.encode(quickDelete, forKey: .quickDelete)
        try container.encode(deleteVault, forKey: .deleteVault)
        try container.encode(deleteForms, forKey: .deleteForms)
        try container.encode(deleteServerSettings, forKey: .deleteServerSettings)
        try container.encode(showRecentFiles, forKey: .showRecentFiles)
        try container.encode( lockTimeout.rawValue, forKey: .lockTimeout)
        try container.encode(screenSecurity, forKey: .screenSecurity)
    }
}

class VaultFileInfo {
    
    var vaultFile : VaultFile
    var data : Data
    var url : URL
    
    init(vaultFile: VaultFile, data: Data, url: URL) {
        self.vaultFile = vaultFile
        self.data = data
        self.url = url
    }
}
