//
//  LocalizableReport.swift
//  Tella
//
//  Created by Gustavo on 27/03/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
    case deleteDraftTitle = "Reports_DeleteReport_Draft_SheetTitle"

    case deleteDraftReportMessage = "Reports_DeleteDraftReport_SheetExpl"
    case deleteOutboxReportMessage = "Reports_DeleteOutboxReport_SheetExpl"
    case deleteSubmittedReportMessage = "Reports_DeleteSubmittedReport_SheetExpl"
    case deleteCancel = "Reports_DeleteReport_Cancel_SheetAction"
    case deleteConfirm = "Reports_DeleteReport_Delete_SheetAction"
    
    case draftTitle = "Reports_PageViewItem_Draft"
    case outboxTitle = "Reports_PageViewItem_Outbox"
    case submittedTitle = "Reports_PageViewItem_Submitted"
    case clearAppBar = "Reports_Submitted_Clear_AppBar"
    case clearSheetTitle = "Reports_Submitted_ClearAll_SheetTitle"
    case clearSheetExpl = "Reports_Submitted_ClearAll_SheetExpl"
    case clearCancel = "Reports_Submitted_ClearAll_Cancel_SheetAction"
    case clearSubmitted = "Reports_Submitted_ClearAll_ClearSubmitted_SheetAction"
    
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
    
    
    case draftSavedToast = "Reports_DraftSaved_Toast"
    case reportDeletedToast = "Reports_ReportDeleted_Toast"
    case reportSubmittedToast = "Reports_ReportSubmitted_Toast"
    case outboxSavedToast = "Reports_OutboxSaved_Toast"
    case allReportDeletedToast = "Reports_AllReportDeleted_Toast"
    
    case draftListExpl = "Reports_Draft_DraftList_Expl"
    case outboxListExpl = "Reports_Outbox_OutboxList_Expl"
    case submittedListExpl = "Reports_Submitted_SubmittedList_Expl"
    
    case exitReportSheetTitle = "Reports_Outbox_ExitReport_SheetTitle"
    case exitReportSheetExpl = "Reports_Outbox_ExitReport_SheetExpl"
    case exitReportExitSheetAction = "Reports_Outbox_ExitReport_Exit_SheetAction"
    case exitReportCancelSheetAction = "Reports_Outbox_ExitReport_Cancel_SheetAction"
  
    case pausedCardExpl = "Reports_Paused_CardExpl"
}
