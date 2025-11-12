//
//  AppViewState.swift
//  Tella
//
//  Created by Rance Tsai on 9/7/20.
//  Copyright © 2020 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

enum MainViewEnum {
    case MAIN, LOCK, UNLOCK
}

final class AppViewState: ObservableObject {
   
    @Published var homeViewModel : MainAppModel
    @Published private var viewStack = [MainViewEnum]()
    @Published var mainAppLayout: LayoutDirection = .leftToRight
    @Published var networkMonitor : NetworkMonitor 

    init() {
        let networkMonitor = NetworkMonitor.shared
        self.networkMonitor = networkMonitor
        homeViewModel = MainAppModel(networkMonitor:  networkMonitor)
        
        self.resetApp()
        self.initLanguage()
    }
    
    var currentView: MainViewEnum {
        return viewStack.last ?? .LOCK
    }

    func navigateBack() {
        viewStack.removeLast()
    }

    func navigate(to view: MainViewEnum) {
        viewStack.append(view)
    }

    func resetToLock() {
        viewStack = [.LOCK]
    }

    func resetToUnlock() {
        homeViewModel.resetData()
        viewStack = [.UNLOCK]
    }

    func showMainView() {
        viewStack = [.MAIN]
    }
    
    func resetToMain() {
        viewStack = [.MAIN]
    }

    func resetApp() {
        homeViewModel.vaultManager.keysInitialized() ? self.resetToUnlock() : self.resetToLock()
    }
    
    func initLanguage() {
        let selectedLanguage = LanguageManager.shared.currentLanguage.rawValue
        mainAppLayout = LanguageManager.shared.currentLanguage.layoutDirection
        Bundle.setLanguage(selectedLanguage)
    }
}

extension AppViewState {
    static func stub() -> AppViewState {
        return AppViewState()
    }
}

