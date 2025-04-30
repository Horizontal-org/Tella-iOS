//
//  NextcloudDatabase.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension TellaDataBase {
    
    func createNextcloudServerTable() {
        let columns = [ cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
                        cddl(D.cName, D.text),
                        cddl(D.cURL, D.text),
                        cddl(D.cUsername, D.text),
                        cddl(D.cPassword, D.text),
                        cddl(D.cUserId, D.text),
                        cddl(D.cRootFolderName, D.text)]
        
        statementBuilder.createTable(tableName: D.tNextcloudServer, columns: columns)
    }
    
    func addNextcloudServer(server: NextcloudServer) -> Result<Int,Error> {
        do {
            let nextcloudServerDictionnary = server.dictionary
            let valuesToAdd = nextcloudServerDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let serverId = try statementBuilder.insertInto(tableName: D.tNextcloudServer, keyValue: valuesToAdd)
            return .success(serverId) 
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateNextcloudServer(server: NextcloudServer) -> Int? {
        do {
            
            let nextcloudServerDictionnary = server.dictionary
            let valuesToUpdate = nextcloudServerDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let serverCondition = [KeyValue(key: D.cServerId, value: server.id)]
            return try statementBuilder.update(tableName: D.tNextcloudServer,
                                               valuesToUpdate: valuesToUpdate,
                                               equalCondition: serverCondition)
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getNextcloudServer() -> [NextcloudServer] {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tNextcloudServer)
            let server = try serversDict.decode(NextcloudServer.self)
            return server
        } catch {
            debugLog("Error while fetching servers from \(D.tNextcloudServer): \(error)")
            return []
        }
    }
    
    func deleteNextcloudServer(serverId: Int) -> Result<Void,Error> {
        do {
            try statementBuilder.delete(tableName: D.tNextcloudServer,
                                        primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
            try statementBuilder.deleteAll(tableNames: [D.tNextcloudReport, D.tNextcloudInstanceVaultFile])
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
}

// Nextcloud Reports
extension TellaDataBase {
    
    func createNextcloudReportTable() {
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cStatus, D.integer),
            cddl(D.cRemoteReportStatus, D.integer),
            cddl(D.cServerId, D.integer, tableName: D.tNextcloudServer, referenceKey: D.cId)
        ]
        statementBuilder.createTable(tableName: D.tNextcloudReport, columns: columns)
    }
    
    func createNextcloudReportFilesTable() {
        
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cBytesSent, D.integer),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cChunkFiles, D.text),
            cddl(D.cReportInstanceId, D.integer, tableName: D.tNextcloudReport, referenceKey: D.cId)
        ]
        statementBuilder.createTable(tableName: D.tNextcloudInstanceVaultFile, columns: columns)
    }
    
    func addNextcloudReport(report: NextcloudReport) -> Int? {
        do {
            
            let reportDictionary = report.dictionary
            let valuesToAdd = reportDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportId = try statementBuilder.insertInto(tableName: D.tNextcloudReport, keyValue: valuesToAdd)
            
            try report.reportFiles?.forEach( { reportFile in
                reportFile.reportInstanceId = reportId
                let reportFilesDictionnary = reportFile.dictionary
                let fileValuesToAdd = reportFilesDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
                try statementBuilder.insertInto(tableName: D.tNextcloudInstanceVaultFile, keyValue: fileValuesToAdd)
            })
            
            return reportId
            
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getNextcloudReports(reportStatus: [ReportStatus]) -> [NextcloudReport] {
        do {
            
            let statusArray = reportStatus.compactMap{ $0.rawValue }
            
            let nextcloudReportDict = try statementBuilder.getSelectQuery(tableName: D.tNextcloudReport,
                                                                          inCondition: [KeyValues(key:D.cStatus, value: statusArray )]
            )
            
            let decodedReports = try nextcloudReportDict.compactMap ({ dict in
                return try dict.decode(NextcloudReport.self)
            })
            
            return decodedReports
            
        } catch let error {
            debugLog(error)
            return []
        }
    }
    
    func getNextcloudReport(id: Int) -> NextcloudReport? {
        do{
            let reportsCondition = [KeyValue(key: D.cReportId, value: id)]
            let nextcloudDict = try statementBuilder.getSelectQuery(tableName: D.tNextcloudReport,
                                                                    equalCondition: reportsCondition
            )
            
            let decodedReport = try nextcloudDict.first?.decode(NextcloudReport.self)
            let reportFiles = getNextcloudVaultFiles(reportId: decodedReport?.id)
            decodedReport?.reportFiles = reportFiles
            
            let server = getNextcloudServer().first
            decodedReport?.server = server
            
            return decodedReport
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getNextcloudVaultFiles(reportId: Int?) -> [NextcloudReportFile] {
        do {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: reportId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tNextcloudInstanceVaultFile, andCondition: reportFilesCondition)
            
            let decodedFiles = try responseDict.compactMap ({ dict in
                return try dict.decode(NextcloudReportFile.self)
            })
            
            return decodedFiles
        } catch let error {
            debugLog(error)
            
            return []
        }
    }
    
    func updateNextcloudReport(report: NextcloudReport) -> Result<Void,Error> {
        do {
            
            let reportDictionary = report.dictionary
            let valuesToUpdate = reportDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
            
            try statementBuilder.update(
                tableName: D.tNextcloudReport,
                valuesToUpdate: valuesToUpdate,
                equalCondition: reportCondition
            )
            
            if let files = report.reportFiles {
                
                try deleteNextcloudReportFiles(reportIds: [report.id])
                
                try files.forEach( { reportFile in
                    
                    let reportFilesDictionnary = reportFile.dictionary
                    let reportFilesValuesToAdd = reportFilesDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
                    
                    try statementBuilder.insertInto(tableName: D.tNextcloudInstanceVaultFile, keyValue: reportFilesValuesToAdd)
                })
            }
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func deleteNextcloudReport(reportId: Int?) -> Result<Void,Error> {
        do {
            let reportCondition = [KeyValue(key: D.cReportId, value: reportId)]
            try statementBuilder.delete(tableName: D.tNextcloudReport, primarykeyValue: reportCondition)
            
            try deleteNextcloudReportFiles(reportIds: [reportId])
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateNextcloudReportFile(reportFile: ReportFile) -> Result<Void,Error> {
        do {
            
            let reportDictionary = reportFile.dictionary
            let valuesToUpdate = reportDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportCondition = [KeyValue(key: D.cId, value: reportFile.id)]
            
            try statementBuilder.update(tableName: D.tNextcloudInstanceVaultFile,
                                        valuesToUpdate: valuesToUpdate,
                                        equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateNextcloudReportWithoutFiles(report: NextcloudReport) -> Result<Void,Error> {
        do {
            
            let reportDictionary = report.dictionary
            let valuesToUpdate = reportDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
            
            try statementBuilder.update(tableName: D.tNextcloudReport,
                                        valuesToUpdate: valuesToUpdate,
                                        equalCondition: reportCondition)
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func deleteNextcloudSubmittedReports() -> Result<Void,Error> {
        do {
            let submittedReports = self.getNextcloudReports(reportStatus: [.submitted])
            let reportIds = submittedReports.compactMap{$0.id}
            try deleteNextcloudReportFiles(reportIds: reportIds)
            
            let reportCondition = [KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
            try statementBuilder.delete(tableName: D.tNextcloudReport,
                                        primarykeyValue: reportCondition)
            return .success
            
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    private func deleteNextcloudReportFiles(reportIds:[Int?]) throws {
        let reportIds = reportIds.compactMap{$0}
        let reportFilesCondition = [KeyValues(key: D.cReportInstanceId, value: reportIds)]
        try statementBuilder.delete(tableName: D.tNextcloudInstanceVaultFile,
                                    inCondition: reportFilesCondition)
    }
}
