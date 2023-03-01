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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appViewState)
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { value in
                    appViewState.homeViewModel?.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }.onReceive(appDelegate.$shouldHandleTimeout) { value in
                    if value {
                        UploadService.shared.clearDownloads()
                        self.saveData()
                    }
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                self.saveData()
            case .active:
                self.resetApp()
            case .inactive:
                appViewState.homeViewModel?.shouldShowSecurityScreen = true
            default:
                break
            }
        }
    }
    
    func saveData() {
        
        appViewState.homeViewModel?.saveLockTimeoutStartDate()
        
        
        guard let shouldResetApp = appViewState.homeViewModel?.shouldResetApp() else { return }
        let hasFileOnBackground = UploadService.shared.hasFilesToUploadOnBackground
        
        if shouldResetApp && !hasFileOnBackground {
            
            appViewState.homeViewModel?.appEnterInBackground = true
            appViewState.homeViewModel?.shouldSaveCurrentData = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                appViewState.homeViewModel?.vaultManager.clearTmpDirectory()
                appViewState.resetApp()
            })
            //            appViewState.homeViewModel?.saveLockTimeoutStartDate()
            appViewState.homeViewModel?.shouldSaveCurrentData = false
        }
        
    }
    
    func resetApp() {
        if let shouldResetApp = appViewState.homeViewModel?.shouldResetApp(),
           shouldResetApp == true,
           appViewState.homeViewModel?.appEnterInBackground == true {
            DispatchQueue.main.async {
                appViewState.shouldHidePresentedView = true
                appViewState.homeViewModel?.vaultManager.clearTmpDirectory()
                appViewState.resetApp()
                appViewState.shouldHidePresentedView = false
            }
        }
        appViewState.homeViewModel?.appEnterInBackground = false
        appViewState.homeViewModel?.shouldShowSecurityScreen = false
    }
}

