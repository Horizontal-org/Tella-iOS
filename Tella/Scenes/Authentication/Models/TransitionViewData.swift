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
    var title = Localizable.Lock.onboardingIntroHead
    var description = Localizable.Lock.onboardingIntroSubhead
    var buttonTitle = Localizable.Lock.onboardingIntroActionGetStarted
    var alignment = TextAlignment.leading
}

struct OnboardingEndViewData : TransitionViewData {
    var image = "lock.done"
    var title = Localizable.Lock.onboardingdLockSuccessHead
    var description = Localizable.Lock.onboardingLockSuccessSubhead
    var buttonTitle = Localizable.Lock.onboardingLockSuccessActionGoToTella
    var alignment = TextAlignment.center
 }
