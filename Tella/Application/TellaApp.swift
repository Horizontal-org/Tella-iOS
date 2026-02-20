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

    enum LockAppType {
        case enterInBackground
        case finishBackgroundTasks
    }
    
    @StateObject private var appViewState = AppViewState()
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// Delay before clearing tmp and resetting view state when app enters background.
    private let backgroundCleanupDelay: TimeInterval = 1.0
    
    var body: some Scene {
        WindowGroup {
            ContentView(appViewState: appViewState)
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
                    appViewState.homeViewModel.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }
                .onReceive(NotificationCenter.default.publisher(for: .backgroundUploadsDidFinish)) { _ in
                    self.saveData(lockAppType: .finishBackgroundTasks)
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                UIApplication.getTopViewController()?.dismiss(animated: false)
                self.saveData(lockAppType: .enterInBackground)
            case .active:
                self.resetApp()
            case .inactive:
                appViewState.homeViewModel.shouldShowSecurityScreen = true
            default:
                break
            }
        }
    }
    
    func saveData(lockAppType: LockAppType) {
        guard appViewState.homeViewModel.shouldResetApp() else { return }
        
        // Cancel foreground uploads and mark background entry; must run even when waiting for background uploads.
        UploadService.shared.cancelTasksIfNeeded()
        appViewState.homeViewModel.appEnterInBackground = true
        
        if lockAppType == .enterInBackground {
            appViewState.homeViewModel.shouldSaveCurrentData = true
        }
        
        let hasFileOnBackground = UploadService.shared.hasFilesToUploadOnBackground
        guard !hasFileOnBackground else { return }
        
        appViewState.homeViewModel.saveLockTimeoutStartDate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + backgroundCleanupDelay) {
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
    }
}
