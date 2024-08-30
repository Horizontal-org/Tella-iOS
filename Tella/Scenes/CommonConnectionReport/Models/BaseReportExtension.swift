//
//  BaseReportExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension BaseReport {
    var getReportDate: String {
        let status = self.status
        switch status {
        case .submissionPaused:
            return LocalizableReport.pausedCardExpl.localized
        case .submitted:
            return self.updatedDate?.getSubmittedReportTime() ?? ""
        default:
            return self.updatedDate?.getModifiedReportTime() ?? ""
        }
    }
}
