//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Report : Hashable {
    
    var id : Int?
   @Published var title : String?
    @Published var description : String?
    @Published var date : Date?
    var status : ReportStatus?
    var server : Server?
    
    init(id : Int? = nil,
         title : String?,
         description : String?,
         date : Date?,
         status : ReportStatus?,
         server : Server?) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
        self.server = server
    }
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id.hashValue)
    }
}

extension Report {
    var getReportDate: String {
        guard let status = self.status  else {
            return ""
        }
        
        switch status {
        case .draft:
           return self.date?.getDraftReportTime() ?? ""
        case .outbox:
            return ""
        case .submitted:
            return self.date?.getSubmittedReportTime() ?? ""
        }
    }
    
 
}

enum ReportStatus :Int {
    case draft = 0
    case outbox = 1
    case submitted = 2
}
