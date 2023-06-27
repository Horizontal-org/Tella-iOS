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
   
    var homeViewModel : MainAppModel?

    @Published private var viewStack = [MainViewEnum]()
    @Published var shouldHidePresentedView: Bool = false
    @Published var networkMonitor = NetworkMonitor()

    init() {
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
        homeViewModel = nil
        viewStack = [.UNLOCK]
    }

    func initMainAppModel() {
        homeViewModel = MainAppModel(networkMonitor: networkMonitor)
     }

    func showMainView() {
        viewStack = [.MAIN]
    }
    
    func resetToMain() {
        homeViewModel = MainAppModel(networkMonitor: networkMonitor)
        viewStack = [.MAIN]
    }

    func resetApp() {
        AuthenticationManager().keysInitialized() ? self.resetToUnlock() : self.resetToLock()
        
    }
    
    func initLanguage() {
        let selectedLanguage = LanguageManager.shared.currentLanguage.rawValue
        Bundle.setLanguage(selectedLanguage)
    }
}
