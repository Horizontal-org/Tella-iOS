//
//  ReportStatusExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension ReportStatus {
    
    var sheetItemTitle : String {
        switch self {
            
        case .submitted:
            return LocalizableReport.viewModelView.localized
            
        case .draft:
            return LocalizableReport.viewModelEdit.localized
            
        default:
            return LocalizableReport.viewModelOpen.localized
        }
    }
    
    var reportActionType : ConnectionActionType {
        switch self {
            
        case .submitted:
            return .viewSubmitted
            
        case .draft:
            return .editDraft
            
        default:
            return .editOutbox
            
        }
    }
    
    var listActionSheetItem : [ListActionSheetItem] {
        switch self {
            
        case .submitted:
            return [ListActionSheetItem(imageName: "view-icon",
                                        content: LocalizableReport.viewModelView.localized,
                                        type: ConnectionActionType.viewSubmitted),
                    ListActionSheetItem(imageName: "delete-icon-white",
                                        content: LocalizableReport.viewModelDelete.localized,
                                        type: ConnectionActionType.delete)]
        case .draft:
            
            return [ListActionSheetItem(imageName: "edit-icon",
                                        content: LocalizableReport.viewModelEdit.localized,
                                        type: ConnectionActionType.editDraft),
                    ListActionSheetItem(imageName: "delete-icon-white",
                                        content: LocalizableReport.viewModelDelete.localized,
                                        type: ConnectionActionType.delete) ]
        default:
            return [ListActionSheetItem(imageName: "view-icon",
                                        content: LocalizableReport.viewModelView.localized,
                                        type: ConnectionActionType.editOutbox),
                    ListActionSheetItem(imageName: "delete-icon-white",
                                        content: LocalizableReport.viewModelDelete.localized,
                                        type: ConnectionActionType.delete)]
        }
    }
    
    var deleteReportStrings: ConfirmDeleteConnectionStrings {
        switch self {
        case .draft:
            ConfirmDeleteConnectionStrings(deleteTitle: LocalizableReport.deleteDraftTitle.localized,
                                           deleteMessage: LocalizableReport.deleteDraftReportMessage.localized)
        case .submitted:
            ConfirmDeleteConnectionStrings(deleteTitle: LocalizableReport.deleteTitle.localized,
                                           deleteMessage: LocalizableReport.deleteSubmittedReportMessage.localized)
        default:
            ConfirmDeleteConnectionStrings(deleteTitle: LocalizableReport.deleteTitle.localized,
                                           deleteMessage: LocalizableReport.deleteOutboxReportMessage.localized)
        }
    }
    
    var iconImageName: String? {
        
        switch self {
        case .submitted:
            return "submitted"
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
