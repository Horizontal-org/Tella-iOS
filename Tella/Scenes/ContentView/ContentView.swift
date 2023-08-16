//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    @StateObject var lockViewModel : LockViewModel
    
    init(mainAppModel:MainAppModel) {
        _lockViewModel = StateObject(wrappedValue: LockViewModel(unlockType: .new, appModel: mainAppModel))
    }
    var body: some View {
        
        ZStack {
            
            if appViewState.currentView == .MAIN {
                MainView()
                    .environmentObject((appViewState.homeViewModel))
                    .environment(\.layoutDirection, LanguageManager.shared.currentLanguage.layoutDirection)
                    .environmentObject(SheetManager())
            }
            
            if appViewState.currentView == .LOCK {
                WelcomeView()
                    .environmentObject(lockViewModel)
            }
            
            if appViewState.currentView == .UNLOCK {
                let passwordType = appViewState.homeViewModel.vaultManager.getPasswordType()
                passwordType == .tellaPassword ?
                UnlockView(type: .tellaPassword)
                    .environmentObject(lockViewModel)
                    .eraseToAnyView() :
                UnlockView(type: .tellaPin)
                    .environmentObject(lockViewModel)
                    .eraseToAnyView()
            }
        }.onAppear {
            setDebugLevel(level: .debug, for: .app)
        }
        .environmentObject(DeviceOrientationHelper())

    }
}
