//
//  LocalizableUwazi.swift
//  Tella
//
//  Created by Gustavo on 23/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum LocalizableUwazi: String, LocalizableDelegate {
    
    case uwaziTitle = "Uwazi_AppBar"
    
    case uwaziServerEdit = "Uwazi_Server_Edit_SheetAction"
    case uwaziServerDelete = "Uwazi_Server_Delete_SheetAction"
    
    case uwaziPageViewTemplate = "Uwazi_PageViewItem_Template"
    case uwaziTemplateListExpl = "Uwazi_Template_TemplateList_Expl"
    case uwaziTemplateListEmptyExpl = "Uwazi_Template_TemplateList_EmptyExpl"
    
    case uwaziAddTemplateTitle = "Uwazi_Template_AddTemplate_Title"
    case uwaziAddTemplateExpl = "Uwazi_Template_AddTemplate_Expl"
    case uwaziAddTemplateSecondExpl = "Uwazi_Template_AddTemplate_SecondExpl"
    case uwaziAddTemplateSavedToast = "Uwazi_Template_AddTemplateSaved_Toast"
    case uwaziAddTemplateEmptydExpl = "Uwazi_Template_AddTemplate_EmptyExpl"
    case uwaziDeleteTemplateExpl = "Uwazi_DeleteTemplate_SheetExpl"
    
    case uwaziCreateEntitySheetExpl = "Uwazi_Template_CreateEntity_SheetAction"
    case uwaziDeleteEntitySheetExpl = "Uwazi_Template_Delete_SheetAction"
    
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
    case uwaziEntitySummaryDetailToolbarItem = "Uwazi_Entity_SummaryDetail_ToolbarItem"
    case uwaziEntitySummaryDetailServerTitle = "Uwazi_Entity_SummaryDetail_ServerTitle"
    case uwaziEntitySummaryDetailTemplateTitle = "Uwazi_Entity_SummaryDetail_TemplateTitle"
    case uwaziEntitySummaryDetailEntityResponseTitle = "Uwazi_Entity_SummaryDetail_EntityResponse_Title"
    case uwaziEntitySummaryDetailSubmitAction = "Uwazi_Entity_SummaryDetail_Submit_Action"
    case uwaziEntitySelectFiles = "Uwazi_Entity_SelectFiles"
    case uwaziEntitySelectFilesDropdownTitle = "Uwazi_Entity_SelectFiles_Dropdown_Title"
    case uwaziEntitySelectFilesDropdownHide = "Uwazi_Entity_SelectFiles_Dropdown_Hide"
    case uwaziEntitySelectFilesDropdownShow = "Uwazi_Entity_SelectFiles_Dropdown_Show"
}
