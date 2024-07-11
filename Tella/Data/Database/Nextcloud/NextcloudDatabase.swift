//
//  NextcloudDatabase.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    
    func createNextcloudServerTable() {
        let columns = [ cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
                        cddl(D.cName, D.text),
                        cddl(D.cURL, D.text),
                        cddl(D.cUsername, D.text),
                        cddl(D.cPassword, D.text),
                        cddl(D.cUserId, D.text),
                        cddl(D.cRootFolder, D.text)]
        
        statementBuilder.createTable(tableName: D.tNextcloudServer, columns: columns)
    }
    
    func addNextcloudServer(server: NextcloudServer) -> Int? {
        do {
            
            let nextcloudServerDictionnary = server.dictionary
            let valuesToAdd = nextcloudServerDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let serverId = try statementBuilder.insertInto(tableName: D.tNextcloudServer, keyValue: valuesToAdd)
            return serverId
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func updateNextcloudServer(server: NextcloudServer) -> Int? {
        do {
            
            let nextcloudServerDictionnary = server.dictionary
            let valuesToUpdate = nextcloudServerDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let serverCondition = [KeyValue(key: D.cId, value: server.id)]
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
    
    func deleteNextcloudServer(serverId: Int) -> Bool {
        do {
            try statementBuilder.delete(tableName: D.tNextcloudServer,
                                        primarykeyValue: [KeyValue(key: D.cId, value: serverId)])
            return true
        } catch let error {
            debugLog(error)
            return false
        }
    }
}

// Nextcloud Reports
extension TellaDataBase {
    
    func createNextcloudReportTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cStatus, D.integer),
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
            cddl(D.cReportInstanceId, D.integer, tableName: D.tNextcloudReport, referenceKey: D.cId)
            
        ]
        statementBuilder.createTable(tableName: D.tNextcloudInstanceVaultFile, columns: columns)
    }
    
    func addNextcloudReport(report: NextcloudReport) -> Int? {
        do {
            let reportValuesToAdd = [KeyValue(key: D.cTitle, value: report.title),
                                     KeyValue(key: D.cDescription, value: report.description),
                                     KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                     KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                                     KeyValue(key: D.cStatus, value: report.status.rawValue),
                                     KeyValue(key: D.cServerId, value: report.server?.id)]
            
            let reportId = try statementBuilder.insertInto(tableName: D.tNextcloudReport, keyValue: reportValuesToAdd)
            
            try report.reportFiles?.forEach( { reportFile in
                let reportFileValuesToAdd = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                             KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                             KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                             KeyValue(key: D.cBytesSent, value: 0),
                                             KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                             KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
                
                try statementBuilder.insertInto(tableName: D.tNextcloudInstanceVaultFile, keyValue: reportFileValuesToAdd)
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
            let reportsCondition = [KeyValue(key: D.cId, value: id)]
            let nextcloudDict = try statementBuilder.getSelectQuery(tableName: D.tNextcloudReport,
                                                                    equalCondition: reportsCondition
            )
            
            let decodedReports = try nextcloudDict.first?.decode(NextcloudReport.self)
            let reportFiles = getNextcloudVaultFiles(reportId: decodedReports?.id)
            decodedReports?.reportFiles = reportFiles
            return decodedReports
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getNextcloudVaultFiles(reportId: Int?) -> [ReportFile] {
        do {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: reportId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tNextcloudInstanceVaultFile, andCondition: reportFilesCondition)
            
            let decodedFiles = try responseDict.compactMap ({ dict in
                return try dict.decode(ReportFile.self)
            })
            
            return decodedFiles
        } catch let error {
            debugLog(error)
            
            return []
        }
    }
    
    func updateNextcloudReport(report: NextcloudReport) -> Bool {
        do {
            
            let valuesToUpdate = [ KeyValue(key: D.cTitle, value: report.title),
                                   KeyValue(key: D.cDescription, value: report.description),
                                   KeyValue(key: D.cStatus, value: report.status.rawValue),
                                   KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
            ]
            let reportCondition = [KeyValue(key: D.cId, value: report.id)]
            
            try statementBuilder.update(
                tableName: D.tNextcloudReport,
                valuesToUpdate: valuesToUpdate,
                equalCondition: reportCondition
            )
            
            if let files = report.reportFiles {
                let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: report.id)]
                
                try statementBuilder.delete(tableName: D.tNextcloudInstanceVaultFile, primarykeyValue: reportFilesCondition)
                
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
                    
                    try statementBuilder.insertInto(tableName: D.tNextcloudInstanceVaultFile, keyValue: reportFilesValuesToAdd)
                })
            }
            return true
        } catch let error {
            debugLog(error)
            return false
        }
    }
    
    func deleteNextcloudReport(reportId: Int?) -> Bool {
        do {
            let reportCondition = [KeyValue(key: D.cId, value: reportId)]
            
            try statementBuilder.delete(tableName: D.tNextcloudReport, primarykeyValue: reportCondition)
            
            return true
        } catch let error {
            debugLog(error)
            return false
        }
    }
}
