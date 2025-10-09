//
//  MainOnboardingViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import SwiftUI

// MARK: - ViewModel

@MainActor
final class MainOnboardingViewModel: ObservableObject {
    @Published var index: Int
    private let startIndex: Int = 0
    
    let pages: [OnboardingItem] = [
        .camera(CameraContent()),
        .recorder(MicContent()),
        .files(FilesContent()),
        .connections(ConnectionsContent()),
        .nearbySharing(NearbySharingContent()),
        .lock,
        .allDone
    ]
    
    init() {
        self.index = min(max(startIndex, 0), max(0, pages.count - 1))
    }
    
    // MARK: - States
    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    var canGoBack: Bool { index > 0 }
    var canGoNext: Bool { index < lastIndex }
    
    var currentPage: OnboardingItem {
        pages[safe: index] ?? .camera(CameraContent())
    }
    
    var isOnLock: Bool {
        if case .lock = currentPage { return true }
        return false
    }
    
    var isOnAllDone: Bool {
        if case .allDone = currentPage { return true }
        return false
    }
    
    var isSwipeAllowed: Bool {
        !isOnLock && !isOnAllDone
    }
    
    func shouldHideNext(isLockSucceeded: Bool) -> Bool {
        (isOnLock && !isLockSucceeded) || isOnAllDone
    }
    
    func shouldHideBack(isLockSucceeded: Bool) -> Bool {
        (isOnLock && isLockSucceeded) || isOnAllDone
    }
    
    // MARK: - Navigation
    func goToPage(_ newIndex: Int) {
        guard count > 0 else { return }
        index = min(max(newIndex, 0), lastIndex)
    }
    func goNext() { goToPage(index + 1) }
    func goBack() { goToPage(index - 1) }
}

enum OnboardingItem: Identifiable, Equatable {
    static func == (lhs: OnboardingItem, rhs: OnboardingItem) -> Bool {
        lhs.id == rhs.id
    }
    
    case camera(any OnboardingContent)
    case recorder(any OnboardingContent)
    case files(any OnboardingContent)
    case connections(any OnboardingContent)
    case nearbySharing(any OnboardingContent)
    case lock
    case allDone
    
    var id: String {
        
        switch self {
        case .camera:
            return "camera"
        case .recorder:
            return "recorder"
        case .files:
            return "files"
        case .connections:
            return "connections"
        case .nearbySharing:
            return "nearbySharing"
        case .lock:
            return "lock"
        case .allDone:
            return "allDone"
        }
    }
}

extension MainOnboardingViewModel {
    static func stub() -> MainOnboardingViewModel { MainOnboardingViewModel() }
}
