//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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


extension FileSortOptions  {

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
            return LocalizableVault.sortByName.localized
        case .nameZA:
            return LocalizableVault.sortByName.localized
        case .newestToOldest:
            return LocalizableVault.sortByDate.localized
        case .oldestToNewest:
            return LocalizableVault.sortByDate.localized
        }
    }
    
    var name: String {
        switch self {
        case .nameAZ:
            return LocalizableVault.sortByAscendingNameSheetSelect.localized
        case .nameZA:
            return LocalizableVault.sortByDescendingNameSheetSelect.localized
        case .newestToOldest:
            return LocalizableVault.sortByAscendingDateSheetSelect.localized
        case .oldestToNewest:
            return LocalizableVault.sortByDescendingDateSheetSelect.localized
        }
    }
}
