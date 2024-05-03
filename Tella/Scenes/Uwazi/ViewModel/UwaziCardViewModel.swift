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

class UwaziCardViewModel: Hashable {

    var id : String
    
    var templateId : Int?
    var entityInstanceID : Int?
    
    var title: String
    var deleteAction: (() -> Void)
    var serverName: String
    var serverId: Int?
    var deleteTitle: String
    var deleteMessage: String
    var listActionSheetItem: [ListActionSheetItem]
    var type : CardType
    
    var imageName: String? = nil
    
    
    init(template : CollectedTemplate,
         deleteTemplate: @escaping (() -> Void)) {
        self.id = UUID().uuidString
        
        self.templateId = template.id
        self.title = template.entityRow?.translatedName ?? ""
        self.deleteAction = deleteTemplate
        self.serverId = template.serverId
        self.serverName = template.serverName ?? ""
        let titleText = String.init(format: LocalizableUwazi.deleteDraftSheetTitle.localized, "\"\(self.title)\"")
        
        self.deleteTitle = titleText
        self.deleteMessage = LocalizableUwazi.uwaziDeleteTemplateExpl.localized
        listActionSheetItem = downloadTemplateActionItems
        
        type = .template
    }
    
    init(instance : UwaziEntityInstance,
         deleteTemplate: @escaping (() -> Void)) {
        
        self.id = UUID().uuidString
        
        self.entityInstanceID = instance.id
        self.templateId = instance.templateId
        self.title = instance.title ?? ""
        self.deleteAction = deleteTemplate
        self.serverName = instance.server?.name ?? ""
        
        let titleText = String.init(format: LocalizableUwazi.deleteDraftSheetTitle.localized, "\"\(self.title)\"")
        
        self.deleteTitle = titleText
        self.deleteMessage = LocalizableUwazi.deleteDraftSheetExpl.localized
        
        switch instance.status {
        case .draft:
            listActionSheetItem = uwaziDraftActionItems
        case .submitted:
            listActionSheetItem = uwaziOutboxActionItems
        default:
            listActionSheetItem = uwaziOutboxActionItems
        }
        
        switch instance.status {
        case .submitted:
            imageName = "submitted"
        case .finalized:
            imageName = "time.yellow"
        case .submissionError, .submissionPending:
            imageName = "info-icon"
        case .submissionInProgress:
            imageName = "progress-circle.green"
        default:
            break
        }
        
        type = .entityInstance
    }

    static func == (lhs: UwaziCardViewModel, rhs: UwaziCardViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
