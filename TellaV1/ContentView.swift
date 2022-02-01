//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        
        if appViewState.currentView == .MAIN {
            return AppView()
                .environmentObject((appViewState.homeViewModel)!)
                .environment(\.layoutDirection, Language.currentLanguage.layoutDirection)
                .eraseToAnyView()
        }
        
        if appViewState.currentView == .AUTH {
            return LockChoiceView( isPresented: .constant(false)).eraseToAnyView()
        }
        
        if appViewState.currentView == .LOCK {
            return LockChoiceView( isPresented: .constant(false))
                .environmentObject(LockViewModel(unlockType: .new))
                .eraseToAnyView()
        }
        
        if appViewState.currentView == .UNLOCK {
            let passwordType = CryptoManager.shared.passwordType
            return passwordType == .TELLA_PASSWORD ?
            UnlockPasswordView()
                .environmentObject(LockViewModel(unlockType: .new))
                .eraseToAnyView() :
            UnlockPinView()
                .environmentObject(LockViewModel(unlockType: .new))
                .eraseToAnyView()
        }
        
        
        return Color.black
            .edgesIgnoringSafeArea(.all) // ignore just for the color
            .eraseToAnyView()
    }
}
