//
//  LocalizableReport.swift
//  Tella
//
//  Created by Gustavo on 27/03/2023.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableReport: String, LocalizableDelegate {

    case reportsTitle = "Reports_AppBar"
    case reportsText = "Reports_AppBar_SubHead"
    case reportsDraftEmpty = "Reports_Draft_EmptyAllFiles_Expl"
    case reportsOutboxEmpty = "Reports_Outbox_EmptyAllFiles_Expl"
    case reportsSubmitedEmpty = "Reports_Submitted_EmptyAllFiles_Expl"
    case reportsCreateNew = "Reports_ReportsView_CreateNew"

    case reportsListTitle = "Reports_ReportsList_Title"
    case reportsListDescription = "Reports_ReportsList_Description"
    case reportsListMessage = "Reports_ReportsList_Message"

    case reportsSendTo = "Reports_Draft_SendTo"
    case audioSavedCorrectly = "Reports_Draft_SuccessMessage"
    case reportsSubmit = "Reports_Draft_Submit"
    case reportsSend = "Reports_Draft_Send"
    case selectFiles = "Reports_Draft_SelectFiles"

    case exitTitle = "Reports_ExitReport_SheetTitle"
    case exitMessage = "Reports_ExitReport_SheetExpl"
    case exitCancel = "Reports_ExitReport_Exit_SheetAction"
    case exitSave = "Reports_ExitReport_Save_SheetAction"

    case attachFiles = "Reports_Draft_AddFiles"

    case deleteTitle = "Reports_DeleteFile_SheetTitle"
    case deleteMessage = "Reports_DeleteFile_SheetExpl"
    case deleteCancel = "Reports_DeleteFile_Cancel_SheetAction"
    case deleteConfirm = "Reports_DeleteFile_Delete_SheetAction"

    case draftTitle = "Reports_PageViewItem_Draft"
    case outboxTitle = "Reports_PageViewItem_Outbox"
    case submittedTitle = "Reports_PageViewItem_Submitted"
    case viewModelDelete = "Reports_ListItem_Delete_SheetAction"
    case selectProject = "Reports_Connections_SelectProject"

    case cameraFilled = "Reports_ManageFiles_TakePhotoVideo_SheetSelect"
    case micFilled = "Reports_ManageFiles_Record_SheetSelect"
    case galleryFilled = "Reports_ManageFiles_TellaFiles_SheetSelect"
    case phoneFilled = "Reports_ManageFiles_ImportFromDevice_SheetSelect"
    case waitingConnection = "Reports_Outbox_PercentangeUploaded_Expl"
}
