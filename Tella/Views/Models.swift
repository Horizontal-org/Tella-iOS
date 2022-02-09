//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

protocol AppModelFileManagerProtocol {
    
    func add(files: [URL], to parentFolder: VaultFile?, type: FileType)
    func add(audioFilePath: URL, to parentFolder: VaultFile?, type: FileType, fileName:String)

    func add(image: UIImage, to parentFolder: VaultFile?, type: FileType, pathExtension:String)
    func add(folder: String, to parentFolder: VaultFile?)
    func cancelImportAndEncryption()
    func delete(file: VaultFile, from parentFolder: VaultFile?)
    func rename(file : VaultFile, parent: VaultFile?)
    func getFilesForShare(files: [VaultFile]) -> [Any]
}

class MainAppModel: ObservableObject, AppModelFileManagerProtocol {
    
    enum Tabs: Hashable {
        case home
        case forms
        case reports
        case camera
        case mic
    }
    
    @Published var settings: SettingsModel = SettingsModel()
    @Published var vaultManager: VaultManager = VaultManager(cryptoManager: CryptoManager.shared, fileManager: DefaultFileManager(), rootFileName: "root", containerPath: "Containers", progress: ImportProgress())
    
    @Published var selectedTab: Tabs = .home
    
    @Published var selectedType: FileType = .other
    @Published var showFilesList: Bool = false
//    
    @Published var content = DragViewData()

    var shouldUpdateLanguage = CurrentValueSubject<Bool, Never>(false)

    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)

    private var cancellable: Set<AnyCancellable> = []
    
    init() {
        loadData()
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
    
    func removeAllFiles() {
        vaultManager.removeAllFiles()
        publishUpdates()
    }
    
    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
    
    func add(files: [URL], to parentFolder: VaultFile?, type: FileType) {
        
        vaultManager.progress.progress.sink { value in
            self.publishUpdates()
        }.store(in: &cancellable)

        self.vaultManager.importFile(files: files, to: parentFolder, type: type)
        self.publishUpdates()
    }
    
    func add(audioFilePath: URL, to parentFolder: VaultFile?, type: FileType, fileName:String) {
        self.vaultManager.importFile(audioFilePath: audioFilePath, to: parentFolder, type: type, fileName: fileName)
        self.publishUpdates()
    }

    func add(image: UIImage, to parentFolder: VaultFile?, type: FileType, pathExtension:String) {
        
        vaultManager.progress.progress.sink { value in
            self.publishUpdates()
        }.store(in: &cancellable)
        
        
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.importFile(image: image, to: parentFolder ?? self.vaultManager.root, type: type, pathExtension: pathExtension)
            self.publishUpdates()
        }
    }
    
    func add(folder: String, to parentFolder: VaultFile?) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.createNewFolder(name: folder, parent: parentFolder)
            self.publishUpdates()
        }
    }
    
    func cancelImportAndEncryption() {
        self.vaultManager.shouldCancelImportAndEncryption.send(true)
     }
    
    func delete(file: VaultFile, from parentFolder: VaultFile?) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.delete(file: file, parent: parentFolder)
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
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
}

class SettingsModel: ObservableObject, Codable {
    
    @Published var offLineMode = false
    @Published var quickDelete: Bool = false
    @Published var deleteVault: Bool = false
    @Published var deleteForms: Bool = false
    @Published var deleteServerSettings: Bool = false
    
    enum CodingKeys: CodingKey {
        case offLineMode
        case quickDelete
        case deleteVault
        case deleteForms
        case deleteServerSettings
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
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offLineMode, forKey: .offLineMode)
        try container.encode(quickDelete, forKey: .quickDelete)
        try container.encode(deleteVault, forKey: .deleteVault)
        try container.encode(deleteForms, forKey: .deleteForms)
        try container.encode(deleteServerSettings, forKey: .deleteServerSettings)
    }
    
}
