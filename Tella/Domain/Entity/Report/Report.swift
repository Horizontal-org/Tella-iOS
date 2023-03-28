//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Report : Hashable {
    
    var id : Int?
    var title : String?
    var description : String?
    var createdDate : Date?
    var updatedDate : Date?
    var status : ReportStatus?
    var server : Server?
    var reportFiles : [ReportFile]?
    var apiID : String?
    var currentUpload: Bool?

    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus? = nil,
         server: Server? = nil,
         vaultFiles: [ReportFile]? = nil,
         apiID: String? = nil,
         currentUpload: Bool? = nil ) {
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.status = status
        self.server = server
        self.reportFiles = vaultFiles
        self.apiID = apiID
        self.currentUpload = currentUpload

    }
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension Report {
    var getReportDate: String {
        guard let status = self.status  else {
            return ""
        }
//        to do
        switch status {
        case .draft:
            return self.createdDate?.getDraftReportTime() ?? ""
        case .submissionPartialParts:
            return "Paused"
            
        case .submissionInProgress:
            return ""

        case .submitted:
            return self.createdDate?.getSubmittedReportTime() ?? ""
        default:
            return ""
            
        }
    }
}

