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
    @Published var apiID : String?
    @Published var folderId: String?
    
    init() {
        
    }
    init(report: Report, files: [ReportVaultFile]) where T == TellaServer {
        self.id = report.id
        self.title = report.title ?? ""
        self.description = report.description ?? ""
        self.files = files
        self.reportFiles = report.reportFiles ?? []
        self.server = report.server
        self.status = report.status
        self.apiID = report.apiID
        self.folderId = nil
    }
    
    init(report: GDriveReport, files: [ReportVaultFile]) where T == GDriveServer {
        self.id = report.id
        self.title = report.title ?? ""
        self.description = report.description ?? ""
        self.files = files
        self.reportFiles = report.reportFiles ?? []
        self.server = report.server
        self.status = report.status
        self.apiID = nil
        self.folderId = report.folderId
    }
}

