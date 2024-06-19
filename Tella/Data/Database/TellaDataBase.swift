//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation
import SQLCipher

class TellaDataBase : DataBase {
    
    var dataBaseHelper : DataBaseHelper
    var statementBuilder : SQLiteStatementBuilder
    
    init(key: String?) throws {
        dataBaseHelper =  try DataBaseHelper(key: key, databaseName:D.databaseName)
        statementBuilder = SQLiteStatementBuilder(dbPointer: dataBaseHelper.dbPointer)
        checkVersions()
    }
    
    func checkVersions() {
        do {
            let oldVersion = try statementBuilder.getCurrentDatabaseVersion()
            
            switch oldVersion {
            case 0:
                createTables()
            case 1:
                createFeedbackTable()
                renameUpdatedDateColumn()
                fallthrough
            case 2:
                createTemplateTableForUwazi()
                createUwaziServerTable()
                fallthrough
            case 3:
                createResourceTable()
                fallthrough
            case 4:
                createUwaziEntityInstancesTable()
                createUwaziEntityInstanceVaultFileTable()
                addRelationshipColumnToUwaziTemplate()
            default :
                break
            }
            try statementBuilder.setNewDatabaseVersion(version: D.databaseVersion)
        } catch let error {
            debugLog(error)
        }
    }
    
    func createTables() {
        createServerTable()
        createReportTable()
        createReportFilesTable()
        createFeedbackTable()
        createTemplateTableForUwazi()
        createUwaziServerTable()
        createResourceTable()
        createUwaziEntityInstancesTable()
        createUwaziEntityInstanceVaultFileTable()
        addRelationshipColumnToUwaziTemplate()
    }
    
