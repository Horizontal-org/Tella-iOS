//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SecuritySettingsView: View {
    
    @ObservedObject var mainAppModel : MainAppModel
    var settingsViewModel : SettingsViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    @ObservedObject var lockViewModel: LockViewModel
    @State var passwordTypeString : String = ""

    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onAppear {
            lockViewModel.shouldDismiss.send(false)
            let passwordType = mainAppModel.vaultManager.getPasswordType()
            passwordTypeString = passwordType == .tellaPassword ? LocalizableLock.lockSelectActionPassword.localized : LocalizableLock.lockSelectActionPin.localized
        }
        .onReceive(lockViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.popTo(ViewClassType.securitySettingsView)
            }
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.settSecAppBar.localized)
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 8)
            
            SettingsCardView(cardViewArray: [lockView.eraseToAnyView(), lockTimeoutView.eraseToAnyView(), deleteAfterFailGroupView.eraseToAnyView()])
            
            SettingsCardView(cardViewArray: [screenSecurityView.eraseToAnyView()])
            
            SettingsCardView(cardViewArray: [preserveMetadataView.eraseToAnyView()])
            
            SettingsCardView(cardViewArray: [quickDeleteView.eraseToAnyView()])
            
            Spacer()
        }.scrollOnOverflow()
    }
    
    // MARK: Lock
    var lockView: some View {
        SettingsItemView(imageName: "settings.lock",
                         title: LocalizableSettings.settSecLock.localized,
                         value: passwordTypeString,
                         destination:unlockView.eraseToAnyView())
    }
    
    // MARK: Lock timeout
    var lockTimeoutView: some View {
        SettingsItemView<AnyView>(imageName:"settings.timeout",
                                  title: LocalizableSettings.settSecLockTimeout.localized,
                                  value: mainAppModel.settings.lockTimeout.displayName,
                                  destination:nil) {
            showLockTimeout()
        }
    }
    
    // MARK: Delete after failed unlock
    var deleteAfterFailGroupView: some View {
        Group {
            deleteAfterFailView
            if(mainAppModel.settings.deleteAfterFail != .off) {
                DividerView()
                showUnlockAttemptsRemainingView
            }
        }
    }
    
    var deleteAfterFailView: some View {
        SettingsItemView<AnyView>(imageName: "settings.lock",
                                  title: LocalizableSettings.settSecDeleteAfterFail.localized,
                                  value: mainAppModel.settings.deleteAfterFail.selectedDisplayName,
                                  destination:nil) {
            showDeleteAfterFailedAttempts()
        }
    }
    
    var showUnlockAttemptsRemainingView: some View {
        SettingToggleItem(title: LocalizableSettings.settSecShowUnlockAttempts.localized,
                          description: LocalizableSettings.settSecShowUnlockAttemptsExpl.localized,
                          toggle: $mainAppModel.settings.showUnlockAttempts, onChange: {
            mainAppModel.saveSettings()
        })
    }
    
    // MARK: Screen Security
    var screenSecurityView: some View {
        SettingToggleItem(title: LocalizableSettings.settSecScreenSecurity.localized,
                          description: LocalizableSettings.settSecScreenSecurityExpl.localized,
                          toggle: $mainAppModel.settings.screenSecurity, onChange: {
            mainAppModel.saveSettings()
        })
    }
    
    // MARK: Preserve metadata when importing
    var preserveMetadataView: some View {
        SettingToggleItem(title: LocalizableSettings.settSecPreserveMetadata.localized,
                          description: LocalizableSettings.settSecPreserveMetadataExpl.localized,
                          toggle: $mainAppModel.settings.preserveMetadata, onChange: {
            mainAppModel.saveSettings()
        })
    }
    
    // MARK: Quick delete
    var quickDeleteView: some View {
        
        let quickDeleteBinding = Binding<Bool>(
            get: { mainAppModel.settings.quickDelete },
            set: { isOn in
                withTransaction(Transaction(animation: .easeInOut)) {
                    let settings = mainAppModel.settings
                    settings.quickDelete = isOn
                    settings.deleteVault = isOn
                    mainAppModel.settings = settings
                }
                mainAppModel.saveSettings()
            }
        )
        
        return Group {
            
            SettingToggleItem(title: LocalizableSettings.settQuickDelete.localized,
                              description: LocalizableSettings.settQuickDeleteExpl.localized,
                              toggle: quickDeleteBinding, onChange: {
                mainAppModel.saveSettings()
            })

            if mainAppModel.settings.quickDelete {
                
                DividerView()
                
                SettingCheckboxItem(
                    isChecked: $mainAppModel.settings.deleteVault,
                    mainAppModel: mainAppModel,
                    title: LocalizableSettings.settQuickDeleteFilesCheckbox.localized,
                    helpText: LocalizableSettings.settQuickDeleteFilesTooltip.localized
                )
                SettingCheckboxItem(
                    isChecked: $mainAppModel.settings.deleteServerSettings,
                    mainAppModel: mainAppModel,
                    title: LocalizableSettings.settQuickDeleteConnectionsCheckbox.localized,
                    helpText: LocalizableSettings.settQuickDeleteConnectionsTooltip.localized
                )
            }
        }
    }
    
    var unlockView : some View {
        
        let passwordType = mainAppModel.vaultManager.getPasswordType()
        
        return ContainerViewWithHeader {
            NavigationHeaderView()
        } content: {
            passwordType == .tellaPassword ?
            
            UnlockView(viewModel: lockViewModel,
                       type: .tellaPassword)
            .eraseToAnyView()  :
            
            UnlockView(viewModel: lockViewModel,
                       type: .tellaPin)
            .eraseToAnyView()
        }
    }
    
    func showLockTimeout() {
        sheetManager.showBottomSheet() {
            LockTimeoutView(settingsViewModel: settingsViewModel)
        }
    }
    
    func showDeleteAfterFailedAttempts() {
        sheetManager.showBottomSheet() {
            DeleteAfterFailView(settingsViewModel: settingsViewModel)
        }
    }
}

//struct SecuritySettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SecuritySettingsView(mainAppModel: MainAppModel.stub(),
//                             appViewState: AppViewState(),
//                             settingsViewModel: SettingsViewModel(mainAppModel: MainAppModel.stub()))
//    }
//}
