//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Report: BaseReport {
    
    var server: TellaServer?
    var apiID: String?
    var currentUpload: Bool?
    
    enum CodingKeys: String, CodingKey {
        case apiID = "c_api_report_id"
        case currentUpload = "c_current_upload"
    }
    
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
        self.currentUpload = currentUpload
        
        super.init(id: id, title: title,
                   description: description,
                   createdDate: createdDate,
                   updatedDate: updatedDate,
                   status: status ?? .unknown,
                   vaultFiles: vaultFiles,
                   serverId: self.server?.id)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiID = try container.decode(String?.self, forKey: .apiID)
        self.currentUpload = try container.decode(Bool?.self, forKey: .currentUpload)
        try super.init(from: decoder)
    }
}
