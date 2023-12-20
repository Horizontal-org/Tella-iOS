//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class TellaData : ObservableObject {

    private var database : TellaDataBase
    
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
        let id = database.addServer(server: server)
        getServers()
        return id
        
    }
    
    func addUwaziServer(server: UwaziServer) -> Int? {
        let id = database.addUwaziServer(server: server)
        getServers()
        return id
    }
    
    @discardableResult
    func updateServer(server : Server) -> Int? {
        let id = database.updateServer(server: server)
        getServers()
        return id
    }
    
    func updateUwaziServer(server: UwaziServer) -> Int? {
        let id = database.updateUwaziServer(server: server)
        getServers()
        return id
    }
    
    func deleteServer(serverId : Int) {
        database.deleteServer(serverId: serverId)
        getServers()
        getReports()
    }
    
    func deleteUwaziServer(serverId: Int) {
        database.deleteUwaziServer(serverId: serverId)
        getServers()
    }
    
    @discardableResult
    func deleteAllServers() -> Int? {
        do {
            let id = try database.deleteAllServers()
            getServers()
            getReports()
            return id
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getServers(){
        servers.value = database.getServers()
    }
    
    func getUwaziServer(serverId: Int) -> UwaziServer? {
        do {
            return try database.getUwaziServer(serverId: serverId)
            
        }catch {
            debugLog(error)
            return nil
        }
    }
    
    func getAutoUploadServer() -> Server? {
        return database.getAutoUploadServer()
    }
    
    func getReports() {
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
        return database.getReport(reportId: reportId)
    }
    
    func getCurrentReport() -> Report? {
        return database.getCurrentReport()
    }
    
    func getUnsentReports() -> [Report] {
        return database.getReports(reportStatus: [ .submissionError,
                                                   .submissionPending,
                                                   .submissionInProgress])
    }
    
    func addReport(report : Report) -> Int? {
        let id = database.addReport(report: report)
        getReports()
        return id
    }
    
    func addCurrentUploadReport(report : Report) throws -> Report? {
        try database.resetCurrentUploadReport()
        guard let id = database.addReport(report: report) else { return nil }
        let report = getReport(reportId: id)
        return report
    }
    
    @discardableResult
    func updateReport(report : Report) -> Report? {
        let report = database.updateReport(report: report)
        getReports()
        return report
    }
    
    @discardableResult
    func updateReportStatus(idReport : Int, status: ReportStatus) -> Int? {
        let id = database.updateReportStatus(idReport: idReport, status: status, date: Date())
        getReports()
        return id
        
    }
    
    func addReportFile(fileId: String?, reportId : Int) -> ReportFile? {
        guard let id = database.addReportFile(fileId: fileId , reportId: reportId) else { return nil}
        return database.getVaultFile(reportFileId: id)
    }
    
    func updateReportFile(reportFile: ReportFile) {
        database.updateReportFile(reportFile: reportFile)
    }
    
    func deleteReport(reportId : Int?)  {
        database.deleteReport(reportId: reportId)
        getReports()
    }
    
    func deleteSubmittedReport() {
        database.deleteSubmittedReport()
        getReports()
    }
}

// MARK: - Extension for Uwazi Template methods
extension TellaData {
    func addUwaziTemplate(template: CollectedTemplate) -> CollectedTemplate? {
        return database.addUwaziTemplate(template: template)
    }

    func deleteAllUwaziTemplate(templateId: String) {
        return database.deleteUwaziTemplate(templateId: templateId)
    }
    func getAllUwaziTemplate() -> [CollectedTemplate] {
        do {
            return try database.getAllUwaziTemplate()
        } catch let error {
            debugLog(error)
            return []
        }

    }
    func getUwaziTemplateById(id: Int) -> CollectedTemplate? {
        do {
            return try database.getUwaziTemplate(templateId: id)
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    func deleteAllUwaziTemplate(id: Int) {
        database.deleteUwaziTemplate(id: id)
    }
}
