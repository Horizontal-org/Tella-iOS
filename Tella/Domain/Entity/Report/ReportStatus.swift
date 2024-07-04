//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum  ReportStatus : Int, Codable {
    case unknown = 0
    case draft = 1
    case finalized = 2
    case submitted = 3
    case submissionError = 4
    case deleted = 5
    case submissionPending = 6 // no connection on sending, or offline mode - form saved
    case submissionPaused = 7  // Submission paused
    case submissionInProgress = 8  // Submission launched
    case submissionAutoPaused = 9  // Submission paused for auto report
    case submissionScheduled = 10  // Submission scheduled
}

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
    
    var reportActionType : ReportActionType {
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
                                        type: ReportActionType.viewSubmitted),
                    ListActionSheetItem(imageName: "delete-icon-white",
                                        content: LocalizableReport.viewModelDelete.localized,
                                        type: UwaziActionType.delete)]
        case .draft:
            
            return [ListActionSheetItem(imageName: "edit-icon",
                                        content: LocalizableReport.viewModelEdit.localized,
                                        type: ReportActionType.editDraft),
                    ListActionSheetItem(imageName: "delete-icon-white",
                                        content: LocalizableReport.viewModelDelete.localized,
                                        type: UwaziActionType.delete) ]
        default:
            return [ListActionSheetItem(imageName: "view-icon",
                                        content: LocalizableReport.viewModelView.localized,
                                        type: ReportActionType.editOutbox),
                    ListActionSheetItem(imageName: "delete-icon-white",
                                        content: LocalizableReport.viewModelDelete.localized,
                                        type: UwaziActionType.delete)]
        }
    }
    
    var deleteReportStrings: DeleteReportStrings {
        switch self {
        case .draft:
            DeleteReportStrings(deleteTitle: LocalizableReport.deleteDraftTitle.localized,
                                deleteMessage: LocalizableReport.deleteDraftReportMessage.localized)
        case .submitted:
            
            DeleteReportStrings(deleteTitle: LocalizableReport.deleteTitle.localized,
                                deleteMessage: LocalizableReport.deleteSubmittedReportMessage.localized)
        default:
            DeleteReportStrings(deleteTitle: LocalizableReport.deleteTitle.localized,
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


struct DeleteReportStrings {
    var deleteTitle : String
    var deleteMessage : String
    
    
}
