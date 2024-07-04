//
//  TemplateCardViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 9/23/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


enum CardType {
    case template
    case entityInstance
}

class UwaziCardViewModel: CommonCardViewModel {
    
    var templateId : Int?
    var entityInstanceID : Int?
    var serverId: Int?
    var status : EntityStatus = EntityStatus.unknown
    var type : CardType = .entityInstance
    
    init(template : CollectedTemplate,
         deleteTemplate: @escaping (() -> Void)) {
        
        let title = template.entityRow?.translatedName ?? ""
        let deleteTitle = String.init(format: LocalizableUwazi.deleteSheetTitle.localized, "\(title)")
        let deleteMessage = LocalizableUwazi.uwaziDeleteTemplateExpl.localized
        let deleteReportStrings = DeleteReportStrings(deleteTitle: deleteTitle,
                                                      deleteMessage: deleteMessage)
        super.init(id: Int(UUID().uuidString) ?? 0,
                   title: title,
                   iconImageName: nil,
                   serverName: template.serverName ?? "",
                   listActionSheetItem: downloadTemplateActionItems,
                   connectionType: .uwazi, 
                   deleteReportStrings: deleteReportStrings,
                   deleteAction: deleteTemplate)
        
        self.templateId = template.id
        self.serverId = template.serverId
        type = .template
    }
    
    init(instance : UwaziEntityInstance,
         deleteTemplate: @escaping (() -> Void)) {
        
        let title = instance.title ?? ""
        let serverName = instance.server?.name ?? ""
        let iconImageName : String? = instance.status.iconImageName
        let listActionSheetItem = instance.status.listActionSheetItem
        let deleteReportStrings = instance.status.deleteReportStrings(title: title)
        
        super.init(id: Int(UUID().uuidString) ?? 0,
                   title: title,
                   iconImageName: iconImageName,
                   serverName: serverName,
                   listActionSheetItem: listActionSheetItem,
                   connectionType: .uwazi,
                   deleteReportStrings: deleteReportStrings,
                   deleteAction:deleteTemplate)
        
        self.entityInstanceID = instance.id
        self.templateId = instance.templateId
        self.status = instance.status
        type = .entityInstance
    }
    
    
}
