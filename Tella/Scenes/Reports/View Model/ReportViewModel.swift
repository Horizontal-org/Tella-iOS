//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

class ReportViewModel {
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files : [ReportVaultFile] = []
    @Published var server : Server?
    @Published var status : ReportStatus?
    @Published var apiID : String?
    
    init() {
        
    }
    
    init(id: Int?, title: String, description: String, files: [ReportVaultFile], server: Server?, status: ReportStatus?, apiID: String?) {
        self.id = id
        self.title = title
        self.description = description
        self.files = files
        self.server = server
        self.status = status
        self.apiID = apiID
    }
}

