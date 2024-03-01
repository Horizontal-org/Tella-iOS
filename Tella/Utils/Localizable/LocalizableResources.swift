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
    case resourcesDownloadedSecondMsg = "Resources_Downloaded_Empty_SecondMsg"
    case resourcesDownloadedRemoveSheetSelect = "Resource_Downloaded_Remove_SheetSelect"
    case resourcesDownloadViewSheetSelect = "Resources_Downloaded_View_SheetSelect"
    case resourcesDownloadRemoveSheetTitle = "Resources_Downloaded_Remove_SheetTitle"
    case resourcesDownloadRemoveSheetExpl = "Resources_Downloaded_Remove_SheetExpl"
    case resourcesDownloadRemoveCancelSheetAction = "Resources_Downloaded_Remove_Cancel_SheetAction"
    case resourccesDownloadRemoveConfirmSheetAction = "Resources_Downloaded_Remove_Confirm_SheetAction"
    case resourcesDownloadRemoveToast = "Resources_Downloaded_Remove_Toast"
    
    case resourcesAvailableTitle = "Resources_Available_Title"
    case resourcesAvailableMsg = "Resources_Available_Msg"
    case resourcesAvailableEmpty = "Resources_Available_Empty"
    case resourcesAvailableErrorMsg = "Resources_Available_ErrorMsg"
}
