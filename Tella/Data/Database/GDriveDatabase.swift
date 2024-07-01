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
                                        primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
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
            cddl(D.cServerId, D.integer, tableName: D.tGDriveServer, referenceKey: D.cServerId)// update ref key after merge with server subclass PR
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
            let currentUpload = ((report.currentUpload == false) || (report.currentUpload == nil)) ? 0 : 1
            
            let reportValuesToAdd = [KeyValue(key: D.cTitle, value: report.title),
                                                 KeyValue(key: D.cDescription, value: report.description),
                                                 KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                                 KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                                                 KeyValue(key: D.cStatus, value: report.status?.rawValue),
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
    
    func getDraftGDriveReports() {
        do {
            let joinCondition = [JoinCondition(tableName: D.tGDriveServer,
                                                           firstItem: JoinItem(tableName: D.tGDriveReport, columnName: D.cServerId),
                                                           secondItem: JoinItem(tableName: D.tGDriveServer, columnName: D.cServerId))]
            
            let reportsCondition = [KeyValue(key: D.cStatus, value: ReportStatus.draft.rawValue)]
            
            let gDriveReportsDict = try statementBuilder.getSelectQuery(tableName: D.tGDriveReport,
                                                                        equalCondition: reportsCondition,
                                                                        joinCondition: joinCondition
            )
            
        } catch let error {
            debugLog(error)
        }
    }
}
