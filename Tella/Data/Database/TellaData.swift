//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class TellaData : ObservableObject {
    
    var database : TellaDataBase
    var vaultManager : VaultManagerInterface?
    
    var shouldReloadServers = CurrentValueSubject<Bool, Never>(false)
    
    var shouldReloadTellaReports = CurrentValueSubject<Bool, Never>(false)
    var shouldReloadGDriveReports = CurrentValueSubject<Bool, Never>(false)
    var shouldReloadNextcloudReports = CurrentValueSubject<Bool, Never>(false)
    var shouldReloadDropboxReports = CurrentValueSubject<Bool, Never>(false)
    
    var shouldReloadUwaziInstances = CurrentValueSubject<Bool, Never>(false)
    var shouldReloadUwaziTemplates = CurrentValueSubject<Bool, Never>(false)
    
    init(database : TellaDataBase, vaultManager: VaultManagerInterface? = nil) throws {
        self.database = database
        self.vaultManager = vaultManager
    }
    
    func addServer(server : TellaServer) -> Result<Int, Error> {
        let addServerResult = database.addServer(server: server)
        reloadServers()
        
        return addServerResult
    }
    
    func addUwaziServer(server: UwaziServer) -> Int? {
        let id = database.addUwaziServer(server: server)
        reloadServers()
        return id
    }
    
    func addGDriveServer(server: GDriveServer) -> Result<Int, Error>{
        let id = database.addGDriveServer(gDriveServer: server)
        reloadServers()
        
        return id
    }
    
    func addNextcloudServer(server : NextcloudServer) -> Result<Int,Error> {
        let addServerResult = database.addNextcloudServer(server: server)
        reloadServers()
        
        return addServerResult
    }
    
    func addDropboxServer(server: DropboxServer) -> Result<Int, Error> {
        let id = database.addDropboxServer(dropboxServer: server)
        reloadServers()
        
        return id
    }
    
    @discardableResult
    func updateServer(server : TellaServer) -> Result<Bool, Error> {
        let updateServerResult = database.updateServer(server: server)
        reloadServers()
        return updateServerResult
    }
    
    func updateUwaziServer(server: UwaziServer) -> Int? {
        let id = database.updateUwaziServer(server: server)
        reloadServers()
        return id
    }
    
    @discardableResult
    func updateNextcloudServer(server: NextcloudServer) -> Int? {
        let id = database.updateNextcloudServer(server: server)
        reloadServers()
        return id
    }
    
    @discardableResult
    func deleteTellaServer(serverId : Int) -> Result<Bool, Error> {
        let deleteServerResult = database.deleteServer(serverId: serverId)
        reloadServers()
        shouldReloadTellaReports.send(true)
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
        case .gDrive:
            deleteGDriveServer(serverId: serverId)
        case .nextcloud:
            deleteNextcloudServer(serverId: serverId)
        case .dropbox:
            deleteDropboxServer(serverId: serverId)
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
        reloadServers()
        shouldReloadTellaReports.send(true)
        return deleteAllServersResult
    }
    
    func deleteUwaziServer(serverId: Int) {
        database.deleteUwaziServer(serverId: serverId)
        reloadServers()
    }
    
    func deleteGDriveServer(serverId: Int) {
        database.deleteGDriveServer(serverId: serverId)
        reloadServers()
    }
    
    @discardableResult
    func deleteNextcloudServer(serverId: Int) -> Result<Void,Error> {
        // signOut
        let resultDelete = database.deleteNextcloudServer(serverId: serverId)
        reloadServers()
        return resultDelete
    }
    
    func deleteDropboxServer(serverId: Int) {
        database.deleteDroboxServer(serverId: serverId)
        reloadServers()
    }
    
    func reloadServers() {
        self.shouldReloadServers.send(true)
    }
    
    func getServers() -> [Server] {
        
        let tellaServers = self.getTellaServers()
        let uwaziServers = self.getUwaziServers()
        let gDriveServers = self.getDriveServers()
        let nextcloudServers = self.getNextcloudServer()
        let dropboxServers = self.getDropboxServers()
        
        return tellaServers + uwaziServers + gDriveServers + nextcloudServers + dropboxServers
    }
    
    func getTellaServers() -> [TellaServer] {
        self.database.getTellaServers()
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
    
    func getDraftReports() -> [Report] {
        return database.getReports(reportStatus: [.draft])
    }
    func getOutboxedReports() -> [Report] {
        return database.getReports(reportStatus: [.finalized,
                                                  .submissionError,
                                                  .submissionPending,
                                                  .submissionPaused,
                                                  .submissionInProgress,
                                                  .submissionAutoPaused,
                                                  .submissionScheduled])
    }
    
    func getSubmittedReports() -> [Report] {
        return database.getReports(reportStatus: [ReportStatus.submitted])
    }
    
    func getReport(reportId: Int?) -> Report? {
        guard let reportId else { return nil }
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
        shouldReloadTellaReports.send(true)
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
        shouldReloadTellaReports.send(true)
        return report
    }
    
    @discardableResult
    func updateReportStatus(idReport : Int, status: ReportStatus) -> Result<Void, Error>  {
        database.updateReportStatus(idReport: idReport, status: status, date: Date())
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
    
    func deleteReport(reportId : Int?) -> Result<Void,Error> {
        let deleteReportResult = database.deleteReport(reportId: reportId)
        shouldReloadTellaReports.send(true)
        return deleteReportResult
    }
    
    @discardableResult
    func deleteSubmittedReports() -> Result<Void,Error> {
        let deleteSubmittedReportResult = database.deleteSubmittedReports()
        shouldReloadTellaReports.send(true)
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
    
    func addUwaziTemplate(template: CollectedTemplate) -> Result<CollectedTemplate, Error> {
        
        let result = database.addUwaziTemplate(template: template)
        
        switch result {
        case .success(let collectedTemplate):
            self.shouldReloadUwaziTemplates.send(true)
            return .success(collectedTemplate)
        case .failure(let error):
            return .failure(error)
        }
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
    
    func getUwaziServers() -> [UwaziServer] {
        self.database.getUwaziServers()
    }
    
    @discardableResult
    func addUwaziEntityInstance(entityInstance:UwaziEntityInstance) -> Result<Int,Error>  {
        
        if let instanceId = entityInstance.id {
            let result = database.updateUwaziEntityInstance(entityInstance: entityInstance)
            
            if case .success = result {
                self.shouldReloadUwaziInstances.send(true)
                return .success(instanceId)
            } else {
                return .failure(RuntimeError(""))
            }
            
        } else {
            let result =  database.addUwaziEntityInstance(entityInstance: entityInstance)
            self.shouldReloadUwaziInstances.send(true)
            return result
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
        
        let result = database.deleteEntityInstance(entityId: entityId)
        self.shouldReloadUwaziInstances.send(true)
        return result
        
    }
    
    func getUwaziEntityInstance(entityId:Int?) -> UwaziEntityInstance? {
        guard let entityId else { return nil }
        return database.getUwaziEntityInstance(entityId: entityId)
    }
}
