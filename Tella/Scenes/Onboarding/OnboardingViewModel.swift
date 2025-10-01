//
//  OnboardingViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ViewModel

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var index: Int
    let startIndex: Int = 0
    
    let pages: [OnboardingItem] = [
        .intro(CameraContent()),
        .intro(MicContent()),
        .intro(FilesContent()),
        .intro(ConnectionsContent()),
        .intro(NearbySharingContent()),
        .lock
    ]
    
    init() {
        self.index = min(max(startIndex, 0), max(0, pages.count - 1))
    }
    
    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    var canGoBack: Bool { index > 0 }
    var canGoNext: Bool { index < lastIndex }
    
    func goToPage(_ newIndex: Int) {
        guard count > 0 else { return }
        index = min(max(newIndex, 0), lastIndex)
    }
    func goNext() { goToPage(index + 1) }
    func goBack() { goToPage(index - 1) }
}

extension OnboardingViewModel {
    static func stub() -> OnboardingViewModel { OnboardingViewModel() }
}

// MARK: - Model

enum OnboardingType: String, Codable, CaseIterable, Hashable {
    case intro
    case lock
    case lockSuccess
    case allDone
}

enum OnboardingItem: Identifiable, Equatable {
    static func == (lhs: OnboardingItem, rhs: OnboardingItem) -> Bool {
        lhs.id == rhs.id
    }
    
    case intro(any OnboardingContent)
    case lock
    case lockSuccess
    case allDone
    
    var id: String {
        switch self {
        case .intro(let content): return "intro-\(content.hashValue)"
        case .lock:               return "lock"
        case .lockSuccess:        return "lockSuccess"
        case .allDone:            return "allDone"
        }
    }
    
    var type: OnboardingType {
        switch self {
        case .intro:        return .intro
        case .lock:         return .lock
        case .lockSuccess:  return .lockSuccess
        case .allDone:      return .allDone
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case let .intro(content):
            OnboardingPageView(content: content)
            
        case .lock:
            LockChoiceView()
            
        case .lockSuccess:
            LockChoiceView()
            
        case .allDone:
            LockChoiceView()
        }
    }
}
// MARK: - Content protocol & concrete content

protocol OnboardingContent: Hashable {
    var imageName: ImageResource { get }
    var title: String { get }
    var message: String { get }
}

struct CameraContent: OnboardingContent {
    var imageName: ImageResource = .onboardCamera
    var title: String = LocalizableLock.onboardingCameraTitle.localized
    var message: String = LocalizableLock.onboardingCameraExpl.localized
}

struct MicContent: OnboardingContent {
    var imageName: ImageResource = .onboardMic
    var title: String = LocalizableLock.onboardingRecorderTitle.localized
    var message: String = LocalizableLock.onboardingRecorderExpl.localized
}

struct FilesContent: OnboardingContent {
    var imageName: ImageResource = .onboardFiles
    var title: String = LocalizableLock.onboardingEncryptedFilesFoldersTitle.localized
    var message: String = LocalizableLock.onboardingEncryptedFilesFoldersExpl.localized
}

struct ConnectionsContent: OnboardingContent {
    var imageName: ImageResource = .onboardConnections
    var title: String = LocalizableLock.onboardingServerConnectionsTitle.localized
    var message: String =
    LocalizableLock.onboardingServerConnectionspart1Expl.localized + "\n\n" +
    LocalizableLock.onboardingServerConnectionspart2Expl.localized
}

struct NearbySharingContent: OnboardingContent {
    var imageName: ImageResource = .onboardNearbysharing
    var title: String = LocalizableLock.onboardingNearbySharingTitle.localized
    var message: String = LocalizableLock.onboardingNearbySharingExpl.localized
}
