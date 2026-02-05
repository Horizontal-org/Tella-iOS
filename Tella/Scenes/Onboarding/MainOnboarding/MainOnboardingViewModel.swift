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
        .record(RecordContent()),
        .files(FilesContent()),
        .connections(ConnectionsContent()),
        .nearbySharing(NearbySharingContent()),
        .allDone
    ]
    
    init(lockViewModel: LockViewModel) {
        self.index = max(0, min(startIndex, pages.count - 1))
        self.lockViewModel = lockViewModel
        
        lockViewModel.shouldDismiss
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.goNext()
            }
            .store(in: &subscribers)
    }
    
    // MARK: - States
    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    
    var currentPage: OnboardingItem {
        pages[safe: index] ?? .record(RecordContent())
    }
    
    var isOnAllDone: Bool {
        if case .allDone = currentPage { return true }
        return false
    }
    
    func canTapNext() -> Bool {
        switch currentPage {
        case .allDone: return false
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
    func goToPage(_ newIndex: Int) {
        guard count > 0 else { return }
        index = min(max(newIndex, 0), lastIndex)
    }
    func goNext() { goToPage(index + 1) }
    func goBack() { goToPage(index - 1) }
    
    func handleSwipe(for page: OnboardingItem, direction: SwipeDirection) -> Bool {
        switch page {
        case .record:
            return direction == .left
        case .files, .connections:
            return true
        case .nearbySharing:
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
    
    case record(any ImageTitleMessageContent)
    case files(any ImageTitleMessageContent)
    case connections(any ImageTitleMessageContent)
    case nearbySharing(any ImageTitleMessageContent)
    case allDone
    
    var id: String {
        
        switch self {
        case .record:
            return "record"
        case .files:
            return "files"
        case .connections:
            return "connections"
        case .nearbySharing:
            return "nearbySharing"
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
