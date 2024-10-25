//
//  DropboxDatabase.swift
//  Tella
//
//  Created by gus valbuena on 9/9/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

/// Create Server Tables
extension TellaDataBase {
    
    func createDropboxServerTable() {
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text)
        ]
        
        statementBuilder.createTable(tableName: D.tDropboxServer, columns: columns)
    }
    
    func addDropboxServer(dropboxServer: DropboxServer) -> Result<Int, Error> {
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: dropboxServer.name)]
            
            let serverId = try statementBuilder.insertInto(tableName: D.tDropboxServer, keyValue: valuesToAdd)
            return .success(serverId)
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func getDropboxServers() -> [DropboxServer] {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tDropboxServer, andCondition: [])
            
            let dropboxServer = try serversDict.decode(DropboxServer.self)
            
            return dropboxServer
        } catch let error {
            debugLog("Error while fetching servers from \(D.tDropboxServer): \(error)")
            return []
        }
    }
    
    func deleteDropboxServer(serverId: Int) -> Result<Void,Error> {
        do {
            try statementBuilder.delete(tableName: D.tDropboxServer,
                                        primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
            try statementBuilder.deleteAll(tableNames: [D.tDropboxReport, D.tDropboxInstanceVaultFile])
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
}

/// Create report tables
extension TellaDataBase {
    
    func createDropboxReportTable() {
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cStatus, D.integer),
            cddl(D.cFolderId, D.text),
            cddl(D.cRemoteReportStatus, D.integer),
            cddl(D.cServerId, D.integer, tableName: D.tDropboxServer, referenceKey: D.cId)
        ]
        
        statementBuilder.createTable(tableName: D.tDropboxReport, columns: columns)
    }
    
    func createDropboxReportsFileTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cBytesSent, D.integer),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cSessionId, D.text),
            cddl(D.cReportInstanceId, D.integer, tableName: D.tDropboxReport, referenceKey: D.cReportId)
        ]
        
        statementBuilder.createTable(tableName: D.tDropboxInstanceVaultFile, columns: columns)
    }
    
}

/// Dropbox report methods
extension TellaDataBase {
    
    /// GET
    func getDropboxReports(reportStatus: [ReportStatus]) -> [DropboxReport] {
        do {
            
            let statusArray = reportStatus.compactMap{ $0.rawValue }
            
            let dropboxReportsDict = try statementBuilder.getSelectQuery(tableName: D.tDropboxReport,
                                                                         inCondition: [KeyValues(key:D.cStatus, value: statusArray )])
            
            let decodedReports = try dropboxReportsDict.compactMap ({ dict in
                return try dict.decode(DropboxReport.self)
            })
            
            return decodedReports
            
        } catch let error {
            debugLog(error)
            return []
        }
    }
    
