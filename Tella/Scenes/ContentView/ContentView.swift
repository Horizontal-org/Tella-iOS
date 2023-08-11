//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
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
                    .environmentObject(LockViewModel(unlockType: .new))
            }
            
            if appViewState.currentView == .UNLOCK {
                let passwordType = AuthenticationManager().getPasswordType()
                passwordType == .tellaPassword ?
                UnlockPasswordView()
                    .environmentObject(LockViewModel(unlockType: .new))
                    .eraseToAnyView() :
                UnlockPinView()
                    .environmentObject(LockViewModel(unlockType: .new))
                    .eraseToAnyView()
            }
        }.onAppear {
            setDebugLevel(level: .debug, for: .app)
        }
        .environmentObject(DeviceOrientationHelper())

    }
}
