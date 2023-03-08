//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Report : Hashable {
    
    var id : Int?
    var title : String?
    var description : String?
    var date : Date?
    //    @Published var title : String?
    //    @Published var description : String?
    //    @Published var date : Date?
    
    var status : ReportStatus?
    var server : Server?
    var reportFiles : [ReportFile]?
    var apiID : String?
    
    init(id: Int? = nil,
         title: String? = nil,
         description: String? = nil,
         date: Date? = nil,
         status: ReportStatus? = nil,
         server: Server? = nil,
         vaultFiles: [ReportFile]? = nil,
         apiID: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
        self.server = server
        self.reportFiles = vaultFiles
        self.apiID = apiID
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
            return self.date?.getDraftReportTime() ?? ""
        case .submissionPartialParts:
            return "Paused"
            
        case .submissionInProgress:
            return ""

        case .submitted:
            return self.date?.getSubmittedReportTime() ?? ""
        default:
            return ""
            
        }
    }
}

