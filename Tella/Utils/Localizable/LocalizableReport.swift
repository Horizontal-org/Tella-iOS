//
//  LocalizableReport.swift
//  Tella
//
//  Created by Gustavo on 27/03/2023.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableReport: String, LocalizableDelegate {

    case reportsTitle = "Reports_ReportsView_Title"
    case reportsText = "Reports_Draft_Title"
    case reportsDraftMessage = "Reports_ReportsView_DraftMessage"
    case reportsOutboxMessage = "Reports_ReportsView_OutboxMessage"
    case reportsSubmited = "Reports_ReportsView_Submitted"
    case reportsCreateNew = "Reports_ReportsView_CreateNew"

    case reportsListTitle = "Reports_ReportsList_Title"
    case reportsListDescription = "Reports_ReportsList_Description"
    case reportsListMessage = "Reports_ReportsList_Message"

    case reportsSendTo = "Reports_Draft_SendTo"
    case audioSavedCorrectly = "Reports_Draft_SuccessMessage"
    case reportsSubmit = "Reports_Draft_Submit"
    case reportsSend = "Reports_Draft_Send"
    case selectFiles = "Reports_Draft_SelectFiles"
    case exitTitle = "Reports_Draft_ExitTitle"
    case exitMessage = "Reports_Draft_ExitMessage"
    case exitCancel = "Reports_Draft_ExitCancel"
    case exitSave = "Reports_Draft_ExitSave"

    case draftEmptyMessage = "Reports_Draft_EmptyMessage"
    case attachFiles = "Reports_Draft_AddFiles"

    case deleteTitle = "Reports_Submitted_DeleteTitle"
    case deleteMessage = "Reports_Submitted_DeleteMessage"
    case deleteCancel = "Reports_Submitted_CancelDelete"
    case deleteConfirm = "Reports_Submitted_ConfirmDelete"

    case draftTitle = "Reports_ViewModel_DraftTitle"
    case outboxTitle = "Reports_ViewModel_OutboxTitle"
    case submittedTitle = "Reports_ViewModel_SubmittedTitle"
    case viewModelDelete = "Reports_ViewModel_Delete"
    case selectProject = "Reports_ViewModel_SelectProject"
    case cameraFilled = "Reports_ViewModel_Camera"
    case micFilled = "Reports_ViewModel_Mic"
    case galleryFilled = "Reports_ViewModel_Gallery"
    case phoneFilled = "Reports_ViewModel_Phone"
    case waitingConnection = "Reports_ViewModel_WaitingConnection"
}
