//
//

import SwiftUI

struct ContentView: View {
    
    var lockViewModel : LockViewModel?
    var appViewState : AppViewState
    
    init(appViewState: AppViewState) {
        self.lockViewModel = LockViewModel(lockFlow: .new, appViewState: appViewState)
        self.appViewState = appViewState
    }
    var body: some View {
        
        ZStack {
            if appViewState.currentView == .MAIN {
                MainView(appViewState: appViewState)
                    .environment(\.layoutDirection, LanguageManager.shared.currentLanguage.layoutDirection)
                    .environmentObject(SheetManager())
            }
            
            if appViewState.currentView == .LOCK {
                WelcomeView(appViewState: appViewState)
            }
            
            if appViewState.currentView == .UNLOCK, let lockViewModel  {
                let passwordType = appViewState.homeViewModel.vaultManager.getPasswordType()
                passwordType == .tellaPassword ?
                UnlockView(viewModel: lockViewModel, type: .tellaPassword)
                    .eraseToAnyView() :
                UnlockView(viewModel: lockViewModel, type: .tellaPin)
                    .eraseToAnyView()
            }
        }.onAppear {
            setDebugLevel(level: .debug, for: .app)
        }
        .environmentObject(DeviceOrientationHelper())
    }
}
