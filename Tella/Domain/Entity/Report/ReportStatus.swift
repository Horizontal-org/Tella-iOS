//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum  ReportStatus : Int {
    case unknown = 0
    case draft = 1
    case finalized = 2
    case submitted = 3
    case submissionError = 4
    case deleted = 5
    case submissionPending = 6 // no connection on sending, or offline mode - form saved
    case submissionPartialParts = 7  // some req body parts (files) are not sent
    case submissionInProgress = 8  // Submission launched
}

extension ReportStatus {
    
    var sheetItemTitle : String {
        switch self {
        
        case .submitted:
            return "View"

        case .draft:
            return "Edit"

        default:
            return "Open"
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
