//
//  AppViewState.swift
//  Tella
//
//  Created by Rance Tsai on 9/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

final class AppViewState: ObservableObject {
    var homeViewModel : MainAppModel?

    @Published private var viewStack = [MainViewEnum]()
    init() {
        CryptoManager.shared.keysInitialized() ? self.resetToUnlock() : self.resetToLock()

    }
    var currentView: MainViewEnum {
        return viewStack.last ?? .AUTH
    }

    func navigateBack() {
        viewStack.removeLast()
    }

    func navigate(to view: MainViewEnum) {
        viewStack.append(view)
    }

    func resetToAuth() {
        viewStack = [.AUTH]
    }
    
    func resetToLock() {
        viewStack = [.LOCK]
    }

    func resetToUnlock() {
        viewStack = [.UNLOCK]
    }


    func resetToMain() {
        homeViewModel = MainAppModel()
        viewStack = [.MAIN]
    }
    
    func resetToAudio() {
        viewStack = [.MAIN]
        
        homeViewModel?.selectedType = .audio
        homeViewModel?.showFilesList = true
    }
    
    func resetToImage() {
        viewStack = [.MAIN]
        
        homeViewModel?.selectedType = .image
        homeViewModel?.showFilesList = true
    }
    
    func resetToVideo() {
        viewStack = [.MAIN]
        
        homeViewModel?.selectedType = .video
        homeViewModel?.showFilesList = true
    }
}

