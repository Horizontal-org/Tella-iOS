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
    
    var aboutAndHelpItems : [AboutAndHelpItem] = {
        return [AboutAndHelpItem(title: LocalizableSettings.settAboutContactUs.localized,
                                 imageName: "settings.contact-us",
                                 url: TellaUrls.contactURL),
                AboutAndHelpItem(title: LocalizableSettings.settAboutPrivacyPolicy.localized,
                                 imageName: "settings.privacy",
                                 url: TellaUrls.privacyURL)
        ]
    }()
    
    var selectedLockTimeoutOption : LockTimeoutOption {
        didSet {
            lockTimeoutOptions.filter{$0.lockTimeoutOption != selectedLockTimeoutOption}.forEach{$0.isSelected = false}
            lockTimeoutOptions.filter{$0.lockTimeoutOption == selectedLockTimeoutOption}.first?.isSelected = true
            self.objectWillChange.send()
        }
    }
    
    @Published var lockTimeoutOptions : [LockTimeoutOptionsStatus]
    
    init(appModel: MainAppModel) {
        
        self.appModel = appModel
        
        // Init lock timeout Options
        lockTimeoutOptions = [LockTimeoutOptionsStatus(lockTimeoutOption: .immediately, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .oneMinute, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .fiveMinutes, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .thirtyMinutes, isSelected: false),
                              LockTimeoutOptionsStatus(lockTimeoutOption: .onehour, isSelected: false)]
        selectedLockTimeoutOption =  appModel.settings.lockTimeout
        lockTimeoutOptions.filter{$0.lockTimeoutOption == appModel.settings.lockTimeout}.first?.isSelected = true
    }
    
    func saveLockTimeout() {
        appModel.settings.lockTimeout = selectedLockTimeoutOption
        appModel.saveSettings()
    }
}

