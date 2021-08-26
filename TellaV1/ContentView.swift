//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState

    var body: some View {
        // makes black background and overlays content
        if appViewState.currentView == .MAIN {
            return AppView().environmentObject(appViewState.homeViewModel).eraseToAnyView()
        }
        
        if appViewState.currentView == .AUTH {
            return PasswordView().eraseToAnyView()
        }
        return Color.black
            .edgesIgnoringSafeArea(.all) // ignore just for the color
            .eraseToAnyView()
    }
}
