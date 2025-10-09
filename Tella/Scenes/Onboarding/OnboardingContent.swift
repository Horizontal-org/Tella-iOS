//
//  OnboardingContent.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


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

struct SuccessLockContent: OnboardingContent {
    var imageName: ImageResource = .lockPhone
    var title: String = LocalizableLock.onboardingLockSuccessTitle.localized
    var message: String = LocalizableLock.onboardingLockSuccessExpl.localized
}

struct ServerConnectedContent: OnboardingContent {
    var imageName: ImageResource = .settingsServer
    var title: String = LocalizableLock.onboardingServerConnectedTitle.localized
    var message: String = LocalizableLock.onboardingServerConnectedExpl.localized
}

struct LockDoneContent: OnboardingContent {
    var imageName: ImageResource = .lockDone
    var title: String = LocalizableLock.onboardingLockDoneTitle.localized
    var message: String = LocalizableLock.onboardingLockDoneExpl.localized
}

struct MainServerOnboardingContent: OnboardingContent {
    var imageName: ImageResource = .settingsServer
    var title: String = LocalizableLock.onboardingServerMainTitle.localized
    var message: String = LocalizableLock.onboardingServerMainExpl.localized
}

struct AdvancedCustomizationComplete: OnboardingContent {
    var imageName: ImageResource = .lockDone
    var title: String = LocalizableLock.onboardingServerDoneTitle.localized
    var message: String = LocalizableLock.onboardingServerDoneExpl.localized
}
