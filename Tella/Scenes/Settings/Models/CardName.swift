//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

protocol CardName {}

enum MainSettingsCardName : CardName {
    case general
    case security
    case servers
    case aboutAndHelp
}

enum GeneralCardName : CardName {
    case language
    case recentFile
}

enum SecurityCardName : CardName {
    case lock
    case lockTimeout
    case screenSecurity
}

enum AboutAndHelpCardName : CardName {
    case contactUs
    case privacy
}
