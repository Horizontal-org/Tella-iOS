//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

protocol AppModelFileManagerProtocol {
    
    func add(files: [URL], to parentFolder: VaultFile?, type: FileType)
    func add(image: UIImage, to parentFolder: VaultFile?, type: FileType)
    func delete(file: VaultFile)
    
}

class MainAppModel: ObservableObject {
    
    enum Tabs: Hashable {
       case home
       case forms
       case reports
       case camera
       case mic
    }
    
    @Published var settings: SettingsModel = SettingsModel()
    @Published var vaultManager: VaultManager = VaultManager(cryptoManager: DummyCryptoManager(), fileManager: DefaultFileManager(), rootFileName: "rootFile", containerPath: "")

    @Published var selectedTab: Tabs = .home
    
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
    
    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
    
    func add(files: [URL], to parentFolder: VaultFile?, type: FileType) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.importFile(files: files, to: parentFolder, type: type)
            self.publishUpdates()
        }
    }
    
    func add(image: UIImage, to parentFolder: VaultFile?, type: FileType) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.importFile(image: image, to: parentFolder ?? self.vaultManager.root, type: type)
            self.publishUpdates()
        }
    }

    func delete(file: VaultFile, from parentFolder: VaultFile?) {
        DispatchQueue.global(qos: .background).async {
            self.vaultManager.delete(file: file, parent: parentFolder)
            self.publishUpdates()
        }
    }
    
    private func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
}

class SettingsModel: ObservableObject, Codable {
    var offLineMode = false
    var quickDelete: Bool = false
    var deleteVault: Bool = false
    var deleteForms: Bool = false
    var deleteServerSettings: Bool = false
}
