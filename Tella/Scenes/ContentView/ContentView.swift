//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var appModel: MainAppModel
    
    var body: some View {
        
        ZStack {
            
            if appViewState.currentView == .MAIN {
                MainView()
                    .environmentObject((appViewState.homeViewModel)!)
                    .environment(\.layoutDirection, LanguageManager.shared.currentLanguage.layoutDirection)
                    .environmentObject(SheetManager())
            }
            
            if appViewState.currentView == .LOCK {
                WelcomeView()
                    .environmentObject(LockViewModel(unlockType: .new, appModel: appModel))
            }
            
            if appViewState.currentView == .UNLOCK {
                let passwordType = AuthenticationManager().getPasswordType()
                passwordType == .tellaPassword ?
                UnlockPasswordView(appModel: appModel)
                    .environmentObject(LockViewModel(unlockType: .new, appModel: appModel))
                    .eraseToAnyView() :
                UnlockPinView(appModel: appModel)
                    .environmentObject(LockViewModel(unlockType: .new, appModel: appModel))
                    .eraseToAnyView()
            }
        }.onAppear {
            setDebugLevel(level: .debug, for: .app)
        }
        .environmentObject(DeviceOrientationHelper())

    }
}
