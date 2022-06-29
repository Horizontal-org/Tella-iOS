//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        
        if appViewState.currentView == .MAIN {
            return MainView()
                .environmentObject((appViewState.homeViewModel)!)
                .environment(\.layoutDirection, LanguageManager.shared.currentLanguage.layoutDirection)
                .environmentObject(SheetManager())
                .eraseToAnyView()
        }
        
        if appViewState.currentView == .LOCK {
            return WelcomeView()
                .environmentObject(LockViewModel(unlockType: .new))
                .eraseToAnyView()
        }
        
        if appViewState.currentView == .UNLOCK {
            let passwordType = AuthenticationManager().getPasswordType()
            return UnlockPinView()
                .environmentObject(LockViewModel(unlockType: .new))
                .eraseToAnyView()
        }
        
        
        return Color.black
            .edgesIgnoringSafeArea(.all) // ignore just for the color
            .eraseToAnyView()
    }
}
