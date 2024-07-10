//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class ReportViewModel<T: ServerProtocol> {
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files : [ReportVaultFile] = []
    @Published var reportFiles : [ReportFile] = []
    @Published var server : T?
    @Published var status : ReportStatus?
    @Published var apiID : String?
    
    init() {
        
    }
    
    init(id: Int?, title: String, description: String, files: [ReportVaultFile], reportFiles : [ReportFile], server: T?, status: ReportStatus?, apiID: String?) {
        self.id = id
        self.title = title
        self.description = description
        self.files = files
        self.reportFiles = reportFiles
        self.server = server
        self.status = status
        self.apiID = apiID
    }
}

