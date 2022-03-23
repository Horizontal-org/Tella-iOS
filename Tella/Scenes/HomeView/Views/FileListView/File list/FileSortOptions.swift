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

enum FileSortOptions {
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
            return NSLocalizedString("Name", comment: "File sort menu")
        case .nameZA:
            return NSLocalizedString("Name", comment: "File sort menu")
        case .newestToOldest:
            return NSLocalizedString("Date", comment: "File sort menu")
        case .oldestToNewest:
            return NSLocalizedString("Date", comment: "File sort menu")
        }
    }

    var name: String {
        switch self {
        case .nameAZ:
            return NSLocalizedString("Name A > Z", comment: "File sort menu")
        case .nameZA:
            return NSLocalizedString("Name Z > A", comment: "File sort menu")
        case .newestToOldest:
            return NSLocalizedString("Newest to oldest", comment: "File sort menu")
        case .oldestToNewest:
            return NSLocalizedString("Oldest to newest", comment: "File sort menu")
        }
    }
}
