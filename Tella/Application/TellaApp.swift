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
    
    var body: some Scene {
        WindowGroup {
            ContentView(appViewState: appViewState)
                .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
                    appViewState.homeViewModel.shouldShowRecordingSecurityScreen = UIScreen.main.isCaptured
                }
                .onReceive(NotificationCenter.default.publisher(for: .backgroundUploadsDidFinish)) { _ in
                    if UIApplication.shared.applicationState == .background {
                        self.saveData(lockAppType: .finishBackgroundTasks)
                    }
                }.onReceive(appDelegate.$appWillTerminate) { willTerminate in
                    if willTerminate {
                        clearTmpDirectory()
                    }
                }
            
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                appViewState.homeViewModel.saveLockTimeoutStartDate()
                self.saveData(lockAppType: .enterInBackground)
            case .active:
                self.resetApp()
            case .inactive:
                dismissPresentedViewsIfNeeded()
                appViewState.homeViewModel.shouldShowSecurityScreen = true
            default:
                break
            }
        }
    }
    
    /// Hides presented overlays when leaving the app, but keeps onboarding lock-choice modals
    private func dismissPresentedViewsIfNeeded() {
        guard appViewState.currentView != .LOCK else { return }
        UIApplication.getTopViewController()?.dismiss(animated: false)
    }
    
    func saveData(lockAppType: LockAppType) {
        
        guard appViewState.homeViewModel.shouldResetApp() else { return }
        
        // Cancel foreground uploads and mark background entry; must run even when waiting for background uploads.
        appViewState.homeViewModel.uploadService.cancelTasksIfNeeded()
        appViewState.homeViewModel.appEnterInBackground = true
        
        if lockAppType == .enterInBackground {
            appViewState.homeViewModel.shouldSaveCurrentData = true
        }
        
        let hasFileOnBackground = appViewState.homeViewModel.uploadService.hasFilesToUploadOnBackground
        guard !hasFileOnBackground else { return }
        
        guard UIApplication.shared.applicationState == .background else {
            return
        }
        appViewState.homeViewModel.vaultManager.clearTmpDirectory()
        appViewState.lockAfterBackground()
    }
    
    func resetApp() {
        appViewState.homeViewModel.shouldSaveCurrentData = false
        
        let hasFileOnBackground = appViewState.homeViewModel.uploadService.hasFilesToUploadOnBackground
        let appEnterInBackground = appViewState.homeViewModel.appEnterInBackground
        let shouldResetApp = appViewState.homeViewModel.shouldResetApp()
        
        if shouldResetApp && appEnterInBackground && !hasFileOnBackground {
            DispatchQueue.main.async { appViewState.resetApp() }
            appViewState.homeViewModel.vaultManager.clearTmpDirectory()
            appViewState.homeViewModel.uploadService.reset()
        }
        
        appViewState.homeViewModel.appEnterInBackground = false
        appViewState.homeViewModel.shouldShowSecurityScreen = false
    }
    
    func clearTmpDirectory() {
        appViewState.homeViewModel.vaultManager.clearTmpDirectory()
    }
}
