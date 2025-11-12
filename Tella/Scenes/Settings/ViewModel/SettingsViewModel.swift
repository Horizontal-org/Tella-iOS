//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class SettingsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
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
    
    init(mainAppModel: MainAppModel) {
        
        self.mainAppModel = mainAppModel
        
        // Init lock timeout Options
        lockTimeoutOptions = [LockTimeoutOptionsStatus(lockTimeoutOption: .immediately, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .oneMinute, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .fiveMinutes, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .thirtyMinutes, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .onehour, isSelected: false)]
        selectedLockTimeoutOption =  mainAppModel.settings.lockTimeout
        
        // Init delete after fail options
        deleteAfterFailOptions=[DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .off, isSelected: false),
                                DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .five, isSelected: false),
                                DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .ten, isSelected: false),
                                DeleteAfterFailedOptionsStatus(deleteAfterFailOption: .twenty, isSelected: false)]
        selectedDeleteAfterFailOption = mainAppModel.settings.deleteAfterFail
        
        lockTimeoutOptions.filter{$0.lockTimeoutOption == mainAppModel.settings.lockTimeout}.first?.isSelected = true
        deleteAfterFailOptions.filter{$0.deleteAfterFailOption == mainAppModel.settings.deleteAfterFail}.first?.isSelected = true
    }
    
    func saveLockTimeout() {
        mainAppModel.settings.lockTimeout = selectedLockTimeoutOption
        mainAppModel.saveSettings()
    }
    
    func cancelLockTimeout() {
        selectedLockTimeoutOption = mainAppModel.settings.lockTimeout
    }
    
    func saveDeleteAfterFail() {
        setShowUnlockAttempts()
        mainAppModel.settings.deleteAfterFail = selectedDeleteAfterFailOption
        mainAppModel.saveSettings()
    }
    
    func setShowUnlockAttempts () {
        if(mainAppModel.settings.deleteAfterFail == .off && selectedDeleteAfterFailOption != .off) {
            mainAppModel.settings.showUnlockAttempts = true
        }
        if(selectedDeleteAfterFailOption == .off) {
            mainAppModel.settings.showUnlockAttempts = false
        }
    }
    
    func cancelDeleteAfterFail() {
        selectedDeleteAfterFailOption = mainAppModel.settings.deleteAfterFail
    }

}

extension SettingsViewModel {
    static func stub() -> SettingsViewModel {
        return SettingsViewModel(mainAppModel: MainAppModel.stub())
    }
}
