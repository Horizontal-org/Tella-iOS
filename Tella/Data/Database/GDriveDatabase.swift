//
//  GDriveDatabase.swift
//  Tella
//
//  Created by gus valbuena on 5/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

// GDrive Server
extension TellaDataBase {
    
    func createGDriveServerTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
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
            let reportValuesToAdd = [KeyValue(key: D.cTitle, value: report.title),
                                                 KeyValue(key: D.cDescription, value: report.description),
                                                 KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                                 KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                                                 KeyValue(key: D.cStatus, value: report.status.rawValue),
                                                 KeyValue(key: D.cServerId, value: report.server?.id)]
            
            let reportId = try statementBuilder.insertInto(tableName: D.tGDriveReport, keyValue: reportValuesToAdd)
            
            try report.reportFiles?.forEach( { reportFile in
                let reportFileValuesToAdd = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                             KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                             KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                             KeyValue(key: D.cBytesSent, value: 0),
                                             KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                             KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
                
                try statementBuilder.insertInto(tableName: D.tGDriveInstanceVaultFile, keyValue: reportFileValuesToAdd)
            })
            
            return .success(reportId)
            
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
    
    func updateDriveReport(report: GDriveReport) -> Result<Bool, Error> {
        do {
            
            let valuesToUpdate = [ KeyValue(key: D.cTitle, value: report.title),
                                   KeyValue(key: D.cDescription, value: report.description),
                                   KeyValue(key: D.cStatus, value: report.status.rawValue),
                                   KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
            ]
            let reportCondition = [KeyValue(key: D.cId, value: report.id)]

            try statementBuilder.update(
                tableName: D.tGDriveReport,
                valuesToUpdate: valuesToUpdate,
                equalCondition: reportCondition
            )
            
            if let files = report.reportFiles {
                let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: report.id)]
                
                try statementBuilder.delete(tableName: D.tGDriveInstanceVaultFile, primarykeyValue: reportFilesCondition)
                
                try files.forEach( { reportFile in
                    let reportFilesValuesToAdd = [
                        reportFile.id == nil ? nil : KeyValue(key: D.cId, value: reportFile.id),
                        KeyValue(key: D.cReportInstanceId, value: report.id),
                        KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                        KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                        KeyValue(key: D.cBytesSent, value: reportFile.bytesSent),
                        KeyValue(key: D.cCreatedDate, value: reportFile.createdDate),
                        KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                    ]
                    
                    try statementBuilder.insertInto(tableName: D.tGDriveInstanceVaultFile, keyValue: reportFilesValuesToAdd)
                })
            }
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func deleteDriveReport(reportId: Int?) -> Result<Bool, Error> {
        do {
            let reportCondition = [KeyValue(key: D.cId, value: reportId)]
            
            try statementBuilder.delete(tableName: D.tGDriveReport, primarykeyValue: reportCondition)
            
            return .success(true)
        } catch let error {
            debugLog(error)
            
            return .failure(error)
        }
    }
}
