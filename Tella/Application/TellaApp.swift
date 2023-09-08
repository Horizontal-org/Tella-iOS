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
    let delayTimeInSecond = 1.0
    
    var body: some Scene {
        WindowGroup {
            ContentView(mainAppModel: appViewState.homeViewModel)
                .environmentObject(appViewState)
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { value in
                    appViewState.homeViewModel.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }.onReceive(appDelegate.$shouldHandleTimeout) { value in
                    if value {
                        self.saveData(lockApptype: .finishBackgroundTasks)
                    }
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                self.saveData(lockApptype: .enterInBackground)
            case .active:
                self.resetApp()
            case .inactive:
                appViewState.homeViewModel.shouldShowSecurityScreen = true
            default:
                break
            }
        }
    }

    func saveData(lockApptype:LockApptype) {
        let homeViewModel = appViewState.homeViewModel
        homeViewModel.saveLockTimeoutStartDate()
        UploadService.shared.cancelTasksIfNeeded()
        handleResetApp(lockApptype)
    }
    
    fileprivate func handleResetApp(_ lockApptype: LockApptype) {
        let homeViewModel = appViewState.homeViewModel
        let shouldResetApp = appViewState.homeViewModel.shouldResetApp()
        let  hasFileOnBackground = lockApptype == .enterInBackground ? UploadService.shared.hasFilesToUploadOnBackground : false
        if shouldResetApp && !hasFileOnBackground {
            homeViewModel.appEnterInBackground = true
            homeViewModel.shouldSaveCurrentData = true
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTimeInSecond, execute: {
                appViewState.homeViewModel.vaultManager.clearTmpDirectory() // TO FIX for server doesn't allow upload in Background
                appViewState.resetApp()
            })
            homeViewModel.shouldSaveCurrentData = false
        }
    }
    func resetApp() {
        let homeViewModel = appViewState.homeViewModel
        if homeViewModel.shouldResetApp() == true,
           homeViewModel.appEnterInBackground == true {
            DispatchQueue.main.async {
                appViewState.shouldHidePresentedView = true
                appViewState.homeViewModel.vaultManager.clearTmpDirectory()
                appViewState.resetApp()
                appViewState.shouldHidePresentedView = false
            }
        }
        homeViewModel.appEnterInBackground = false
        homeViewModel.shouldShowSecurityScreen = false
    }
}

enum LockApptype {
    case enterInBackground
    case finishBackgroundTasks
}
