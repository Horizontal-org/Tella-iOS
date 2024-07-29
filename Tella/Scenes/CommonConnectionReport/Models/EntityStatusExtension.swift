//
//  EntityStatusExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension EntityStatus {
    
    func deleteReportStrings(title:String) -> ConfirmDeleteConnectionStrings {
        switch self {
        case .draft:
            return ConfirmDeleteConnectionStrings(deleteTitle: String.init(format: LocalizableUwazi.deleteSheetTitle.localized, "\(title)"),
                                       deleteMessage: LocalizableUwazi.deleteDraftSheetExpl.localized)
            
        case .submitted:
            return ConfirmDeleteConnectionStrings(deleteTitle: LocalizableUwazi.submittedDeleteSheetTitle.localized,
                                       deleteMessage :LocalizableUwazi.submittedDeleteSheetExpl.localized)
        default:
            return ConfirmDeleteConnectionStrings(deleteTitle : LocalizableUwazi.submittedDeleteSheetTitle.localized,
                                       deleteMessage : LocalizableUwazi.outboxDeleteSheetExpl.localized)
        }
        
    }

    var listActionSheetItem: [ListActionSheetItem] {
        
        switch self {
        case .draft:
            return [
                ListActionSheetItem(imageName: "edit-icon",
                                    content: LocalizableUwazi.editDraft.localized,
                                    type: ConnectionActionType.editDraft),
                ListActionSheetItem(imageName: "delete-icon-white",
                                    content: LocalizableUwazi.deleteDraft.localized,
                                    type: ConnectionActionType.delete)
            ]
        case .submitted:
            return [
                ListActionSheetItem(imageName: "edit-icon",
                                    content: LocalizableUwazi.viewSheetSelect.localized,
                                    type: ConnectionActionType.viewSubmitted),
                ListActionSheetItem(imageName: "delete-icon-white",
                                    content: LocalizableUwazi.deleteSheetSelect.localized,
                                    type: ConnectionActionType.delete)
            ]
        default:
            return [
                ListActionSheetItem(imageName: "view-icon",
                                    content: LocalizableUwazi.viewSheetSelect.localized,
                                    type: ConnectionActionType.editOutbox),
                ListActionSheetItem(imageName: "delete-icon-white",
                                    content: LocalizableUwazi.deleteSheetSelect.localized,
                                    type: ConnectionActionType.delete)
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
