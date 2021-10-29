//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState

    var body: some View {
        // makes black background and overlays content
        if appViewState.currentView == .MAIN {
            return AppView().environmentObject((appViewState.homeViewModel)!).eraseToAnyView()
        }
        
        if appViewState.currentView == .AUTH {
            return LockChoiceView().eraseToAnyView()
        }
        
        if appViewState.currentView == .LOCK {
            return LockChoiceView().eraseToAnyView()
        }
        
        if appViewState.currentView == .UNLOCK {
            let passwordType = CryptoManager.shared.passwordType
            return passwordType == .TELLA_PASSWORD ? UnlockPasswordView().eraseToAnyView() :  UnlockPinView().eraseToAnyView()
        }


        return Color.black
            .edgesIgnoringSafeArea(.all) // ignore just for the color
            .eraseToAnyView()
    }
}
