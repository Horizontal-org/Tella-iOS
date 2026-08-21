//
//  MainOnboardingViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine
import SwiftUI

@MainActor
final class MainOnboardingViewModel: ObservableObject {
    @Published var index: Int
    @Published var lockViewModel: LockViewModel
    
    private let startIndex: Int = 0
    private var subscribers = Set<AnyCancellable>()
    
    let pages: [OnboardingItem] = [
        .welcome,
        .record(RecordContent()),
        .files(FilesContent()),
        .connections(ConnectionsContent()),
        .nearbySharing(NearbySharingContent()),
        .lockChoice,
        .allDone
    ]
    
    init(lockViewModel: LockViewModel) {
        self.index = max(0, min(startIndex, pages.count - 1))
        self.lockViewModel = lockViewModel
        
        lockViewModel.shouldDismiss
            .filter { $0 }
            .sink { [weak self] _ in
                self?.goNext(animated: false)
            }
            .store(in: &subscribers)
    }
    
    // MARK: - States
    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    var dotCount: Int { max(0, count - 1) }
    var dotIndex: Int { max(0, index - 1) }
    
    var currentPage: OnboardingItem {
        pages[safe: index] ?? .welcome
    }

    var isOnWelcome: Bool {
        if case .welcome = currentPage { return true }
        return false
    }
    
    var isOnWelcome: Bool {
        if case .welcome = currentPage { return true }
        return false
    }
    
    var isOnAllDone: Bool {
        if case .allDone = currentPage { return true }
        return false
    }
    
    func canTapNext() -> Bool {
        switch currentPage {
        case .lockChoice, .allDone: return false
        default:       return index < lastIndex
        }
    }
    
    func canTapBack() -> Bool {
        switch currentPage {
        case .allDone: return true
        default:       return index > 0
        }
    }
    
    func shouldHideNext() -> Bool { !canTapNext() }
    func shouldHideBack() -> Bool { isOnAllDone }
    
    // MARK: - Navigation
    func goToPage(_ newIndex: Int, animated: Bool = true) {
        guard count > 0 else { return }
        let clampedIndex = min(max(newIndex, 0), lastIndex)
        if animated {
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.2)) {
                index = clampedIndex
            }
        } else {
            index = clampedIndex
        }
    }
    func goNext(animated: Bool = true) { goToPage(index + 1, animated: animated) }
    func goBack(animated: Bool = true) { goToPage(index - 1, animated: animated) }
    
    func handleSwipe(for page: OnboardingItem, direction: SwipeDirection) -> Bool {
        switch page {
        case .welcome:
            return false
        case .record, .files, .connections, .nearbySharing:
            return true
        case .lockChoice:
            return direction == .right
        case .allDone:
            return false
        }
    }
}

enum OnboardingItem: Identifiable, Equatable {
    static func == (lhs: OnboardingItem, rhs: OnboardingItem) -> Bool {
        lhs.id == rhs.id
    }
    
    case welcome
    case record(any ImageTitleMessageContent)
    case files(any ImageTitleMessageContent)
    case connections(any ImageTitleMessageContent)
    case nearbySharing(any ImageTitleMessageContent)
    case lockChoice
    case allDone
    
    var id: String {
        
        switch self {
        case .welcome:
            return "welcome"
        case .record:
            return "record"
        case .files:
            return "files"
        case .connections:
            return "connections"
        case .nearbySharing:
            return "nearbySharing"
        case .lockChoice:
            return "lockChoice"
        case .allDone:
            return "allDone"
        }
    }
}

extension MainOnboardingViewModel {
    static func stub() -> MainOnboardingViewModel {
        MainOnboardingViewModel(lockViewModel: LockViewModel.stub())
    }
}
