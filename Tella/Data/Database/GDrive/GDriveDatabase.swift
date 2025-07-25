//
//  GDriveDatabase.swift
//  Tella
//
//  Created by gus valbuena on 5/24/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension TellaDataBase {
    func createGDriveServerTable() {
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cRootFolder, D.text),
            cddl(D.cRootFolderName, D.text)
        ]
        
        statementBuilder.createTable(tableName: D.tGDriveServer, columns: columns)
    }
    
    func addGDriveServer(gDriveServer: GDriveServer) -> Result<Int, Error> {
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: gDriveServer.name),
                               KeyValue(key: D.cRootFolder, value: gDriveServer.rootFolder),
                               KeyValue(key: D.cRootFolderName, value: gDriveServer.rootFolderName)
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
    
    func deleteGDriveServer(serverId: Int) -> Result<Void,Error> {
        do {
            try statementBuilder.delete(tableName: D.tGDriveServer,
                                        primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
            try statementBuilder.deleteAll(tableNames: [D.tGDriveReport, D.tGDriveInstanceVaultFile])
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
}

// GDrive Reports
extension TellaDataBase {
    func createGDriveReportTable() {
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
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
            cddl(D.cReportInstanceId, D.integer, tableName: D.tGDriveReport, referenceKey: D.cReportId)
            
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
    
    func updateDriveReport(report: GDriveReport) -> Result<Void, Error> {
        do {
            
            let reportDict = report.dictionary
            let valuesToUpdate = reportDict.compactMap({ KeyValue(key: $0.key, value: $0.value) })
            let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
            
            try statementBuilder.update(
                tableName: D.tGDriveReport,
                valuesToUpdate: valuesToUpdate,
                equalCondition: reportCondition
            )
            
            if let files = report.reportFiles, let reportId = report.id {
                let _ = try updateDriveReportFiles(files: files, reportId: reportId)
            }
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateDriveReportFiles(files: [ReportFile], reportId: Int) -> Result<Void, Error> {
        do {
            try deleteDriveReportFiles(reportIds: [reportId])
            
            try files.forEach( { reportFiles in
                let reportFilesDict = reportFiles.dictionary
                let reportFilesValuesToAdd = reportFilesDict.compactMap({ KeyValue( key: $0.key, value: $0.value) })
                
                try statementBuilder.insertInto(tableName: D.tGDriveInstanceVaultFile, keyValue: reportFilesValuesToAdd)
            })
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }

    func updateDriveFile(reportFile: ReportFile) -> Result<Void,Error> {
        do {
            
            let reportFileDictionary = reportFile.dictionary
            let valuesToUpdate = reportFileDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let reportFileCondition = [KeyValue(key: D.cId, value: reportFile.id)]
            
            try statementBuilder.update(tableName: D.tGDriveInstanceVaultFile,
                                        valuesToUpdate: valuesToUpdate,
                                        equalCondition: reportFileCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
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
            let reportsCondition = [KeyValue(key: D.cReportId, value: id)]
            let gDriveReportsDict = try statementBuilder.getSelectQuery(tableName: D.tGDriveReport,
                                                                        equalCondition: reportsCondition
            )
            
            guard let dict = gDriveReportsDict.first else {
                return nil
            }
            
            let decodedReports = try dict.decode(GDriveReport.self)
            let reportFiles = getDriveVaultFiles(reportId: decodedReports.id)
            decodedReports.reportFiles = reportFiles
            
            let server = getDriveServers().first
            decodedReports.server = server
            
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
    
    func deleteDriveReport(reportId: Int?) -> Result<Void, Error> {
        do {
            let reportCondition = [KeyValue(key: D.cReportId, value: reportId)]
            
            try statementBuilder.delete(tableName: D.tGDriveReport, primarykeyValue: reportCondition)
            
            // delete files
            try deleteDriveReportFiles(reportIds: [reportId])
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    
    func deleteDriveSubmittedReports() -> Result<Void,Error> {
        do {
            let submittedReports = self.getDriveReports(reportStatus: [.submitted])
            let reportIds = submittedReports.compactMap{$0.id}
            try deleteDriveReportFiles(reportIds: reportIds)
            
            let reportCondition = [KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
            try statementBuilder.delete(tableName: D.tGDriveReport,
                                        primarykeyValue: reportCondition)
            return .success
            
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }

    private func deleteDriveReportFiles(reportIds:[Int?]) throws {
        let reportIds = reportIds.compactMap{$0}
        let reportFilesCondition = [KeyValues(key: D.cReportInstanceId, value: reportIds)]
        try statementBuilder.delete(tableName: D.tGDriveInstanceVaultFile,
                                    inCondition: reportFilesCondition)
    }

    func updateDriveReportStatus(idReport: Int, status: ReportStatus) -> Result<Void, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tGDriveReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func updateDriveReportFolderId(idReport: Int, folderId: String) -> Result<Void, Error> {
        do {
            let valuesToUpdate = [KeyValue(key: D.cFolderId, value: folderId),
                                  KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())
            ]
            let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
            
            try statementBuilder.update(tableName: D.tGDriveReport, valuesToUpdate: valuesToUpdate, equalCondition: reportCondition)
            
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
}
