//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

protocol TransitionViewData {
    var image: String {get}
    var title: String {get}
    var description: String {get}
    var buttonTitle: String {get}
    var alignment: TextAlignment {get}
}

struct WelcomeViewData : TransitionViewData {
    var image = "lock.welcome"
    var title = LocalizableLock.onboardingIntroHead.localized
    var description = LocalizableLock.onboardingIntroSubhead.localized
    var buttonTitle = LocalizableLock.onboardingIntroActionGetStarted.localized
    var alignment = TextAlignment.leading
}

struct OnboardingEndViewData : TransitionViewData {
    var image = "lock.done"
    var title = LocalizableLock.onboardingdLockSuccessHead.localized
    var description = LocalizableLock.onboardingLockSuccessSubhead.localized
    var buttonTitle = LocalizableLock.onboardingLockSuccessActionGoToTella.localized
    var alignment = TextAlignment.center
}
