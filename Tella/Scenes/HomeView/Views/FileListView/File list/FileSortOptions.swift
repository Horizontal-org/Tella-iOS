//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

enum FileViewType {
    
    case list
    case grid
    
    var image: AnyView {
        switch self {
        case .list:
            return AnyView(Image("files.grid"))
        case .grid:
            return AnyView(Image("files.list"))
        }
    }
    
}

enum FileSortOptions : ActionType {
    case nameAZ
    case nameZA
    case newestToOldest
    case oldestToNewest
    
    var image: AnyView {
        switch self {
        case .nameAZ:
            return AnyView(Image("files.forward"))
        case .nameZA:
            return AnyView(Image("files.forward")
                            .rotationEffect(.degrees(180))
            )
        case .newestToOldest:
            return AnyView(Image("files.forward"))
        case .oldestToNewest:
            return AnyView(Image("files.forward")
                            .rotationEffect(.degrees(180))
            )
        }
    }
    
    var displayName: String {
        switch self {
        case .nameAZ:
            return Localizable.Home.sortByName
        case .nameZA:
            return Localizable.Home.sortByName
        case .newestToOldest:
            return Localizable.Home.sortByDate
        case .oldestToNewest:
            return Localizable.Home.sortByDate
        }
    }
    
    var name: String {
        switch self {
        case .nameAZ:
            return Localizable.Home.sortByAscendingName
        case .nameZA:
            return Localizable.Home.sortByDescendingName
        case .newestToOldest:
            return Localizable.Home.sortByAscendingDate
        case .oldestToNewest:
            return Localizable.Home.sortByDescendingDate
        }
    }
}
