//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class BaseReport : Hashable {
    
    var id : Int?
    var title : String?
    var description : String?
    var createdDate : Date?
    var updatedDate : Date?
    var status : ReportStatus?
    var reportFiles : [ReportFile]?
    var currentUpload: Bool?

    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus? = nil,
         vaultFiles: [ReportFile]? = nil,
         currentUpload: Bool? = nil ) {
        self.id = id
        self.title = title
        self.description = description
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.status = status
        self.reportFiles = vaultFiles
        self.currentUpload = currentUpload

    }
    
    static func == (lhs: BaseReport, rhs: BaseReport) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension BaseReport {
    var getReportDate: String {
        guard let status = self.status  else {
            return ""
        }
//        to do
        switch status {
        case .draft:
            return self.createdDate?.getDraftReportTime() ?? ""
        case .submissionPaused:
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


// Report

class Report: BaseReport {
    var server: TellaServer?
    var apiID: String?

    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus? = nil,
         server: TellaServer? = nil,
         vaultFiles: [ReportFile]? = nil,
         apiID: String? = nil,
         currentUpload: Bool? = nil) {
        self.server = server
        self.apiID = apiID
        super.init(id: id, title: title, description: description, createdDate: createdDate, updatedDate: updatedDate, status: status, vaultFiles: vaultFiles, currentUpload: currentUpload)
    }
}

// GDriveReport
class GDriveReport: BaseReport {
    var server: GDriveServer?

    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case title = "c_title"
        case description = "c_description"
        case createdDate = "c_created_date"
        case updatedDate = "c_updated_date"
        case status = "c_status"
        case server = "c_server_id"
    }

    // Keep the existing initializer
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         createdDate: Date? = nil,
         updatedDate: Date? = nil,
         status: ReportStatus? = nil,
         server: GDriveServer? = nil,
         vaultFiles: [ReportFile]? = nil,
         currentUpload: Bool? = nil) {
        self.server = server
        super.init(id: id, title: title, description: description, createdDate: createdDate, updatedDate: updatedDate, status: status, vaultFiles: vaultFiles, currentUpload: currentUpload)
    }
}

