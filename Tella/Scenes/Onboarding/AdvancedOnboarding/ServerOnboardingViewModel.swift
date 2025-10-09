//
//  ServerOnboardingViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import SwiftUI
import Combine


@MainActor
final class ServerOnboardingViewModel: ObservableObject {
    
    // MARK: - Dependencies
    let mainAppModel: MainAppModel
    
    // MARK: - Published state
    @Published var isConnectionSucceded: Bool = false
    @Published var index: Int
    
    // MARK: - Pages
    let pages: [ServerOnboardingItem] = [
        .main,
        .customizationDone
    ]
    
    // MARK: - Combine
    private var subscribers = Set<AnyCancellable>()
    
    // MARK: - Init
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.index = 0
        
        if let reloadPublisher = mainAppModel.tellaData?.shouldReloadServers {
            reloadPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] shouldReload in
                    guard let self, shouldReload else { return }
                    self.getServers()
                }
                .store(in: &subscribers)
        }
        getServers()
    }
    
    // MARK: - Data
    func getServers() {
        let serverArray = mainAppModel.tellaData?.getServers() ?? []
        isConnectionSucceded = !serverArray.isEmpty
    }
    
    // MARK: - States
    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    var canGoBack: Bool { index > 0 }
    var canGoNext: Bool { index < lastIndex }
    
    var currentPage: ServerOnboardingItem {
        pages[safe: index] ?? .main
    }
    
    var isOnMain: Bool { currentPage == .main }
    var isOnCustomizationDone: Bool { currentPage == .customizationDone }
    
    var shouldHideNext: Bool {
        !isConnectionSucceded || isOnCustomizationDone
    }
    
    var shouldShowDots: Bool {
        isOnMain
    }
    
    var isSwipeAllowed: Bool {
        isConnectionSucceded && !isOnCustomizationDone
    }
    
    // MARK: - Navigation
    func goToPage(_ newIndex: Int) {
        guard count > 0 else { return }
        index = min(max(newIndex, 0), lastIndex)
    }
    
    func goNext() {
        goToPage(index + 1)
    }
    
    func goBack() {
        goToPage(index - 1)
    }
}

enum ServerOnboardingItem: Identifiable, Equatable {
    case main
    case customizationDone
    
    var id: String {
        switch self {
        case .main:              return "main"
        case .customizationDone: return "customizationDone"
        }
    }
}
