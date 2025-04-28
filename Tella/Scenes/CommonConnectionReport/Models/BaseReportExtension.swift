//
//  BaseReportExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/8/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension BaseReport {
    var getReportDate: String {
        let status = self.status
        switch status {
        case .submissionPending, .finalized:
            return LocalizableReport.readyForSubmissionCardExpl.localized
        case .submissionInProgress:
            return LocalizableReport.submittingCardExpl.localized
        case .submissionPaused, .submissionAutoPaused:
            return LocalizableReport.pausedCardExpl.localized
        case .submitted:
            return self.updatedDate?.getSubmittedReportTime() ?? ""
        default:
            return self.updatedDate?.getModifiedReportTime() ?? ""
        }
    }
}
