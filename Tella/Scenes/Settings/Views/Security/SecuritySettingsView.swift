//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SecuritySettingsView: View {
    
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    @EnvironmentObject private var sheetManager: SheetManager
    @StateObject var lockViewModel = LockViewModel(unlockType: .update)
    @State var passwordTypeString : String = ""
    
    var cards : [[CardData<AnyView>]] { return [[CardData(imageName: "settings.lock",
                                                          title: LocalizableSettings.settSecLock.localized,
                                                          value: passwordTypeString,
                                                          cardType : .display,
                                                          cardName: SecurityCardName.lock,
                                                          destination: unlockView.eraseToAnyView()),
                                                 CardData(imageName: "settings.timeout",
                                                          title: LocalizableSettings.settSecLockTimeout.localized,
                                                          value: appModel.settings.lockTimeout.displayName,
                                                          cardType : .display,
                                                          cardName: SecurityCardName.lockTimeout)],
                                                [CardData(title: LocalizableSettings.settSecScreenSecurity.localized,
                                                          description: LocalizableSettings.settSecScreenSecurityExpl.localized,
                                                          cardType : .toggle,
                                                          cardName: SecurityCardName.screenSecurity,
                                                          valueToSave: $appModel.settings.screenSecurity)]]}
    
    var body: some View {
        
        ContainerView {
            VStack( spacing: 12) {
                Spacer()
                    .frame(height: 12)
                
                ForEach(cards, id:\.self) { item in
                    SettingsCardView(cardDataArray: item) { card in
                        switch card {
                        case SecurityCardName.lockTimeout:
                            showLockTimeout()
                        default:
                            break
                        }
                    }
                }
                
                Spacer()
            }
        }
        
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settSecAppBar.localized)
        }
        
        .onAppear {
            lockViewModel.shouldDismiss.send(false)
            let passwordType = AuthenticationManager().getPasswordType()
            passwordTypeString = passwordType == .tellaPassword ? LocalizableLock.lockSelectActionPassword.localized : LocalizableLock.lockSelectActionPin.localized
        }
        
    }
    
    var unlockView : some View {
        
        let passwordType = AuthenticationManager().getPasswordType()
        return passwordType == .tellaPassword ?
        
        UnlockPasswordView()
            .environmentObject(lockViewModel)
            .eraseToAnyView()  :
        
        UnlockPinView()
            .environmentObject(lockViewModel)
            .eraseToAnyView()
        
    }
    
    func showLockTimeout() {
        sheetManager.showBottomSheet(modalHeight: 408) {
            LockTimeoutView()
                .environmentObject(settingsViewModel)
        }
    }
}

struct SecuritySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySettingsView()
    }
}
