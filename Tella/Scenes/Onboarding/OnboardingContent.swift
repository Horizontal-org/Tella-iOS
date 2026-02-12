//
//  OnboardingContent.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

struct RecordContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .onboardRecord
    var title: String = LocalizableLock.onboardingRecordTitle.localized
    var message: String = LocalizableLock.onboardingRecordExpl.localized
}

struct FilesContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .onboardFiles
    var title: String = LocalizableLock.onboardingFilesTitle.localized
    var message: String = LocalizableLock.onboardingFilesExpl.localized
}

struct ConnectionsContent: ImageTitleMessageContent {
    var imageName: ImageResource? = nil
    var title: String = LocalizableLock.onboardingConnectionsTitle.localized
    var message: String {
        LocalizableLock.onboardingConnectionspart1Expl.localized
            .addTwolines +
        LocalizableLock.onboardingConnectionspart2Expl.localized
    }
}

struct NearbySharingContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .onboardNearbysharing
    var title: String = LocalizableLock.onboardingNearbySharingTitle.localized
    var message: String = LocalizableLock.onboardingNearbySharingExpl.localized
}

struct SuccessLockContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .settingsCheckedCircle
    var title: String = LocalizableLock.lockSuccessTitle.localized
    var message: String = LocalizableLock.lockSuccessExpl.localized
}

struct ServerConnectedContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .settingsServer
    var title: String = LocalizableLock.onboardingServerConnectedTitle.localized
    var message: String = LocalizableLock.onboardingServerConnectedExpl.localized
}

struct LockDoneContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .lockDone
    var title: String = LocalizableLock.onboardingLockDoneTitle.localized
    var message: String = LocalizableLock.onboardingLockDoneExpl.localized
}

struct MainServerOnboardingContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .onboardServer
    var title: String = LocalizableLock.onboardingServerMainTitle.localized
    var message: String = LocalizableLock.onboardingServerMainExpl.localized
}

struct AdvancedCustomizationComplete: ImageTitleMessageContent {
    var imageName: ImageResource? = .lockDone
    var title: String = LocalizableLock.onboardingServerDoneTitle.localized
    var message: String = LocalizableLock.onboardingServerDoneExpl.localized
}


struct LoseFilesWarningOnboardingContent: ImageTitleMessageContent {
    var imageName: ImageResource? = .onboardWarning
    var title: String = LocalizableLock.onboardingLoseFileWarningTitle.localized
    var message: String {
        LocalizableLock.onboardingLoseFileWarningPart1Expl.localized
            .addTwolines +
        LocalizableLock.onboardingLoseFileWarningPart2Expl.localized
    }
}
