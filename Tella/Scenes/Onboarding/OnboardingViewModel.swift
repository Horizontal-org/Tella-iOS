//
//  OnboardingViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var index: Int
    let startIndex: Int = 0
    
    let pages: [OnboardingItem] = [OnboardingItem(imageName: .onboardCamera,
                                                  title: LocalizableLock.onboardingCameraTitle.localized,
                                                  message: LocalizableLock.onboardingCameraExpl.localized),
                                   
                                   OnboardingItem(imageName: .onboardMic,
                                                  title: LocalizableLock.onboardingRecorderTitle.localized ,
                                                  message: LocalizableLock.onboardingRecorderExpl.localized),
                                   
                                   OnboardingItem(imageName: .onboardFiles,
                                                  title: LocalizableLock.onboardingEncryptedFilesFoldersTitle.localized ,
                                                  message: LocalizableLock.onboardingEncryptedFilesFoldersExpl.localized),
                                   
                                   OnboardingItem(imageName: .onboardConnections,
                                                  title: LocalizableLock.onboardingServerConnectionsTitle.localized ,
                                                  message: LocalizableLock.onboardingServerConnectionspart1Expl.localized + "\n\n" +
                                                  LocalizableLock.onboardingServerConnectionspart1Expl.localized),
                                   
                                   OnboardingItem(imageName: .onboardNearbysharing,
                                                  title: LocalizableLock.onboardingNearbySharingTitle.localized ,
                                                  message: LocalizableLock.onboardingNearbySharingExpl.localized),
    ]
    
    init() {
        self.index = min(max(startIndex, 0), max(0, pages.count - 1))
    }
    
    var count: Int { pages.count }
    var lastIndex: Int { max(0, count - 1) }
    
    var canGoBack: Bool { index > 0 }
    var canGoNext: Bool { index < lastIndex }
    
    func goToPage(_ newIndex: Int, animated: Bool = true) {
        guard count > 0 else { return }
        let clamped = min(max(newIndex, 0), lastIndex)
        index = clamped
    }
    
    func goNext() { goToPage(index + 1) }
    func goBack() { goToPage(index - 1) }
}



// MARK: - Model
struct OnboardingItem: Identifiable, Hashable {
    let id = UUID()
    let imageName: ImageResource
    let title: String
    let message: String
}