    func createReportTable() {
        // c_id | c_title | c_description | c_date | cStatus | c_server_id
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cApiReportId, D.text),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cStatus, D.integer),
            cddl(D.cCurrentUpload, D.integer),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)
        ]
        statementBuilder.createTable(tableName: D.tReport, columns: columns)
    }
    
    func createReportFilesTable() {
        
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cBytesSent, D.integer),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cReportInstanceId, D.integer, tableName: D.tReport, referenceKey: D.cReportId)
            
        ]
        statementBuilder.createTable(tableName: D.tReportInstanceVaultFile, columns: columns)
        
    }

    func checkFilesInConnections(ids: [String]) -> Bool {
        do {
            for vaultId in ids {
                let condition = [KeyValue(key: D.cVaultFileInstanceId, value: vaultId)]
                let responseReportDict = try statementBuilder.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                                    andCondition: condition)
                if !responseReportDict.isEmpty {
                    return true
                }
                let responseUwaziDict = try statementBuilder.selectQuery(tableName: D.tUwaziEntityInstanceVaultFile,
                                                                    andCondition: condition)
                if !responseUwaziDict.isEmpty {
                    return true
                }
            }
        } catch let error {
            debugLog(error)
        }
        return false
    }

    /// Rename the cUpatedDate column to cUpdatedDate column in tReport and tReportInstanceVaultFile tables
    /// It was a typo
    func renameUpdatedDateColumn() {
        do {
            try statementBuilder.addColumnOn(tableName: D.tReport, columnName: D.cUpdatedDate, type: D.float)
            try statementBuilder.updateColumnOn(tableName: D.tReport, oldColumn: D.cUpatedDate, newColumn: D.cUpdatedDate)
            try statementBuilder.dropColumnOn(tableName: D.tReport, columnName: D.cUpatedDate)
            
            try statementBuilder.addColumnOn(tableName: D.tReportInstanceVaultFile, columnName: D.cUpdatedDate, type: D.float)
            try statementBuilder.updateColumnOn(tableName: D.tReportInstanceVaultFile, oldColumn: D.cUpatedDate, newColumn: D.cUpdatedDate)
            try statementBuilder.dropColumnOn(tableName: D.tReportInstanceVaultFile, columnName: D.cUpatedDate)

        } catch let error {
            debugLog(error)
        }
    }
    
    func getReports(reportStatus:[ReportStatus]) -> [Report] {
        
        var reports : [Report] = []
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            
            //            let statusArray = reportStatus.compactMap{KeyValue(key: D.cStatus, value: $0.rawValue) }
            let statusArray = reportStatus.compactMap{ $0.rawValue }
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                inCondition: [KeyValues(key:D.cStatus, value: statusArray )],
                                                                joinCondition: joinCondition)
            
            responseDict.forEach { dict in
                reports.append(getReport(dictionnary: dict))
            }
            
            return reports
            
        } catch let error {
            debugLog(error)
            return []
        }
    }
    
    func getReport(reportId:Int) -> Report? {
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            let reportCondition = [KeyValue(key: D.cReportId, value: reportId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: reportCondition,
                                                                joinCondition: joinCondition)
            if !responseDict.isEmpty, let dict = responseDict.first  {
                return  getReport(dictionnary: dict)
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func getCurrentReport() -> Report? {
        
        do {
            
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            let reportCondition = [KeyValue(key: D.cCurrentUpload, value: 1)]
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: reportCondition,
                                                                joinCondition: joinCondition)
            
            if !responseDict.isEmpty, let dict = responseDict.first  {
                
                let reportID = dict[D.cReportId] as? Int
                
                let files = getVaultFiles(reportID: reportID)
                
                let filteredFile = files.filter{(Date().timeIntervalSince($0.updatedDate ?? Date())) < 1800 }
                
                if !filteredFile.isEmpty {
                    return getReport(dictionnary: dict)
                }
                
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func getVaultFile(reportFileId:Int) -> ReportFile? {
        do {
            
            let reportFileCondition = [KeyValue(key: D.cId, value: reportFileId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                                andCondition: reportFileCondition)
            
            if !responseDict.isEmpty, let dict = responseDict.first {
                let id = dict[D.cId] as? Int
                let vaultFileId = dict[D.cVaultFileInstanceId] as? String
                let status = dict[D.cStatus] as? Int
                let bytesSent = dict[D.cBytesSent] as? Int
                let createdDate = dict[D.cCreatedDate] as? Double
                let updatedDate = dict[D.cUpdatedDate] as? Double
                
                return  ReportFile(id: id,
                                   fileId: vaultFileId,
                                   status: FileStatus(rawValue: status ?? 0),
                                   bytesSent: bytesSent,
                                   createdDate: createdDate?.getDate(),
                                   updatedDate: updatedDate?.getDate())
                
            }
            return nil
            
        } catch {
            return nil
        }
        
    }
    
    func getVaultFiles(reportID:Int?) -> [ReportFile] {
        
        var reportFiles : [ReportFile] = []
        
        do {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: reportID)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                                andCondition: reportFilesCondition)
            
            responseDict.forEach { dict in
                let id = dict[D.cId] as? Int
                let vaultFileId = dict[D.cVaultFileInstanceId] as? String
                let status = dict[D.cStatus] as? Int
                let bytesSent = dict[D.cBytesSent] as? Int
                let createdDate = dict[D.cCreatedDate] as? Double
                let updatedDate = dict[D.cUpdatedDate] as? Double
                
                let reportFile =  ReportFile(id: id,
                                             fileId: vaultFileId,
                                             status: FileStatus(rawValue: status ?? 0),
                                             bytesSent: bytesSent,
                                             createdDate: createdDate?.getDate(),
                                             updatedDate: updatedDate?.getDate())
                reportFiles.append(reportFile)
            }
            return reportFiles
            
        } catch let error {
            debugLog(error)
            return []
        }
    }
    
    func addReport(report : Report) -> Result<Int, Error> {
        
        do {
            
            let currentUpload = ((report.currentUpload == false) || (report.currentUpload == nil)) ? 0 : 1
            
            let reportValuesToAdd = [KeyValue(key: D.cTitle, value: report.title),
                                     KeyValue(key: D.cDescription, value: report.description),
                                     KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                     KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                                     KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                     KeyValue(key: D.cServerId, value: report.server?.id),
                                     KeyValue(key: D.cCurrentUpload, value:currentUpload )]
            
            let reportId = try statementBuilder.insertInto(tableName: D.tReport,
                                                           keyValue:reportValuesToAdd)
            
            try report.reportFiles?.forEach({ reportFile in
                
                let reportFileValuesToAdd = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                             KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                             KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                             KeyValue(key: D.cBytesSent, value: 0),
                                             KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                             KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
                
                try statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                                keyValue: reportFileValuesToAdd)
                
                
            })
            return .success(reportId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateReport(report : Report) -> Result<Report?,Error> {
        do {
            var keyValueArray : [KeyValue]  = []
            
            if let title = report.title {
                keyValueArray.append(KeyValue(key: D.cTitle, value: title))
            }
            
            if let description = report.description {
                keyValueArray.append(KeyValue(key: D.cDescription, value: description))
            }
            
            keyValueArray.append(KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()))
            
            if let status = report.status {
                keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
            }
            
            if let serverId = report.server?.id {
                keyValueArray.append(KeyValue(key: D.cServerId, value: serverId))
            }
            
            if let apiID = report.apiID {
                keyValueArray.append(KeyValue(key: D.cApiReportId, value: apiID))
            }
            
            
            if let currentUpload = report.currentUpload {
                keyValueArray.append(KeyValue(key: D.cCurrentUpload, value: currentUpload == false ? 0 : 1))
            }
            
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
            try statementBuilder.update(tableName: D.tReport,
                                        valuesToUpdate: keyValueArray,
                                        equalCondition: reportCondition)
            
            if let files = report.reportFiles {
                let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: report.id as Any)]
                
                try statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                            primarykeyValue:reportFilesCondition )
                
                try files.forEach({ reportFile in
                    let reportFileValuesToAdd = [
                        
                        reportFile.id == nil ? nil : KeyValue(key: D.cId, value: reportFile.id),
                        KeyValue(key: D.cReportInstanceId, value: report.id),
                        KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                        KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                        KeyValue(key: D.cBytesSent, value: reportFile.bytesSent),
                        KeyValue(key: D.cCreatedDate, value: reportFile.createdDate),
                        KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
                    
                    try statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                                    keyValue: reportFileValuesToAdd)
                })
            }
            
            guard let reportId = report.id else {
                return .failure(RuntimeError("No report ID"))
            }
            
            let report = getReport(reportId: reportId)
            return .success(report)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateReportStatus(idReport : Int, status: ReportStatus, date: Date) -> Result<Bool, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tReport,
                                        valuesToUpdate: valuesToUpdate,
                                        equalCondition: reportCondition)
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    @discardableResult
    func resetCurrentUploadReport() -> Result<Bool,Error> {
        do {
            let reportCondition = [KeyValue(key: D.cCurrentUpload, value: 1)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: reportCondition )
            
            if !responseDict.isEmpty, let dict = responseDict.first  {
                
                let reportID = dict[D.cReportId] as? Int
                let valuesToUpdate = [KeyValue(key: D.cCurrentUpload, value: 0),
                                      KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
                let reportCondition = [KeyValue(key: D.cReportId, value: reportID)]
                
                try statementBuilder.update(tableName: D.tReport,
                                            valuesToUpdate: valuesToUpdate,
                                            equalCondition:reportCondition)
            }
            
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
        
    }
    
    @discardableResult
    func updateReportFile(reportFile:ReportFile) -> Result<Bool,Error> {
        do {
            var keyValueArray : [KeyValue]  = []
            
            if let status = reportFile.status {
                keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
            }

            if let status = reportFile.status {
                keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
            }
            
            if let bytesSent = reportFile.bytesSent {
                keyValueArray.append(KeyValue(key: D.cBytesSent, value: bytesSent))
            }
            
            keyValueArray.append(KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()))
            
            let primarykey = [KeyValue(key: D.cId, value: reportFile.id)]
            try statementBuilder.update(tableName: D.tReportInstanceVaultFile,
                                        valuesToUpdate: keyValueArray,
                                        equalCondition: primarykey)
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateReportIdFile(oldId:String?,newID:String?) -> Result<Bool,Error> {
        do {
            // Get the vault file instance array where cVaultFileInstanceId equal to the old vault file ID
            var vaultFileInstanceIDs : [Int] = []

            let condition = [KeyValue(key: D.cVaultFileInstanceId, value: oldId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                                andCondition: condition)

            responseDict.forEach { dict in
                if let id = dict[D.cId] as? Int {
                    vaultFileInstanceIDs.append(id)
                }
            }

            // Update the cVaultFileInstanceId value with the new vault file ID
            let valuesToUpdate = [KeyValue(key: D.cVaultFileInstanceId, value: newID)]
            
            if !vaultFileInstanceIDs.isEmpty {
                let inCondition = [KeyValues(key: D.cId, value: vaultFileInstanceIDs)]
                try statementBuilder.update(tableName: D.tReportInstanceVaultFile,
                                            valuesToUpdate: valuesToUpdate,
                                            inCondition: inCondition)
            }
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }

    func addReportFile(fileId:String?, reportId:Int) -> Result<Int,Error> {
        
        do {
            let reportFileValues = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                    KeyValue(key: D.cVaultFileInstanceId, value: fileId),
                                    KeyValue(key: D.cStatus, value: FileStatus.notSubmitted.rawValue),
                                    KeyValue(key: D.cBytesSent, value: 0),
                                    KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                    KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
            
            let reportFileId = try statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                                               keyValue: reportFileValues)
            return .success(reportFileId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func deleteReport(reportId : Int?) -> Result<Bool,Error> {
        
        do {
            
            guard let reportId, let report = self.getReport(reportId: reportId)else {
                return .failure(RuntimeError("No report is selected"))
            }
            
            try deleteReportFiles(reportIds: [reportId])
            
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id as Any)]
            
            try statementBuilder.delete(tableName: D.tReport,
                                        primarykeyValue: reportCondition)
            
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func deleteSubmittedReport() -> Result<Bool,Error> {
        do {
            let submittedReports = self.getReports(reportStatus: [.submitted])
            let reportIds = submittedReports.compactMap{$0.id}
            
            try deleteReportFiles(reportIds: reportIds)
            
            let reportCondition = [KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
            
            try statementBuilder.delete(tableName: D.tReport,
                                        primarykeyValue: reportCondition)
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    private func deleteReportFiles(reportIds:[Int]) throws {
        let reportCondition = [KeyValues(key: D.cReportInstanceId, value: reportIds)]
        try statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                    inCondition: reportCondition)
        
    }
    
    private func getReport(dictionnary : [String:Any] ) -> Report {
        
        let reportID = dictionnary[D.cReportId] as? Int
        let title = dictionnary[D.cTitle] as? String
        let description = dictionnary[D.cDescription] as? String
        let createdDate = dictionnary[D.cCreatedDate] as? Double
        let updatedDate = dictionnary[D.cUpdatedDate] as? Double
        let status = dictionnary[D.cStatus] as? Int
        let apiReportId = dictionnary[D.cApiReportId] as? String
        let currentUpload = dictionnary[D.cCurrentUpload] as? Int
        
        return Report(id: reportID,
                      title: title ?? "",
                      description: description ?? "",
                      createdDate: createdDate?.getDate() ?? Date(),
                      updatedDate: updatedDate?.getDate() ?? Date(),
                      status: ReportStatus(rawValue: status ?? 0) ?? .draft,
                      server: getTellaServer(dictionnary: dictionnary),
                      vaultFiles: getVaultFiles(reportID: reportID),
                      apiID: apiReportId,
                      currentUpload: currentUpload == 0 ? false : true)
    }
    
}

extension TellaDataBase {
    
    func createFeedbackTable() {
        
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.ctext, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
        ]
        statementBuilder.createTable(tableName: D.tFeedback, columns: columns)
        
    }
    
    func getDraftFeedback() -> Feedback? {
        do {
            let feedbackCondition = [KeyValue(key: D.cStatus, value: FeedbackStatus.draft.rawValue)]
            
            let feedbackDict = try statementBuilder.getSelectQuery(tableName: D.tFeedback,
                                                                   equalCondition: feedbackCondition)
            return try feedbackDict.first?.decode(Feedback.self)
        } catch (let error) {
            debugLog(error)
            return nil
        }
    }
    
    func getUnsentFeedbacks() -> [Feedback] {
        do {
            let feedbackCondition = [KeyValue(key: D.cStatus, value: FeedbackStatus.pending.rawValue)]
            
            let feedbackDict = try statementBuilder.getSelectQuery(tableName: D.tFeedback,
                                                                   equalCondition: feedbackCondition)
            return try feedbackDict.decode(Feedback.self)
        } catch (let error) {
            debugLog(error)
            return []
        }
    }
    
    func addFeedback(feedback : Feedback) -> Result<Int?, Error> {
        do {
            let valuesToAdd = [KeyValue(key: D.ctext, value: feedback.text),
                               KeyValue(key: D.cStatus, value: feedback.status?.rawValue),
                               KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                               KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
            
            let idResult = try statementBuilder.insertInto(tableName: D.tFeedback,
                                                           keyValue: valuesToAdd)
            return .success(idResult)
            
        } catch(let error) {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateFeedback(feedback : Feedback) -> Result<Bool, Error> {
        
        do {
            
            let valuesToUpdate = [ KeyValue(key: D.ctext, value: feedback.text),
                                   KeyValue(key: D.cStatus, value: feedback.status?.rawValue),
                                   KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
            
            let feedbackCondition = [KeyValue(key: D.cId, value: feedback.id)]
            try statementBuilder.update(tableName: D.tFeedback,
                                        valuesToUpdate: valuesToUpdate,
                                        equalCondition: feedbackCondition)
            return .success(true)
            
        } catch(let error) {
            debugLog(error)
            return .failure(error)
        }
    }

    func deleteFeedback(feedbackId: Int) -> Result<Bool,Error> {
        
        do {
            let feedbackCondition = [KeyValue(key: D.cId, value: feedbackId as Any)]
            
            try statementBuilder.delete(tableName: D.tFeedback,
                                        primarykeyValue:feedbackCondition)
            return .success(true)
        } catch (let error) {
            debugLog(error)
            return .failure(error)
        }
    }
}
