//
//  GDriveDatabase.swift
//  Tella
//
//  Created by gus valbuena on 5/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    func createGDriveServerTable() {
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cRootFolder, D.text)
        ]
        
        statementBuilder.createTable(tableName: D.tGDriveServer, columns: columns)
    }
    
    func addGDriveServer(gDriveServer: GDriveServer) -> Result<Int, Error> {
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: gDriveServer.name),
                               KeyValue(key: D.cRootFolder, value: gDriveServer.rootFolder)
            ]
            
            let serverId = try statementBuilder.insertInto(tableName: D.tGDriveServer, keyValue: valuesToAdd)
            return .success(serverId)
        } catch let error {
            return .failure(error)
        }
    }
    
    func getDriveServers() -> [GDriveServer] {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tGDriveServer, andCondition: [])
            
            let driveServer = try serversDict.decode(GDriveServer.self)            
            return driveServer
        } catch {
            debugLog("Error while fetching servers from \(D.tGDriveServer): \(error)")
            return []
        }
    }
    
    func deleteGDriveServer(serverId: Int) {
        do {
            try statementBuilder.delete(tableName: D.tGDriveServer,
                                        primarykeyValue: [KeyValue(key: D.cId, value: serverId)])
            try statementBuilder.deleteAll(tableNames: [D.tGDriveReport, D.tGDriveInstanceVaultFile])
        } catch let error {
            debugLog(error)
        }
    }
    
}
// GDrive Reports
extension TellaDataBase {
    func createGDriveReportTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cStatus, D.integer),
            cddl(D.cFolderId, D.text),
            cddl(D.cServerId, D.integer, tableName: D.tGDriveServer, referenceKey: D.cId)
        ]
        
        statementBuilder.createTable(tableName: D.tGDriveReport, columns: columns)
    }
    func createGDriveReportFilesTable() {
        
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cBytesSent, D.integer),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cReportInstanceId, D.integer, tableName: D.tGDriveReport, referenceKey: D.cId)
            
        ]
        statementBuilder.createTable(tableName: D.tGDriveInstanceVaultFile, columns: columns)
        
    }
    
    func addGDriveReport(report: GDriveReport) -> Result<Int, Error> {
        do {
            let reportDict = report.dictionary
            let valuesToAdd = reportDict.compactMap({ KeyValue(key: $0.key, value: $0.value) })
            let reportId = try statementBuilder.insertInto(tableName: D.tGDriveReport, keyValue: valuesToAdd)
            
            _ = report.reportFiles?.compactMap({ $0.reportInstanceId = reportId })
            try report.reportFiles?.forEach( { reportFiles in
                let reportFilesDictionary = reportFiles.dictionary
                let reportFilesValuesToAdd = reportFilesDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
                
                try statementBuilder.insertInto(tableName: D.tGDriveInstanceVaultFile, keyValue: reportFilesValuesToAdd)
            })
            
            return .success(reportId)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateDriveReport(report: GDriveReport) -> Result<Bool, Error> {
        do {
            
            let reportDict = report.dictionary
            let valuesToUpdate = reportDict.compactMap({ KeyValue(key: $0.key, value: $0.value) })
            let reportCondition = [KeyValue(key: D.cId, value: report.id)]
            
            try statementBuilder.update(
                tableName: D.tGDriveReport,
                valuesToUpdate: valuesToUpdate,
                equalCondition: reportCondition
            )
            
            if let files = report.reportFiles, let reportId = report.id {
                let _ = try updateDriveReportFiles(files: files, reportId: reportId)
            }
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateDriveReportFiles(files: [ReportFile], reportId: Int) -> Result<Bool, Error> {
        do {
            try deleteDriveReportFiles(reportId: reportId)
            
            try files.forEach( { reportFiles in
                let reportFilesDict = reportFiles.dictionary
                let reportFilesValuesToAdd = reportFilesDict.compactMap({ KeyValue( key: $0.key, value: $0.value) })
                
                try statementBuilder.insertInto(tableName: D.tGDriveInstanceVaultFile, keyValue: reportFilesValuesToAdd)
            })
            
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func getDriveReports(reportStatus: [ReportStatus]) -> [GDriveReport] {
        do {
            
            let statusArray = reportStatus.compactMap{ $0.rawValue }
            
            let gDriveReportsDict = try statementBuilder.getSelectQuery(tableName: D.tGDriveReport,
                                                                        inCondition: [KeyValues(key:D.cStatus, value: statusArray )]
            )
            
            let decodedReports = try gDriveReportsDict.compactMap ({ dict in
                return try dict.decode(GDriveReport.self)
            })

            return decodedReports
            
        } catch let error {
            debugLog(error)
            return []
        }
    }
    
    func getGDriveReport(id: Int) -> GDriveReport? {
        do{
            let reportsCondition = [KeyValue(key: D.cId, value: id)]
            let gDriveReportsDict = try statementBuilder.getSelectQuery(tableName: D.tGDriveReport,
                                                                        equalCondition: reportsCondition
            )
            let decodedReports = try gDriveReportsDict.first?.decode(GDriveReport.self)
            let reportFiles = getDriveVaultFiles(reportId: decodedReports?.id)
            decodedReports?.reportFiles = reportFiles
            return decodedReports
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getDriveVaultFiles(reportId: Int?) -> [ReportFile] {
        do {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: reportId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tGDriveInstanceVaultFile, andCondition: reportFilesCondition)
            
            let decodedFiles = try responseDict.compactMap ({ dict in
                return try dict.decode(ReportFile.self)
            })

            return decodedFiles
        } catch let error {
            debugLog(error)
            
            return []
        }
    }
    
    func deleteDriveReport(reportId: Int?) -> Result<Bool, Error> {
        do {
            let reportCondition = [KeyValue(key: D.cId, value: reportId)]
            
            try statementBuilder.delete(tableName: D.tGDriveReport, primarykeyValue: reportCondition)
            
            // delete files
            try deleteDriveReportFiles(reportId: reportId)
            
            return .success(true)
        } catch let error {
            debugLog(error)
            
            return .failure(error)
        }
    }
    
    func deleteDriveReportFiles(reportId: Int?) throws {
        let fileCondition = [KeyValue(key: D.cReportInstanceId, value: reportId)]
        try statementBuilder.delete(tableName: D.tGDriveInstanceVaultFile, primarykeyValue: fileCondition)
    }
    
    func updateDriveReportStatus(idReport: Int, status: ReportStatus) -> Result<Bool, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            
            let reportCondition = [KeyValue(key: D.cId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tGDriveReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func updateDriveReportFolderId(idReport: Int, folderId: String) -> Result<Bool, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cFolderId, value: folderId),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            let reportCondition = [KeyValue(key: D.cId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tGDriveReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
}
