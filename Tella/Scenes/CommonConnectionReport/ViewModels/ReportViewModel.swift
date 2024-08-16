//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class ReportViewModel<T: Server> {
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files : [ReportVaultFile] = []
    @Published var reportFiles : [ReportFile] = []
    @Published var server : T?
    @Published var status : ReportStatus?
    @Published var remoteReportStatus : RemoteReportStatus?
    @Published var apiID : String?
    @Published var folderId: String?
    var descriptionFileUrl: URL?

    init() {
        
    }
    
    init(id: Int?, title: String, description: String, files: [ReportVaultFile], reportFiles : [ReportFile], server: T?, status: ReportStatus?,remoteReportStatus:RemoteReportStatus? = nil, apiID: String?, folderId: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.files = files
        self.reportFiles = reportFiles
        self.server = server
        self.status = status
        self.remoteReportStatus = remoteReportStatus
        self.apiID = apiID
        self.folderId = folderId
    }
}

