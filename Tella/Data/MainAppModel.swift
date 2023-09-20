import SwiftUI
import Combine

protocol AppModelFileManagerProtocol {
    
//    func add(files: [URL], to parentFolder: VaultFileDB?, type: TellaFileType, folderPathArray:[VaultFileDB]) async throws -> [VaultFileDB]
//    func add(audioFilePath: URL, to parentFolder: VaultFileDB?, type: TellaFileType, fileName:String, folderPathArray:[VaultFileDB]) async throws -> VaultFileDB?
//    func add(folder: String, to parentFolder: VaultFileDB?, folderPathArray:[VaultFileDB])
//
//    func move(files: [VaultFileDB], from originalParentFolder: VaultFileDB?, to newParentFolder: VaultFileDB?)
//    func cancelImportAndEncryption()
//    func delete(files: [VaultFileDB], from parentFolder: VaultFileDB?)
//    func rename(file : VaultFileDB, parent: VaultFileDB?)
//    func getFilesForShare(files: [VaultFileDB]) -> [Any]
//    func clearTmpDirectory()
//    func saveDataToTempFile(data:Data, pathExtension:String) -> URL?
//    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL?
//    func load(files vaultFiles: [VaultFileDB]) -> [URL]
//    func load(file vaultFile: VaultFileDB) -> Data?
//    func loadFilesInfos(file vaultFile: VaultFileDB, offsetSize:Int ) -> VaultFileInfo?
//    func sendAutoReportFile(file: VaultFileDB)
//    func initFiles() -> AnyPublisher<Bool,Never>
//    func initRoot()
    
    
    func sendAutoReportFile(file: VaultFileDB)

    
    
    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
    func addFolderFile(name:String, parentId: String?)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
//    func delete(files: [VaultFileDB])
//    func delete(filesIds: [String])
    
    func loadFileData(fileName: String?) -> Data?
    func loadVaultFilesToURL(files vaultFiles: [VaultFileDB]) -> [URL]
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL?

    func loadFilesInfos(file vaultFile: VaultFileDB, offsetSize:Int ) -> VaultFileInfo?
    func saveDataToTempFile(data: Data, pathExtension:String) -> URL?
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL?
    func createTempFileURL(pathExtension: String) -> URL

    func clearTmpDirectory()
    func deleteAfterMaxAttempts()
    func resetVaultManager()
    func removeAllFiles()

    
}

let lockTimeoutStartDateKey = "LockTimeoutStartDate"

class MainAppModel: ObservableObject {
    
    
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
    @Published var shouldUpdateLanguage = true

    var networkMonitor : NetworkMonitor

    //    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    private var cancellable: Set<AnyCancellable> = []

    //MARK: - init -
    
    init(networkMonitor:NetworkMonitor) {
        self.networkMonitor = networkMonitor
        loadData()
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

    func publishUpdates() { //TODO: Dhekra to check
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}


//MARK: - Settings -

extension MainAppModel {

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
        settings.showUnlockAttempts = false
        
        saveSettings()
    }

}

 //MARK: - Lock Timeout -

extension MainAppModel {
   
    func saveLockTimeoutStartDate()  {
        lockTimeoutStartDate = Date()
    }
    
    func shouldResetApp() -> Bool {
        guard let startDate = lockTimeoutStartDate else { return false }
        let elapsedTime = Date().timeIntervalSince(startDate)
        return  TimeInterval(self.settings.lockTimeout.time) <  elapsedTime
    }

    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
}


//MARK: - Manage reports -

extension MainAppModel {
    
    func sendAutoReportFile(file: VaultFileDB) {
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


extension MainAppModel :  AppModelFileManagerProtocol {

    func addFolderFile(name: String, parentId: String?) {
        vaultManager.addFolderFile(name: name, parentId: parentId)
    }
    
    
    func loadFileData(fileName: String?) -> Data? {
       return vaultManager.loadFileData(fileName: fileName)
    }
    
    func loadVaultFilesToURL(files vaultFiles: [VaultFileDB]) -> [URL] {
       return vaultManager.loadVaultFilesToURL(files: vaultFiles)
    }
    
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL? {
        return vaultManager.loadVaultFileToURL(file: vaultFile)
    }
    
    func createTempFileURL(pathExtension: String) -> URL {
        return vaultManager.createTempFileURL(pathExtension: pathExtension)
    }
    
    func saveDataToTempFile(data:Data, pathExtension:String) -> URL? {
        return vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension)
    }
    
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL? {
        return vaultManager.saveDataToTempFile(data: data, fileName: fileName, pathExtension: pathExtension)
    }

    func deleteAfterMaxAttempts() {
        resetSettings()
        vaultManager.deleteContainerDirectory()
    }

    func resetVaultManager() {
        vaultManager.resetData()
        self.selectedTab = .home
    }

    func removeAllFiles() {
        vaultManager.removeAllFiles()
        publishUpdates()
    }
    
    func clearTmpDirectory() {
        vaultManager.clearTmpDirectory()
    }

//    func load(file vaultFile: VaultFileDB) -> Data? {
//        return vaultManager.loadFileData(fileName: vaultFile.id)
//    }
    
    func loadFilesInfos(file vaultFile: VaultFileDB, offsetSize:Int ) -> VaultFileInfo? {
        return vaultManager.loadFilesInfos(file: vaultFile, offsetSize: offsetSize)
    }

    func cancelImportAndEncryption() {
        self.vaultManager.shouldCancelImportAndEncryption.send(true)
    }
}

extension MainAppModel {
    static func stub() -> MainAppModel {
        return MainAppModel(networkMonitor: NetworkMonitor())
    }
}
