//
//  TellaApp.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

@main
struct TellaApp: App {
    
    private var appViewState = AppViewState()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appViewState)
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                appViewState.homeViewModel?.vaultManager.clearTmpDirectory()
            default:
                break
            }
        }
    }
}
