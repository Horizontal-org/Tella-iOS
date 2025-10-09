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
        .intro(CameraContent()),
        .intro(MicContent()),
        .intro(FilesContent()),
        .intro(ConnectionsContent()),
        .intro(NearbySharingContent()),
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
        pages[safe: index] ?? .intro(CameraContent())
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
    
    case intro(any OnboardingContent)
    case lock
    case allDone
    
    var id: String {
        switch self {
        case .intro(let content): return "intro-\(content.hashValue)"
        case .lock:               return "lock"
        case .allDone:            return "allDone"
        }
    }
}

extension MainOnboardingViewModel {
    static func stub() -> MainOnboardingViewModel { MainOnboardingViewModel() }
}
