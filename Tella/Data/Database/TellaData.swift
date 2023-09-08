//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class TellaData : ObservableObject {

    // TODO: Make this private to ensure abstraction
    var database : TellaDataBase?
    
    // Servers
    var servers = CurrentValueSubject<[Server], Error>([])
    
    // Reports
    var draftReports = CurrentValueSubject<[Report], Error>([])
    var submittedReports = CurrentValueSubject<[Report], Error>([])
    var outboxedReports = CurrentValueSubject<[Report], Error>([])
    
    init(key: String?) {
        self.database = TellaDataBase(key: key)
        getServers()
        getReports()
    }
    
    func addServer(server : Server) -> Int? {
        guard let database = database else {
            return nil
        }
        let id = database.addServer(server: server)
        getServers()
        return id
        
    }
    
    @discardableResult
    func updateServer(server : Server) -> Int? {
        
        guard let database = database else {
            return nil
        }
        let id = database.updateServer(server: server)
        getServers()
        return id
    }
    
    func deleteServer(serverId : Int) throws {
        
        guard let database = database else {
            return
        }
        try database.deleteServer(serverId: serverId)
        getServers()
        getReports()
    }
    
    func deleteAllServers() throws -> Int {
        
        guard let database = database else {
            throw SqliteError()
        }
        let id = try database.deleteAllServers()
        getServers()
        getReports()
        return id
        
    }
    
    func getServers(){
        guard let database = database else {
            return
        }
        
        servers.value = database.getServer()
    }
    
    func getAutoUploadServer() -> Server? {
        guard let database = database else {
            return nil
        }
        
        return database.getAutoUploadServer()
    }
    
    func getReports() {
        guard let database = database else {
            return
        }
        self.draftReports.value = database.getReports(reportStatus: [ReportStatus.draft])
        self.outboxedReports.value = database.getReports(reportStatus: [.finalized,
                                                                        .submissionError,
                                                                        .submissionPending,
                                                                        .submissionPaused,
                                                                        .submissionInProgress,
                                                                        .submissionAutoPaused])
        
        self.submittedReports.value = database.getReports(reportStatus: [ReportStatus.submitted])
    }
    
    func getReport(reportId: Int) -> Report? {
        guard let database = database else {
            return nil
        }
        return database.getReport(reportId: reportId)
    }
    
    func getCurrentReport() -> Report? {
        guard let database = database else {
            return nil
        }
        return database.getCurrentReport()
    }
    
    func getUnsentReports() -> [Report] {
        guard let database = database else {
            return []
        }
        
        return database.getReports(reportStatus: [ .submissionError,
                                                   .submissionPending,
                                                   .submissionInProgress])
    }
    
    func addReport(report : Report) -> Int? {
        
        guard let database = database else {
            return nil
        }
        let id = database.addReport(report: report)
        getReports()
        return id
    }
    
    func addCurrentUploadReport(report : Report) throws -> Report? {
        
        guard let database = database else {
            return nil
        }
        
        try database.resetCurrentUploadReport()
        guard let id = database.addReport(report: report) else { return nil }
        let report = getReport(reportId: id)
        return report
    }
    
    @discardableResult
    func updateReport(report : Report) -> Report? {
        
        guard let database = database else {
            return nil
        }
        let report = database.updateReport(report: report)
        getReports()
        return report
    }
    
    @discardableResult
    func updateReportStatus(idReport : Int, status: ReportStatus) -> Int? {
        
        guard let database = database else {
            return nil
        }
        let id = database.updateReportStatus(idReport: idReport, status: status, date: Date())
        getReports()
        return id
        
    }
    
    func addReportFile(fileId: String?, reportId : Int) -> ReportFile? {
        guard let database = database else {
            return nil
        }
        guard let id = database.addReportFile(fileId: fileId , reportId: reportId) else { return nil}
        return database.getVaultFile(reportFileId: id)
    }
    
    func updateReportFile(reportFile: ReportFile) {
        database?.updateReportFile(reportFile: reportFile)
    }
    
    func deleteReport(reportId : Int?)  {
        database?.deleteReport(reportId: reportId)
        getReports()
    }
    
    func deleteSubmittedReport() {
        database?.deleteSubmittedReport()
        getReports()
    }
}
