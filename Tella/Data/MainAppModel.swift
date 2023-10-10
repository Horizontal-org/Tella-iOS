import SwiftUI
import Combine


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
    
    @Published var vaultManager :VaultManagerInterface = VaultManager()
    
    @Published var vaultFilesManager : VaultFilesManager?
    
    @Published var selectedTab: Tabs = .home
    
    @UserDefaultsProperty(key: lockTimeoutStartDateKey) private var lockTimeoutStartDate: Date?
    
    @Published var shouldSaveCurrentData: Bool = false
    @Published var shouldShowRecordingSecurityScreen: Bool = UIScreen.main.isCaptured
    @Published var shouldShowSecurityScreen: Bool = false
    @Published var appEnterInBackground: Bool = false
    @Published var importOption: ImportOption?
    @Published var shouldUpdateLanguage = true
    
    var networkMonitor : NetworkMonitor
    
    private var cancellable: Set<AnyCancellable> = []
    
    //MARK: - init -
    
    init(networkMonitor:NetworkMonitor) {
        self.networkMonitor = networkMonitor
        loadData()
        self.onSuccessLogin()
    }
    
    private func onSuccessLogin() {
        vaultManager.onSuccessLogin.sink(receiveValue: { key in
            self.vaultFilesManager = VaultFilesManager(key: key, vaultManager: self.vaultManager)
        }).store(in: &cancellable)
    }
    
    func initFiles() -> AnyPublisher<Bool,Never> {
        return Deferred {
            Future <Bool,Never> {  [weak self] promise in
                guard let self = self else { return }
                self.vaultManager.getFilesToMergeToDatabase()
                    .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                    .sink(receiveValue: { files in
                        self.saveFiles(files: files)
                        self.sendReports()
                        promise(.success(true))
                    }).store(in: &self.cancellable)
            }
        }.eraseToAnyPublisher()
    }
    
    private func saveFiles(files: [(VaultFileDB,String?)]) {
        do {
            try self.vaultFilesManager?.addVaultFiles(files: files)
            self.vaultManager.deleteRootFile()
        } catch (let error){
            debugLog(error)
        }
    }
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func resetData() {
        self.vaultFilesManager = nil
        self.selectedTab = .home
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
    
    func deleteAfterMaxAttempts() {
        resetSettings()
        vaultManager.deleteContainerDirectory()
    }
}

//MARK: - Lock Timeout -

extension MainAppModel {
    
    func saveLockTimeoutStartDate() {
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
    
    func initAutoUpload() {
        UploadService.shared.initAutoUpload(mainAppModel: self)
    }
    
    func sendReports() {
        UploadService.shared.initAutoUpload(mainAppModel: self)
        UploadService.shared.sendUnsentReports(mainAppModel: self)
    }
    
    func deleteReport(reportId:Int?) {
        UploadService.shared.cancelSendingReport(reportId: reportId)
        vaultManager.tellaData?.deleteReport(reportId: reportId)
    }
}

extension MainAppModel {
    static func stub() -> MainAppModel {
        return MainAppModel(networkMonitor: NetworkMonitor())
    }
}
