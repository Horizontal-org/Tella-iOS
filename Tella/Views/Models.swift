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
    
    func changeTab(to newTab: Tabs) {
        selectedTab = newTab
    }
    
    func add(files: [URL], to parentFolder: VaultFile?, type: FileType) {
        vaultManager.importFile(files: files, to: parentFolder, type: type)
        objectWillChange.send()
    }
    
    func add(image: UIImage, to parentFolder: VaultFile?, type: FileType) {
        vaultManager.importFile(image: image, to: parentFolder, type: type)
        objectWillChange.send()
    }

    func delete(file: VaultFile, from parentFolder: VaultFile?) {
        vaultManager.delete(file: file, parent: parentFolder)
        objectWillChange.send()
    }
    
}

class SettingsModel: ObservableObject {
    var offLineMode = false
    var quickDelete: Bool = false
    var deleteVault: Bool = false
    var deleteForms: Bool = false
    var deleteServerSettings: Bool = false
}
