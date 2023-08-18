//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    var appModel : MainAppModel
    
    var languageItems : [Language] = {
        var languageItems = Language.allCases.map {$0}
        languageItems = languageItems.sorted(by: { $0.name < $1.name })
        if let index = languageItems.firstIndex(where: {$0 == .systemLanguage}) {
            languageItems = languageItems.rearrange(fromIndex: index, toIndex: 0)
        }
        return languageItems
    }()
        
    var selectedLockTimeoutOption : LockTimeoutOption {
        didSet {
            lockTimeoutOptions.filter{$0.lockTimeoutOption != selectedLockTimeoutOption}.forEach{$0.isSelected = false}
            lockTimeoutOptions.filter{$0.lockTimeoutOption == selectedLockTimeoutOption}.first?.isSelected = true
            self.objectWillChange.send()
        }
    }
    
    var selectedDeleteAfterFailOption : DeleteAfterFailOption {
        didSet {
            deleteAfterFailOptions.filter{$0.deleteAfterFailOption != selectedDeleteAfterFailOption}.forEach{$0.isSelected = false}
            deleteAfterFailOptions.filter{$0.deleteAfterFailOption == selectedDeleteAfterFailOption}.first?.isSelected = true
            self.objectWillChange.send()
        }
    }
    
    @Published var lockTimeoutOptions : [LockTimeoutOptionsStatus]
    @Published var deleteAfterFailOptions: [DeleteAfterFailedOptionsStatus]
    
    init(appModel: MainAppModel) {
        
        self.appModel = appModel
        
        // Init lock timeout Options
        lockTimeoutOptions = [LockTimeoutOptionsStatus(lockTimeoutOption: .immediately, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .oneMinute, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .fiveMinutes, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .thirtyMinutes, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .onehour, isSelected: false)]
        selectedLockTimeoutOption =  appModel.settings.lockTimeout
        
        // Init delete after fail options
        deleteAfterFailOptions=[DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .off, isSelected: false),
                                DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .five, isSelected: false),
                                DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .ten, isSelected: false),
                                DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .twenty, isSelected: false)]
        selectedDeleteAfterFailOption = appModel.settings.deleteAfterFail
        
        lockTimeoutOptions.filter{$0.lockTimeoutOption == appModel.settings.lockTimeout}.first?.isSelected = true
        deleteAfterFailOptions.filter{$0.deleteAfterFailOption == appModel.settings.deleteAfterFail}.first?.isSelected = true
    }
    
    func saveLockTimeout() {
        appModel.settings.lockTimeout = selectedLockTimeoutOption
        appModel.saveSettings()
    }
    
    func cancelLockTimeout() {
        selectedLockTimeoutOption = appModel.settings.lockTimeout
    }
    
    func saveDeleteAfterFail() {
        appModel.settings.deleteAfterFail = selectedDeleteAfterFailOption
        appModel.saveSettings()
    }
    
    func cancelDeleteAfterFail() {
        selectedDeleteAfterFailOption = appModel.settings.deleteAfterFail
    }

}

