//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

protocol TransitionViewData {
    var image: String {get}
    var title: String {get}
    var description: String {get}
    var buttonTitle: String {get}
}

struct WelcomeViewData : TransitionViewData {
    var image = "lock.welcome"
    var title = LocalizableLock.onboardingIntroHead.localized
    var description = LocalizableLock.onboardingIntroSubhead.localized
    var buttonTitle = LocalizableLock.onboardingIntroActionGetStarted.localized
}
