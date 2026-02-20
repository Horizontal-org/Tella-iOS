//
//  TellaApp.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

@main
struct TellaApp: App {
    
    @StateObject private var appViewState = AppViewState()
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let delayTimeInSecond = 1.0
    @State private var pendingBackgroundSave = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(appViewState: appViewState)
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { value in
                    appViewState.homeViewModel.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }.onReceive(NotificationCenter.default.publisher(for: .backgroundUploadsDidFinish)) { _ in
                    self.saveData(lockApptype: .finishBackgroundTasks)
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                UIApplication.getTopViewController()?.dismiss(animated: false)
                self.saveData(lockApptype: .enterInBackground)
            case .active:
                pendingBackgroundSave = false
                self.resetApp()
            case .inactive:
                appViewState.homeViewModel.shouldShowSecurityScreen = true
                pendingBackgroundSave = true
            default:
                break
            }
        }
    }
    
    func saveData(lockApptype: LockApptype) {
        guard appViewState.homeViewModel.shouldResetApp() else { return }
        
        UploadService.shared.cancelTasksIfNeeded()
        appViewState.homeViewModel.appEnterInBackground = true
        
        if lockApptype == .enterInBackground {
            if pendingBackgroundSave {
                appViewState.homeViewModel.shouldSaveCurrentData = true
            }
            pendingBackgroundSave = false
        }
        
        let hasFileOnBackground = UploadService.shared.hasFilesToUploadOnBackground
        guard !hasFileOnBackground else { return }
        
        appViewState.homeViewModel.saveLockTimeoutStartDate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTimeInSecond) {
            appViewState.homeViewModel.vaultManager.clearTmpDirectory()
            appViewState.resetApp()
        }
    }
    
    func resetApp() {
        
        appViewState.homeViewModel.shouldSaveCurrentData = false
        
        let hasFileOnBackground = UploadService.shared.hasFilesToUploadOnBackground
        let appEnterInBackground = appViewState.homeViewModel.appEnterInBackground
        let shouldResetApp = appViewState.homeViewModel.shouldResetApp()
        
        if shouldResetApp && appEnterInBackground && !hasFileOnBackground {
            UIApplication.getTopViewController()?.dismiss(animated: false)
            DispatchQueue.main.async { appViewState.resetApp() }
            appViewState.homeViewModel.vaultManager.clearTmpDirectory()
        }
        
        appViewState.homeViewModel.appEnterInBackground = false
        appViewState.homeViewModel.shouldShowSecurityScreen = false
    }}

enum LockApptype {
    case enterInBackground
    case finishBackgroundTasks
}
