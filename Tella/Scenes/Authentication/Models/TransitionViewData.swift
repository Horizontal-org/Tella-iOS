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
    var title = Localizable.Lock.welcomeTitle
    var description = Localizable.Lock.welcomeDescription
    var buttonTitle = Localizable.Lock.welcomeButtonTitle
}

struct OnboardingEndViewData : TransitionViewData {
    var image = "lock.done"
    var title = Localizable.Lock.onboardingEndTitle
    var description = Localizable.Lock.onboardingEndDescription
    var buttonTitle = Localizable.Lock.onboardingEndButtonTitle 
}
