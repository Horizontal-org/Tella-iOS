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
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { value in
                    appViewState.homeViewModel?.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                self.saveData()
            case .active:
                appViewState.homeViewModel?.saveLockTimeoutStartDate()
                self.resetApp()
            case .inactive:
                appViewState.homeViewModel?.shouldShowSecurityScreen = true
            default:
                break
            }
        }
    }
    
    func saveData() {
        appViewState.appEnterInBackground = true
        appViewState.homeViewModel?.shouldSaveCurrentData = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            appViewState.homeViewModel?.vaultManager.clearTmpDirectory()
        })
        appViewState.homeViewModel?.saveLockTimeoutStartDate()
        appViewState.homeViewModel?.shouldSaveCurrentData = false
    }
    
    func resetApp() {
        if let shouldResetApp = appViewState.homeViewModel?.shouldResetApp(), shouldResetApp == true, appViewState.appEnterInBackground == true {
            DispatchQueue.main.async {
                appViewState.shouldHidePresentedView = true
                appViewState.homeViewModel?.vaultManager.clearTmpDirectory()
                appViewState.resetApp()
                appViewState.shouldHidePresentedView = false
            }
        }
        appViewState.appEnterInBackground = false
        appViewState.homeViewModel?.shouldShowSecurityScreen = false
    }
}
