//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    @StateObject var lockViewModel : LockViewModel
    
    init(mainAppModel:MainAppModel, appViewState: AppViewState) {
        _lockViewModel = StateObject(wrappedValue: LockViewModel(unlockType: .new, appModel: mainAppModel, appViewState: appViewState))
    }
    var body: some View {
        
        ZStack {
            if appViewState.currentView == .MAIN {
                MainView(mainAppModel: appViewState.homeViewModel)
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
        .navigationBarHidden(true)
    }
}
