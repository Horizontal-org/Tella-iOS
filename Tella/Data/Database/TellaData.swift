//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class TellaData : ObservableObject {
    
    var database : TellaDataBase
    var vaultManager : VaultManagerInterface?

    // Servers
    var servers = CurrentValueSubject<[Server], Error>([])
    var tellaServers = CurrentValueSubject<[TellaServer], Error>([])
    var uwaziServers = CurrentValueSubject<[UwaziServer], Error>([])
    
    // Reports
    var draftReports = CurrentValueSubject<[Report], Error>([])
    var submittedReports = CurrentValueSubject<[Report], Error>([])
    var outboxedReports = CurrentValueSubject<[Report], Error>([])
    
    var shouldReloadUwaziInstances = CurrentValueSubject<Bool, Never>(false)
    var shouldReloadUwaziTemplates = CurrentValueSubject<Bool, Never>(false)

    init(database : TellaDataBase, vaultManager: VaultManagerInterface? = nil) throws {
        self.database = database
        self.vaultManager = vaultManager
        
        getServers()
        getReports()
    }
    
    func addServer(server : TellaServer) -> Result<Int, Error> {
        let addServerResult = database.addServer(server: server)
        getServers()
        
        return addServerResult
    }
    
    func addUwaziServer(server: UwaziServer) -> Int? {
        let id = database.addUwaziServer(server: server)
        getServers()
        return id
    }
    
    @discardableResult
    func updateServer(server : TellaServer) -> Result<Bool, Error> {
        let updateServerResult = database.updateServer(server: server)
        getServers()
        return updateServerResult
    }
    
    func updateUwaziServer(server: UwaziServer) -> Int? {
        let id = database.updateUwaziServer(server: server)
        getServers()
        return id
    }
    
    @discardableResult
    func deleteTellaServer(serverId : Int) -> Result<Bool, Error> {
        let deleteServerResult = database.deleteServer(serverId: serverId)
        getServers()
        getReports()
        return deleteServerResult
    }
    
    func deleteServer(server: Server) {
        guard let serverId = server.id else { return }
        
        switch (server.serverType) {
        case .tella:
            let resourcesId = getResourceByServerId(serverId: serverId)
            
            vaultManager?.deleteVaultFile(filesIds: resourcesId)
            deleteTellaServer(serverId: serverId)
        case .uwazi:
            deleteUwaziServer(serverId: serverId)
        default:
            break
        }
    }
    
    @discardableResult
    func deleteAllServers() -> Result<Bool, Error>{
        let resources = getResources()
        let resourcesId = resources.map { res in
            return res.id
        }
        
        vaultManager?.deleteVaultFile(filesIds: resourcesId)
        let deleteAllServersResult = database.deleteAllServers()
        getServers()
        getReports()
        return deleteAllServersResult
    }
    
    func deleteUwaziServer(serverId: Int) {
        database.deleteUwaziServer(serverId: serverId)
        getServers()
    }
    
    func getServers(){
        DispatchQueue.main.async {
            self.tellaServers.value = self.database.getTellaServers()
            self.uwaziServers.value = self.database.getUwaziServers()
            
            self.servers.value = self.tellaServers.value + self.uwaziServers.value
        }
    }
    
    func getTellaServer(serverId: Int?) -> TellaServer? {
        do {
            guard let serverId else { return nil }
            return try database.getTellaServerById(id: serverId)
        } catch {
            debugLog(error)
            return nil
        }
    }
    
    func getUwaziServer(serverId: Int?) -> UwaziServer? {
        do {
            guard let serverId else { return nil }
            return try database.getUwaziServer(serverId: serverId)
            
        }catch {
            debugLog(error)
            return nil
        }
    }
    
    func getAutoUploadServer() -> TellaServer? {
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
                                                                                 .submissionAutoPaused,
                                                                                 .submissionScheduled])
            
            self.submittedReports.value = self.database.getReports(reportStatus: [ReportStatus.submitted])
        }
    }
    
    func getReport(reportId: Int) -> Report? {
        return database.getReport(reportId: reportId)
    }
    
    func getResources() -> [DownloadedResource] {
        return database.getDownloadedResources()
    }
    
    func addResource(resource: Resource, serverId: Int, data: Data) throws -> Bool {
        guard let tempFile = self.vaultManager?.saveDataToTempFile(data: data, fileName: resource.title, pathExtension: "pdf") else { return  false}
        let result = database.addDownloadedResource(resource: resource, serverId: serverId)
        
        switch result {
        case .success(let resourceId):
            guard (self.vaultManager?.save(tempFile, vaultFileId: resourceId)) != nil else {
                return false
            }
            
            return true
        case .failure(let error):
            throw error
        }
    }
    func deleteDownloadedResource(resourceId: String) -> Result<Bool,Error> {
        self.vaultManager?.deleteVaultFile(filesIds: [resourceId])
        let result = database.deleteDownloadedResource(resourceId: resourceId)
        
        switch result {
        case.success(let result):
            return .success(result)
        case.failure(let error):
            return .failure(error)
        }
    }
    func getResourceByServerId(serverId: Int) -> [String] {
        let resourcesResult = database.getResourcesByServerId(serverId: serverId)
        
        switch resourcesResult {
        case .success(let ids):
            return ids
        default:
            return []
        }
        
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
    
    
    func updateReportIdFile(files:[VaultFileDetailsToMerge]) throws {
        
        try files.forEach { fileDetails in
            let addVaultFileResult = database.updateReportIdFile(oldId: fileDetails.oldId, newID: fileDetails.vaultFileDB.id)
            
            if case .failure = addVaultFileResult {
                throw RuntimeError("Error updating Report Id File")
            }
        }
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
    func deleteFeedback(feedbackId: Int) -> Result<Bool,Error> {
        database.deleteFeedback(feedbackId: feedbackId)
    }
}

// MARK: - Extension for Uwazi Template methods
extension TellaData {
    
    func addUwaziTemplate(template: CollectedTemplate) -> CollectedTemplate? {
       
        let collectedTemplate = database.addUwaziTemplate(template: template)
        
        guard let collectedTemplate else { return nil }

        self.shouldReloadUwaziTemplates.send(true)
        
        return collectedTemplate
    }

    func updateUwaziTemplate(template: CollectedTemplate) -> Int? {
        let id = database.updateUwaziTemplate(template: template)
        
        return id
    }
    func deleteAllUwaziTemplate(templateId: String) {
        
        self.shouldReloadUwaziTemplates.send(true)

        
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
    func getUwaziTemplateById(id: Int?) -> CollectedTemplate? {
        do {
            guard let id else { return nil }
            return try database.getUwaziTemplate(templateId: id)
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    func deleteUwaziTemplate(id: Int) -> Result<Bool,Error> {
        database.deleteUwaziTemplate(id: id)
    }
}

extension TellaData {
    @discardableResult
    func addUwaziEntityInstance(entityInstance:UwaziEntityInstance) -> Bool  {
        
        let result : Result<Int, Error>
        if let _ = entityInstance.id {
            result = database.updateUwaziEntityInstance(entityInstance: entityInstance)
        } else {
            result = database.addUwaziEntityInstance(entityInstance: entityInstance)
        }

        if case .success = result {
            self.shouldReloadUwaziInstances.send(true)
            return true
        } else {
            return false
        }
    }
    
    func getDraftUwaziEntityInstances() -> [UwaziEntityInstance] {
        return database.getUwaziEntityInstance(entityStatus: [.draft])
    }
    
    func getOutboxUwaziEntityInstances() -> [UwaziEntityInstance] {
        return database.getUwaziEntityInstance(entityStatus: [.finalized,
                                                              .submissionError,
                                                              .submissionPending])
    }
    
    func getSubmittedUwaziEntityInstances() -> [UwaziEntityInstance] {
        return database.getUwaziEntityInstance(entityStatus: [.submitted])
    }
    
    func deleteUwaziEntityInstance(entityId:Int) -> Result<Bool,Error> {
        database.deleteEntityInstance(entityId: entityId)
    }
    
}
