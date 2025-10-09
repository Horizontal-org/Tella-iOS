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

// MARK: - ViewModel

@MainActor
final class ServerOnboardingViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    var subscribers = Set<AnyCancellable>()

    @Published var isConnectionSucceded: Bool = false
    @Published var index: Int

    let startIndex: Int = 0
    
    let pages: [ServerOnboardingItem] = [
        .main,
        .customizationDone
    ]
    
    init(mainAppModel: MainAppModel) {
        self.index = min(max(startIndex, 0), max(0, pages.count - 1))
        self.mainAppModel = mainAppModel
        
        mainAppModel.tellaData?.shouldReloadServers.sink { completion in
        } receiveValue: { shouldReload in
            if shouldReload {
                self.getServers()
            }
        }.store(in: &subscribers)
    }
    
    func getServers() {
        let serverArray = mainAppModel.tellaData?.getServers() ?? []

        if !serverArray.isEmpty {
            isConnectionSucceded = true
        }
    }

    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    var canGoBack: Bool { index > 0 }
    var canGoNext: Bool { index < lastIndex }
    
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

extension ServerOnboardingViewModel {
    static func stub() -> ServerOnboardingViewModel { ServerOnboardingViewModel(mainAppModel: MainAppModel.stub()) }
}


enum ServerOnboardingItem: Identifiable, Equatable {
    static func == (lhs: ServerOnboardingItem, rhs: ServerOnboardingItem) -> Bool {
        lhs.id == rhs.id
    }
    
    case main
    case customizationDone

    var id: String {
        switch self {
        case .main:                 return "main"
        case .customizationDone:    return "customizationDone"
        }
    }
    
}
