//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState
    @StateObject var lockViewModel : LockViewModel
    
    init(mainAppModel:MainAppModel, appViewState: AppViewState) {
        _lockViewModel = StateObject(wrappedValue: LockViewModel(unlockType: .new, appViewState: appViewState))
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
            }
            
            if appViewState.currentView == .UNLOCK {
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
