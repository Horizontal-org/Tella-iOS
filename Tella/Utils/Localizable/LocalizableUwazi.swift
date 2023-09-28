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
}
