//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class TellaData : ObservableObject {
    
    var database : TellaDataBase
    
    // Servers
    var servers = CurrentValueSubject<[Server], Error>([])
    
    // Reports
    var draftReports = CurrentValueSubject<[Report], Error>([])
    var submittedReports = CurrentValueSubject<[Report], Error>([])
    var outboxedReports = CurrentValueSubject<[Report], Error>([])
    
    init(key: String?) throws {
        self.database = try TellaDataBase(key: key)
        getServers()
        getReports()
    }
    
    func addServer(server : Server) -> Result<Int, Error> {
        let addServerResult = database.addServer(server: server)
        getServers()
        
        return addServerResult
    }
    
    @discardableResult
    func updateServer(server : Server) -> Result<Bool, Error> {
        let updateServerResult = database.updateServer(server: server)
        getServers()
        return updateServerResult
    }
    
    @discardableResult
    func deleteServer(serverId : Int) -> Result<Bool, Error> {
        let deleteServerResult = database.deleteServer(serverId: serverId)
        getServers()
        getReports()
        return deleteServerResult
    }
    
    @discardableResult
    func deleteAllServers() -> Result<Bool, Error>{
        let deleteAllServersResult = database.deleteAllServers()
        getServers()
        getReports()
        return deleteAllServersResult
    }
    
    func getServers(){
        DispatchQueue.main.async {
            self.servers.value = self.database.getServer()
        }
    }
    
    func getAutoUploadServer() -> Server? {
        return database.getAutoUploadServer()
    }
    
    func getReports() {
        DispatchQueue.main.async {
            
            self.draftReports.value = self.database.getReports(reportStatus: [ReportStatus.draft])
            self.outboxedReports.value = self.database.getReports(reportStatus: [.finalized,
                                                                            .submissionError,
                                                                            .submissionPending,
                                                                            .submissionPaused,
                                                                            .submissionInProgress,
                                                                            .submissionAutoPaused])
            
            self.submittedReports.value = self.database.getReports(reportStatus: [ReportStatus.submitted])
        }
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
    
    func addReport(report : Report) -> Result<Int, Error> {
        let id =  database.addReport(report: report)
        getReports()
        return id
    }
    
    func addCurrentUploadReport(report : Report) -> Report?   {
        database.resetCurrentUploadReport()
        let addReportResult = database.addReport(report: report)

        switch addReportResult {
        case .success(let id):
            return getReport(reportId: id)
        default:
            return nil
        }
    }
    
    @discardableResult
    func updateReport(report : Report) -> Result<Report?, Error>  {
        let report = database.updateReport(report: report)
        getReports()
        return report
    }
    
    @discardableResult
    func updateReportStatus(idReport : Int, status: ReportStatus) -> Result<Bool, Error>  {
        let id = database.updateReportStatus(idReport: idReport, status: status, date: Date())
        getReports()
        return id
        
    }
    
    func addReportFile(fileId: String?, reportId : Int)  -> ReportFile? {
        let addReportFileResult =  database.addReportFile(fileId: fileId , reportId: reportId)
        
        switch addReportFileResult {
        case .success(let id):
            return database.getVaultFile(reportFileId: id)
        default:
            return nil
        }
        
    }
    
    @discardableResult
    func updateReportFile(reportFile: ReportFile) -> Result<Bool, Error>{
          database.updateReportFile(reportFile: reportFile)
    }
    
    func deleteReport(reportId : Int?) -> Result<Bool, Error> {
        let deleteReportResult = database.deleteReport(reportId: reportId)
        getReports()
        return deleteReportResult
    }
    
    @discardableResult
    func deleteSubmittedReport() -> Result<Bool, Error> {
        let deleteSubmittedReportResult = database.deleteSubmittedReport()
        getReports()
        return deleteSubmittedReportResult

    }
    
    func addFeedback(feedback : Feedback) -> Result<Int?, Error> {
        database.addFeedback(feedback: feedback)
    }
    
    func getDraftFeedback() -> Feedback? {
        database.getDraftFeedback()
    }
    
    func getUnsentFeedbacks() -> [Feedback] {
        database.getUnsentFeedbacks()
    }

    func updateFeedback(feedback: Feedback) -> Result<Bool, Error> {
        database.updateFeedback(feedback: feedback)
    }
    
    @discardableResult
    func deleteFeedback(feedbackId: Int?) -> Result<Bool,Error> {
        database.deleteFeedback(feedbackId: feedbackId)
    }
}


