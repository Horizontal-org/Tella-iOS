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
    
    func addDropboxServer(dropboxServer: DropboxServer) -> Result<Int, Error>{
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
    
    func deleteDroboxServer(serverId: Int) {
        do {
            try statementBuilder.delete(tableName: D.tDropboxServer,
                                        primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
        } catch let error {
            debugLog(error)
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
            cddl(D.cOffset, D.integer),
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
                                                                        inCondition: [KeyValues(key:D.cStatus, value: statusArray )]
            )
            
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
            return .failure(error)
        }
    }
    
    /// UPDATE
    func updateDropboxReport(report: DropboxReport) -> Result<Bool, Error> {
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
                try deleteDropboxInstanceFiles(reportId: reportId)
                
                try files.forEach( { reportFiles in
                    let reportFilesDict = reportFiles.dictionary
                    let reportFilesValuesToAdd = reportFilesDict.compactMap({ KeyValue( key: $0.key, value: $0.value) })
                    
                    try statementBuilder.insertInto(tableName: D.tDropboxInstanceVaultFile, keyValue: reportFilesValuesToAdd)
                })
            }
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateDropboxReportFile(reportFile: ReportFile) -> Bool {
        do {
            let reportDictionary = reportFile.dictionary
            let valuesToUpdate = reportDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportCondition = [KeyValue(key: D.cId, value: reportFile.id)]
            
            try statementBuilder.update(tableName: D.tDropboxInstanceVaultFile, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return true
        } catch let error {
            debugLog(error)
            return false
        }
    }
    
    func updateDropboxReportStatus(idReport: Int, status: ReportStatus) -> Result<Bool, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tDropboxReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
                        
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateDropboxReportFolderId(idReport: Int, folderId: String) -> Result<Bool, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cFolderId, value: folderId),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tDropboxReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    /// DELETE
    func deleteDropboxReport(reportId: Int?) -> Result<Bool, Error> {
        do {
            let reportCondition = [KeyValue(key: D.cReportId, value: reportId)]
            
            try statementBuilder.delete(tableName: D.tDropboxReport, primarykeyValue: reportCondition)
            
            try deleteDropboxInstanceFiles(reportId: reportId)
            
            return .success(true)
        } catch let error {
            debugLog(error)
            
            return .failure(error)
        }
    }
    
    func deleteDropboxInstanceFiles(reportId: Int?) throws {
        let fileCondition = [KeyValue(key: D.cReportInstanceId, value: reportId)]
        try statementBuilder.delete(tableName: D.tDropboxInstanceVaultFile, primarykeyValue: fileCondition)
    }
}
