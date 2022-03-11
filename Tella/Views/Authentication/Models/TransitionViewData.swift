//
//  Copyright © 2022 INTERNEWS. All rights reserved.
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
    var title = LocalizableLock.welcomeTitle.localized
    var description = LocalizableLock.welcomeDescription.localized
    var buttonTitle = LocalizableLock.welcomeButtonTitle.localized
}

struct OnboardingEndViewData : TransitionViewData {
    var image = "lock.done"
    var title = LocalizableLock.onboardingEndTitle.localized
    var description = LocalizableLock.onboardingEndDescription.localized
    var buttonTitle = LocalizableLock.onboardingEndButtonTitle.localized
}
