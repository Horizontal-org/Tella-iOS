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
    var status : EntityStatus = EntityStatus.unknown

    var deleteTitle: String
    var deleteMessage: String
    var listActionSheetItem: [ListActionSheetItem]
    var type : CardType
    
    var iconImageName: String? = nil
    
    init(template : CollectedTemplate,
         deleteTemplate: @escaping (() -> Void)) {
        self.id = UUID().uuidString
        
        self.templateId = template.id
        self.title = template.entityRow?.translatedName ?? ""
        self.deleteAction = deleteTemplate
        self.serverId = template.serverId
        self.serverName = template.serverName ?? ""
        
        let titleText = String.init(format: LocalizableUwazi.deleteSheetTitle.localized, "\(self.title)")
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
        self.status = instance.status
        
        let titleText = String.init(format: LocalizableUwazi.deleteSheetTitle.localized, "\(self.title)")
        
        switch instance.status {
        case .draft:
            self.deleteTitle = titleText
            self.deleteMessage = LocalizableUwazi.deleteDraftSheetExpl.localized
            listActionSheetItem = uwaziDraftActionItems
        case .submitted:
            self.deleteTitle = LocalizableUwazi.submittedDeleteSheetTitle.localized
            self.deleteMessage = LocalizableUwazi.submittedDeleteSheetExpl.localized
            listActionSheetItem = uwaziSubmittedActionItems
        default:
            self.deleteTitle = LocalizableUwazi.submittedDeleteSheetTitle.localized
            self.deleteMessage = LocalizableUwazi.outboxDeleteSheetExpl.localized
            listActionSheetItem = uwaziOutboxActionItems
        }
        
        switch instance.status {
        case .submitted:
            iconImageName = "submitted"
        case .finalized:
            iconImageName = "time.yellow"
        case .submissionError, .submissionPending:
            iconImageName = "info-icon"
        case .submissionInProgress:
            iconImageName = "progress-circle.green"
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
