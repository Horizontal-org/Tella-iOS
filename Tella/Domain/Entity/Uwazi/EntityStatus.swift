//
//  EntityStatus.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

enum EntityStatus:Int, Codable {
    
    case unknown = 0
    case draft = 1
    case finalized = 2
    case submitted = 3
    case submissionError = 4
    case submissionPending = 7 // no connection on sending, or offline mode - form saved
    case submissionInProgress = 10
    
    func isFinal() -> Bool {
        return !(self == .unknown || self == .draft)
    }
}


extension EntityStatus {
    
    
    func deleteReportStrings(title:String) -> DeleteReportStrings {
        switch self {
        case .draft:
            
            return DeleteReportStrings(deleteTitle: String.init(format: LocalizableUwazi.deleteSheetTitle.localized, "\(title)"),
                                       deleteMessage: LocalizableUwazi.deleteDraftSheetExpl.localized)
            
        case .submitted:
            return DeleteReportStrings(deleteTitle: LocalizableUwazi.submittedDeleteSheetTitle.localized,
                                       deleteMessage :LocalizableUwazi.submittedDeleteSheetExpl.localized)
        default:
            return DeleteReportStrings(deleteTitle : LocalizableUwazi.submittedDeleteSheetTitle.localized,
                                       deleteMessage : LocalizableUwazi.outboxDeleteSheetExpl.localized)
        }
        
    }
    
    
    var listActionSheetItem: [ListActionSheetItem] {
        
        switch self {
        case .draft:
            return [
                ListActionSheetItem(imageName: "edit-icon",
                                    content: LocalizableUwazi.editDraft.localized,
                                    type: UwaziActionType.createEntity),
                ListActionSheetItem(imageName: "delete-icon-white",
                                    content: LocalizableUwazi.deleteDraft.localized,
                                    type: UwaziActionType.delete)
            ]
        case .submitted:
            return [
                ListActionSheetItem(imageName: "edit-icon",
                                    content: LocalizableUwazi.viewSheetSelect.localized,
                                    type: UwaziActionType.viewSubmittedEntity),
                ListActionSheetItem(imageName: "delete-icon-white",
                                    content: LocalizableUwazi.deleteSheetSelect.localized,
                                    type: UwaziActionType.delete)
            ]
        default:
            return [
                ListActionSheetItem(imageName: "view-icon",
                                    content: LocalizableUwazi.viewSheetSelect.localized,
                                    type: UwaziActionType.viewOutboxEntity),
                ListActionSheetItem(imageName: "delete-icon-white",
                                    content: LocalizableUwazi.deleteSheetSelect.localized,
                                    type: UwaziActionType.delete)
            ]
        }
        
        
    }
    
    
    var iconImageName: String? {
        switch self {
        case .submitted:
            return"submitted"
        case .finalized:
            return "time.yellow"
        case .submissionError, .submissionPending:
            return "info-icon"
        case .submissionInProgress:
            return "progress-circle.green"
        default:
            return nil
        }

    }
    
    
}
