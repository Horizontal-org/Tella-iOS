//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SecuritySettingsView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    @StateObject var lockViewModel: LockViewModel
    @State var passwordTypeString : String = ""
    
    
    init(appModel: MainAppModel) {
        _lockViewModel = StateObject(wrappedValue: LockViewModel(unlockType: .update, appModel: appModel))
    }
    
    var body: some View {
        
        ContainerView {
            ScrollView {
                VStack(spacing: 0) {
                   
                    Spacer()
                        .frame(height: 8)

                    SettingsCardView(cardViewArray: [lockView.eraseToAnyView(), lockTimeoutView.eraseToAnyView(), deleteAfterFailGroupView.eraseToAnyView()])
                    
                    SettingsCardView(cardViewArray: [screenSecurityView.eraseToAnyView()])

                    SettingsCardView(cardViewArray: [preserveMetadataView.eraseToAnyView()])
                    
                    SettingsCardView(cardViewArray: [quickDeleteView.eraseToAnyView()])

                    Spacer()
                }
            }
        }
        
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settSecAppBar.localized)
        }
        
        .onAppear {
            lockViewModel.shouldDismiss.send(false)
            let passwordType = appModel.vaultManager.getPasswordType()
            passwordTypeString = passwordType == .tellaPassword ? LocalizableLock.lockSelectActionPassword.localized : LocalizableLock.lockSelectActionPin.localized
        }
        .onReceive(lockViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.popTo(UIHostingController<Optional<ModifiedContent<SecuritySettingsView, _EnvironmentKeyWritingModifier<Optional<SettingsViewModel>>>>>.self)
            }
        }

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
                                  value: appModel.settings.lockTimeout.displayName,
                                  destination:nil) {
            showLockTimeout()

        }
    }
    
    // MARK: Delete after failed unlock
    var deleteAfterFailGroupView: some View {
        Group {
            deleteAfterFailView
            if(appModel.settings.deleteAfterFail != .off) {
                DividerView()
                showUnlockAttemptsRemainingView
            }
        }
    }
    
    var deleteAfterFailView: some View {
        
        SettingsItemView<AnyView>(imageName: "settings.lock",
                                  title: LocalizableSettings.settSecDeleteAfterFail.localized,
                                  value: appModel.settings.deleteAfterFail.selectedDisplayName,
                         destination:nil) {
            showDeleteAfterFailedAttempts()
        }
        
    }
    
    var showUnlockAttemptsRemainingView: some View {
        SettingToggleItem(title: LocalizableSettings.settSecShowUnlockAttempts.localized,
                          description: LocalizableSettings.settSecShowUnlockAttemptsExpl.localized,
                          toggle: $appModel.settings.showUnlockAttempts)
    }

 
    // MARK: Screen Security
    var screenSecurityView: some View {
        
        SettingToggleItem(title: LocalizableSettings.settSecScreenSecurity.localized,
                          description: LocalizableSettings.settSecScreenSecurityExpl.localized,
                          toggle: $appModel.settings.screenSecurity)
        
        
    }
    
    // MARK: Preserve metadata when importing
    var preserveMetadataView: some View {

        SettingToggleItem(title: LocalizableSettings.settSecPreserveMetadata.localized,
                          description: LocalizableSettings.settSecPreserveMetadataExpl.localized,
                          toggle: $appModel.settings.preserveMetadata)


    }
    
    // MARK: Quick delete
    var quickDeleteView: some View {
        
        Group {
            SettingToggleItem(title: LocalizableSettings.settQuickDelete.localized,
                              description: LocalizableSettings.settQuickDeleteExpl.localized,
                              toggle: $appModel.settings.quickDelete)
            if appModel.settings.quickDelete {
                SettingCheckboxItem(
                    isChecked: $appModel.settings.deleteVault ,
                    title: LocalizableSettings.settQuickDeleteFilesCheckbox.localized
                )
                SettingCheckboxItem(
                    isChecked: $appModel.settings.deleteServerSettings ,
                    title: LocalizableSettings.settQuickDeleteConnectionsCheckbox.localized
                )
            }
        }
    }

    var unlockView : some View {
        
        let passwordType = appModel.vaultManager.getPasswordType()
        return passwordType == .tellaPassword ?
        
        UnlockView(type: .tellaPassword)
            .environmentObject(lockViewModel)
            .eraseToAnyView()  :
        
        UnlockView(type: .tellaPin)
            .environmentObject(lockViewModel)
            .eraseToAnyView()
        
    }
    
    func showLockTimeout() {
        sheetManager.showBottomSheet(modalHeight: 408) {
            LockTimeoutView()
                .environmentObject(settingsViewModel)
        }
    }
    
    func showDeleteAfterFailedAttempts() {
        sheetManager.showBottomSheet(modalHeight: 408) {
            DeleteAfterFailView()
                .environmentObject(settingsViewModel)
        }
    }
    
}

struct SecuritySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySettingsView(appModel: MainAppModel.stub())
    }
}
