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
case reportsText = "Reports_Report_AppBar"
case reportsDraftEmpty = "Reports_Draft_EmptyAllFiles_Expl"
case reportsOutboxEmpty = "Reports_Outbox_EmptyAllFiles_Expl"
case reportsSubmitedEmpty = "Reports_Submitted_EmptyAllFiles_Expl"
case reportsCreateNew = "Reports_Action_NewReport"

case reportsListTitle = "Reports_Draft_Select_Title"
case reportsListDescription = "Reports_Draft_Select_Description"
case reportsListMessage = "Reports_Draft_Select_Message"

case reportsSendTo = "Reports_Draft_SendTo"
case audioSavedCorrectly = "Reports_Draft_SuccessMessage"
case reportsSubmit = "Reports_Draft_Action_Submit"
case reportsSend = "Reports_Draft__Action_Send"
case selectFiles = "Reports_Draft_SelectFiles"

case exitTitle = "Reports_Draft_ExitReport_SheetTitle"
case exitMessage = "Reports_Draft_ExitReport_SheetExpl"
case exitCancel = "Reports_Draft_ExitReport_Exit_SheetAction"
case exitSave = "Reports_Draft_ExitReport_Save_SheetAction"

case attachFiles = "Reports_Draft_AddFiles"

case deleteTitle = "Reports_DeleteReport_SheetTitle"
case deleteMessage = "Reports_DeleteReport_SheetExpl"
case deleteCancel = "Reports_DeleteReport_Cancel_SheetAction"
case deleteConfirm = "Reports_DeleteReport_Delete_SheetAction"

case draftTitle = "Reports_PageViewItem_Draft"
case outboxTitle = "Reports_PageViewItem_Outbox"
case submittedTitle = "Reports_PageViewItem_Submitted"
case viewModelDelete = "Reports_ManageReport_Delete_SheetAction"
case viewModelEdit = "Reports_ManageReport_Edit_SheetAction"
case viewModelView = "Reports_ManageReport_View_SheetAction"
case viewModelOpen = "Reports_ManageReport_Open_SheetAction"
case selectProject = "Reports_Draft_Select_SelectProject"

case cameraFilled = "Reports_Draft_SelectFiles_TakePhotoVideo_SheetSelect"
case micFilled = "Reports_Draft_Record_SheetSelect"
case galleryFilled = "Reports_Draft_SelectFiles_TellaFiles_SheetSelect"
case phoneFilled = "Reports_Draft_SelectFiles_ImportFromDevice_SheetSelect"
case waitingConnection = "Reports_Outbox_PercentangeUploaded_Expl"
}
