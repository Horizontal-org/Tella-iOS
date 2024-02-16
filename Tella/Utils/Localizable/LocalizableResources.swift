//
//  LocalizableResources.swift
//  Tella
//
//  Created by gus valbuena on 2/5/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

enum LocalizableResources : String, LocalizableDelegate {
    case resourcesServerTitle = "Resources_Home_Serve_title"

    case resourcesDownloadedTitle = "Resources_Downloaded_Title"
    case resourcesDownloadedEmpty = "Resources_Downloaded_Empty"
    
    case resourcesAvailableTitle = "Resources_Available_Title"
    case resourcesAvailableMsg = "Resources_Available_Msg"
    case resourcesAvailableEmpty = "Resources_Available_Empty"
    case resourcesAvailableErrorMsg = "Resources_Available_ErrorMsg"
}