    func getDropboxReport(id: Int) -> DropboxReport? {
        do{
            let reportsCondition = [KeyValue(key: D.cReportId, value: id)]
            let dropboxReportsDict = try statementBuilder.getSelectQuery(tableName: D.tDropboxReport,
                                                                         equalCondition: reportsCondition
            )
            
            guard let dict = dropboxReportsDict.first else {
                return nil
            }
            
            let decodedReports = try dict.decode(DropboxReport.self)
            let reportFiles = getDropboxVaultFiles(reportId: decodedReports.id)
            decodedReports.reportFiles = reportFiles
            
            let server = getDropboxServers().first
            decodedReports.server = server
            
            return decodedReports
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getDropboxVaultFiles(reportId: Int?) -> [DropboxReportFile] {
        do {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: reportId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tDropboxInstanceVaultFile, andCondition: reportFilesCondition)
            let decodedFiles = try responseDict.compactMap ({ dict in
                return try dict.decode(DropboxReportFile.self)
            })
            
            return decodedFiles
        } catch let error {
            debugLog(error)
            
            return []
        }
    }
    
    /// ADD
    func addDropboxReport(report: DropboxReport) -> Result<Int, Error> {
        do {
            let reportDict = report.dictionary
            let valuesToAdd = reportDict.compactMap({ KeyValue(key: $0.key, value: $0.value) })
            let reportId = try statementBuilder.insertInto(tableName: D.tDropboxReport, keyValue: valuesToAdd)
            
            _ = report.reportFiles?.compactMap({ $0.reportInstanceId = reportId })
            
            try report.reportFiles?.forEach({ reportFiles in
                let reportFilesDictionary = reportFiles.dictionary
                let reportFilesValuesToAdd = reportFilesDictionary.compactMap({ KeyValue(key: $0.key, value: $0.value) })
                
                try statementBuilder.insertInto(tableName: D.tDropboxInstanceVaultFile, keyValue: reportFilesValuesToAdd)
            })
            return .success(reportId)
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    /// UPDATE
    func updateDropboxReport(report: DropboxReport) -> Result<Void, Error> {
        do {
            
            let reportDict = report.dictionary
            let valuesToUpdate = reportDict.compactMap({ KeyValue(key: $0.key, value: $0.value) })
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
            
            try statementBuilder.update(
                tableName: D.tDropboxReport,
                valuesToUpdate: valuesToUpdate,
                equalCondition: reportCondition
            )
            
            if let files = report.reportFiles, let reportId = report.id {
                try deleteDropboxInstanceFiles(reportIds: [reportId])
                
                try files.forEach( { reportFiles in
                    let reportFilesDict = reportFiles.dictionary
                    let reportFilesValuesToAdd = reportFilesDict.compactMap({ KeyValue( key: $0.key, value: $0.value) })
                    
                    try statementBuilder.insertInto(tableName: D.tDropboxInstanceVaultFile, keyValue: reportFilesValuesToAdd)
                })
            }
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateDropboxReportFile(reportFile: DropboxReportFile) -> Result<Void, Error> {
        do {
            let reportDictionary = reportFile.dictionary
            let valuesToUpdate = reportDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportCondition = [KeyValue(key: D.cId, value: reportFile.id)]
            
            try statementBuilder.update(tableName: D.tDropboxInstanceVaultFile, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }

    func updateDropboxReportWithoutFiles(report: DropboxReport) -> Result<Void,Error> {
        do {
            
            let reportDict = report.dictionary
            let valuesToUpdate = reportDict.compactMap({ KeyValue(key: $0.key, value: $0.value) })
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
            
            try statementBuilder.update(tableName: D.tDropboxReport,
                                         valuesToUpdate: valuesToUpdate,
                                         equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }

    func updateDropboxReportStatus(idReport: Int, status: ReportStatus) -> Result<Void, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tDropboxReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateDropboxReportFolderId(idReport: Int, folderName: String) -> Result<Void, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cTitle, value: folderName),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tDropboxReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    /// DELETE
    func deleteDropboxReport(reportId: Int?) -> Result<Void, Error> {
        do {
            let reportCondition = [KeyValue(key: D.cReportId, value: reportId)]
            
            try statementBuilder.delete(tableName: D.tDropboxReport, primarykeyValue: reportCondition)
            
            try deleteDropboxInstanceFiles(reportIds: [reportId])
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func deleteDropboxSubmittedReports() -> Result<Void,Error> {
        do {
            let submittedReports = self.getDropboxReports(reportStatus: [.submitted])
            let reportIds = submittedReports.compactMap{$0.id}
            try deleteDropboxInstanceFiles(reportIds: reportIds)
            
            let reportCondition = [KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
            try statementBuilder.delete(tableName: D.tDropboxReport,
                                        primarykeyValue: reportCondition)
            return .success
            
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    private func deleteDropboxInstanceFiles(reportIds:[Int?]) throws {
        let reportIds = reportIds.compactMap{$0}
        let reportFilesCondition = [KeyValues(key: D.cReportInstanceId, value: reportIds)]
        try statementBuilder.delete(tableName: D.tDropboxInstanceVaultFile,
                                    inCondition: reportFilesCondition)
    }
}
