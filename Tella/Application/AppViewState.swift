//
//  AppViewState.swift
//  Tella
//
//  Created by Rance Tsai on 9/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

enum MainViewEnum {
    case MAIN, LOCK, UNLOCK
}

final class AppViewState: ObservableObject {
   
    var homeViewModel : MainAppModel

    @Published private var viewStack = [MainViewEnum]()
    @Published var shouldHidePresentedView: Bool = false
    @Published var networkMonitor : NetworkMonitor 

    init() {
        let networkMonitor = NetworkMonitor()
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
        homeViewModel.resetVaultManager()
        viewStack = [.UNLOCK]
    }

    func showMainView() {
        viewStack = [.MAIN]
    }
    
    func resetToMain() {
        viewStack = [.MAIN]
    }

    func resetApp() {
        homeViewModel.keysInitialized() ? self.resetToUnlock() : self.resetToLock()
    }
    
    func initLanguage() {
        let selectedLanguage = LanguageManager.shared.currentLanguage.rawValue
        Bundle.setLanguage(selectedLanguage)
    }
}
