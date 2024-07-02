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
}
