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
    var title = "Welcome to Tella"
    var description = "Document & Protect"
    var buttonTitle = "GET STARTED"
}

struct OnboardingEndViewData : TransitionViewData {
    var image = "lock.done"
    var title = "You’re all done!"
    var description = "You can always continue changing your preferences in Settings. "
    var buttonTitle = "GO TO TELLA"
}
