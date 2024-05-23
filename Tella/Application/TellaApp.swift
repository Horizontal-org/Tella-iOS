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
    let gDriveAuthViewModel = GDriveAuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(mainAppModel: appViewState.homeViewModel, appViewState: appViewState)
                .environmentObject(appViewState)
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { value in
                    appViewState.homeViewModel.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }.onReceive(appDelegate.$shouldHandleTimeout) { value in
                    if value {
                        self.saveData(lockApptype: .finishBackgroundTasks)
                    }
                }.onOpenURL { url in
                    gDriveAuthViewModel.handleUrl(url: url)
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                UIApplication.getTopViewController()?.dismiss(animated: false)
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
        
        
        appViewState.homeViewModel.saveLockTimeoutStartDate()
        
        UploadService.shared.cancelTasksIfNeeded()
        
        appViewState.homeViewModel.appEnterInBackground = true
        
        let shouldResetApp = appViewState.homeViewModel.shouldResetApp()
        let  hasFileOnBackground = lockApptype == .enterInBackground ? UploadService.shared.hasFilesToUploadOnBackground : false
        
        if shouldResetApp && !hasFileOnBackground {
            
            appViewState.homeViewModel.shouldSaveCurrentData = true
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTimeInSecond, execute: {
                appViewState.homeViewModel.vaultManager.clearTmpDirectory() // TO FIX for server doesn't allow upload in Background
                appViewState.resetApp()
            })
            appViewState.homeViewModel.shouldSaveCurrentData = false
        }
    }
    func resetApp() {
        let  hasFileOnBackground = UploadService.shared.hasFilesToUploadOnBackground
        let appEnterInBackground = appViewState.homeViewModel.appEnterInBackground
        let shouldResetApp = appViewState.homeViewModel.shouldResetApp()

        if shouldResetApp && appEnterInBackground && !hasFileOnBackground {
            UIApplication.getTopViewController()?.dismiss(animated: false)

            DispatchQueue.main.async {
                appViewState.shouldHidePresentedView = true
                appViewState.resetApp()
                appViewState.shouldHidePresentedView = false
            }
        }
        appViewState.homeViewModel.appEnterInBackground = false
        appViewState.homeViewModel.shouldShowSecurityScreen = false
        appViewState.homeViewModel.vaultManager.clearTmpDirectory()

    }
}

enum LockApptype {
    case enterInBackground
    case finishBackgroundTasks
}
