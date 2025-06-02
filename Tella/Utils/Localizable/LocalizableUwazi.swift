//
//  LocalizableUwazi.swift
//  Tella
//
//  Created by Gustavo on 23/08/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum LocalizableUwazi: String, LocalizableDelegate {
    
    case uwaziTitle = "Uwazi_AppBar"
    
    case uwaziServerEdit = "Uwazi_Server_Edit_SheetAction"
    case uwaziServerDelete = "Uwazi_Server_Delete_SheetAction"
    
    case uwaziPageViewTemplate = "Uwazi_PageViewItem_Template"
    case uwaziPageViewDraft = "Uwazi_PageViewItem_Draft"
    case uwaziPageViewOutbox = "Uwazi_PageViewItem_Outbox"
    case uwaziPageViewSubmitted = "Uwazi_PageViewItem_Submitted"
    
    case uwaziTemplateListExpl = "Uwazi_Template_TemplateList_Expl"
    case uwaziTemplateListEmptyExpl = "Uwazi_Template_TemplateList_EmptyExpl"
    
    case uwaziAddTemplateTitle = "Uwazi_Template_AddTemplate_Title"
    case uwaziAddTemplateExpl = "Uwazi_Template_AddTemplate_Expl"
    case uwaziAddTemplateSecondExpl = "Uwazi_Template_AddTemplate_SecondExpl"
    case uwaziAddTemplateSavedToast = "Uwazi_Template_AddTemplateSaved_Toast"
    
    case uwaziAddTemplateEmptydExpl = "Uwazi_Template_AddTemplate_EmptyExpl"
    case uwaziDeleteTemplateExpl = "Uwazi_DeleteTemplate_SheetExpl"
    
    
    case uwaziDeletedToast = "Uwazi_Deleted_Toast"

    
    case uwaziCreateEntitySheetExpl = "Uwazi_Template_CreateEntity_SheetAction"
    case uwaziDeleteFromDevice = "Uwazi_Template_DeleteFromDevice_SheetAction"
    case uwaziDeleteTemplate = "Uwazi_Template_DeleteTemplate_SheetAction"

    
    
    case uwaziEntityExitSheetTitle = "Uwazi_Entity_ExitEntity_SheetTitle"
    case uwaziEntityExitSheetExpl = "Uwazi_Entity_ExitEntity_SheetExpl"
    case uwaziEntityUnsopportedProperty = "Uwazi_Entity_Property_Unsopported"
    case uwaziEntityActionNext = "Uwazi_Entity_Action_Next"
    case uwaziEntityMandatoryExpl = "Uwazi_Entity_Mandatory_Expl"
    case uwaziMultiFileWidgetPrimaryDocuments = "Uwazi_Entity_MultiFile_PrimaryDocument"
    case uwaziMultiFileWidgetAttachManyPDFFiles = "Uwazi_Entity_MultiFile_AttachManyPDFFiles"
    case uwaziMultiFileWidgetAttachManyPDFFilesSelectTitle = "Uwazi_Entity_MultiFile_AttachManyPDFFiles_SelectTitle"
    case uwaziMultiFileWidgetSupportingFiles = "Uwazi_Entity_MultiFile_SupportingFiles"
    case uwaziMultiFileWidgetSelectManyFiles = "Uwazi_Entity_MultiFile_SupportingFiles_HelpText"
    
    case uwaziEntitySubmitted = "Uwazi_Entity_Submitted"
    case uwaziEntityFailedSubmission = "Uwazi_Entity_Submission_Failed"
    case uwaziEntitySummaryDetailToolbarItem = "Uwazi_Entity_SummaryDetail_ToolbarItem"
    case uwaziEntitySummaryDetailServerTitle = "Uwazi_Entity_SummaryDetail_ServerTitle"
    case uwaziEntitySummaryDetailTemplateTitle = "Uwazi_Entity_SummaryDetail_TemplateTitle"
    case uwaziEntitySummaryDetailEntityResponseTitle = "Uwazi_Entity_SummaryDetail_EntityResponse_Title"
    case uwaziEntitySummaryDetailSubmitAction = "Uwazi_Entity_SummaryDetail_Submit_Action"
    case uwaziEntitySelectFiles = "Uwazi_Entity_SelectFiles"
    case uwaziEntitySelectFilesDropdownTitle = "Uwazi_Entity_SelectFiles_Dropdown_Title"
    case uwaziEntitySelectFilesDropdownTitleSingle = "Uwazi_Entity_SelectFiles_Dropdown_TitleSingle"
    case uwaziEntitySelectFilesDropdownHide = "Uwazi_Entity_SelectFiles_Dropdown_Hide"
    case uwaziEntitySelectFilesDropdownShow = "Uwazi_Entity_SelectFiles_Dropdown_Show"
    case uwaziEntitySelectDateTitle = "Uwazi_Entity_SelectDate_Title"
    
    
    case draftListExpl = "Uwazi_Draft_DraftList_Expl"
    case emptyDraftListExpl = "Uwazi_Draft_EmptyDraftList_Expl"

    case draftEntitySaved = "Uwazi_Draft_EntitySaved_Toast"

    
    case deleteSheetTitle = "Uwazi_Delete_SheetTitle"
    case deleteDraftSheetExpl = "Uwazi_Draft_Delete_SheetExpl"
    case noSheetAction = "Uwazi_Draft_Delete_NO_SheetAction"
    case yesSheetAction = "Uwazi_Draft_Delete_YES_SheetAction"

    case editDraft = "Uwazi_Draft_Edit_SheetSelect"
    case deleteDraft = "Uwazi_Draft_Delete_SheetSelect"

    case outboxListExpl = "Uwazi_Outbox_OutboxList_Expl"
    case emptyOutboxListExpl = "Uwazi_Outbox_EmptyOutboxList_Expl"
    case outboxDeleteSheetExpl = "Uwazi_Outbox_Delete_SheetExpl"

    
    case submittedListExpl = "Uwazi_Submitted_SubmittedList_Expl"
    case emptySubmittedListExpl = "Uwazi_Submitted_EmptySubmittedList_Expl"
    case submitted_AppBar = "Uwazi_Submitted_AppBar"

    
    case uploadedOn = "Uwazi_Submitted_UploadedOn"
    case submittedFiles = "Uwazi_Submitted_Files"
    case submittedFile = "Uwazi_Submitted_File"

    
    
    case submittedDeleteSheetTitle = "Uwazi_Submitted_Delete_SheetTitle"
    case submittedDeleteSheetExpl = "Uwazi_Submitted_Delete_SheetExpl"
    case submittedDeleteCancelAction = "Uwazi_Submitted_Delete_Cancel_SheetAction"
    case submittedDeleteDeleteAction = "Uwazi_Submitted_Delete_Delete_SheetAction"


    case viewSheetSelect = "Uwazi_View_SheetSelect"
    case deleteSheetSelect = "Uwazi_Delete_SheetSelect"

    case uwaziEntityRelationshipExpl = "Uwazi_Entity_Relationship_Expl"
    case uwaziEntityRelationshipSelectTitle = "Uwazi_Entity_Relationship_Select_title"
    case uwaziEntityRelationshipAddMoreTitle = "Uwazi_Entity_Relationship_AddMore_title"
    case uwaziEntityRelationshipSingleConnection = "Uwazi_Entity_Relationship_SingleConnection"
    case uwaziEntityRelationshipMultipleConnections = "Uwazi_Entity_Relationship_MultipleConnections"
    case uwaziRelationshipListExpl = "Search for or select the entities you want to connect to this property."
    case uwaziRelationshipSearchTitle = "Uwazi_Relationship_SearchBar_Title"
}

