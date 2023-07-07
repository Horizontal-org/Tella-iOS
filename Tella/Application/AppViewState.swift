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
    @Published var mainAppLayout: LayoutDirection = .leftToRight
    @Published var networkMonitor = NetworkMonitor()

    init() {
        self.resetApp()
        self.initLanguage()
        self.loadLanguage()
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

    func loadLanguage() {
        switch LanguageManager.shared.currentLanguage {

        case .systemLanguage:

            switch LanguageManager.shared.getSystemLanguageString() {
            case "ar", "fa", "ku":
                mainAppLayout = .rightToLeft
            default:
                mainAppLayout = .leftToRight
            }
        case .arabic, .kurdish, .persian :
            mainAppLayout = .rightToLeft

        default:
            mainAppLayout = .leftToRight
        }
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
