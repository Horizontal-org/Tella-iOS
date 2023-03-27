//
//  LocalizableReport.swift
//  Tella
//
//  Created by Gustavo on 27/03/2023.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableReport: String, LocalizableDelegate {
    
    case reportsTitle = "Reports_Title"
    case reportsText = "Reports_Text"
    case reportsDraftMessage = "Reports_Draft_Message"
    case reportsOutboxMessage = "Reports_Outbox_Message"
    case reportsSubmited = "Reports_Submitted"
    case reportsCreateNew = "Reports_Create_New"

    case reportsListTitle = "Reports_List_Title"
    case reportsListDescription = "Reports_List_Description"
    case reportsListMessage = "Reports_List_Message"
    case reportsSendTo = "Reports_Send_To"
    case audioSavedCorrectly = "Reports_Audio_Saved_Correctly"
    case reportsSubmit = "Reports_Submit"
    case reportsSend = "Reports_Send"

    case selectFiles = "Reports_Select_Files"

    case exitTitle = "Reports_Exit_Title"
    case exitMessage = "Reports_Exit_Message"
    case exitCancel = "Reports_Exit_Cancel"
    case exitSave = "Reports_Exit_Save"

    case draftEmptyMessage = "Reports_Draft_Empty_Message"
    case attachFiles = "Reports_Attach_Files"

    case deleteTitle = "Reports_Delete_Title"
    case deleteMessage = "Reports_Delete_Message"
    case deleteCancel = "Reports_Delete_Cancel"
    case deleteConfirm = "Reports_Delete_Confirm"

    case draftTitle = "Reports_Draft_Title"
    case outboxTitle = "Reports_Outbox_Title"
    case submittedTitle = "Reports_Submitted_Title"

    case viewModelDelete = "Reports_ViewModel_Delete"

    case selectProject = "Reports_Select_Project"
    case cameraFilled = "Reports_Camera_Filled"
    case micFilled = "Reports_Mic_Filled"
    case galleryFilled = "Reports_Gallery_Filled"
    case phoneFilled = "Reports_Phone_Filled"

    case waitingConnection = "Reports_Waiting_Connection"
}
