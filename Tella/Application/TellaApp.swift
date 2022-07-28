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
                self.saveLockTimeoutStartDate()
            case .active:
                self.resetApp()
            default:
                break
            }
        }
    }
    
    func saveLockTimeoutStartDate() {
        appViewState.homeViewModel?.saveLockTimeoutStartDate()
    }
    
    func resetApp() {
        guard let shouldResetApp = appViewState.homeViewModel?.shouldResetApp() else { return }
        if shouldResetApp {
            DispatchQueue.main.async {
                appViewState.shouldHidePresentedView = true
                appViewState.homeViewModel?.vaultManager.clearTmpDirectory()
                appViewState.resetApp()
                appViewState.shouldHidePresentedView = false
            }
        }
    }
}
