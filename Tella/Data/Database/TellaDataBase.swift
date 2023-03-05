//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3
import SQLCipher

class TellaDataBase {
    
    var dataBaseHelper = DataBaseHelper()
    
    init(key: String?) {
        dataBaseHelper.openDatabases(key: key)
        createTables()
    }
    
    func createTables() {
        createServerTable()
        createReportTable()
        createReportFilesTable()
    }
    
    func createServerTable() {
        // c_id | c_name | c_url | c_username | c_password | cAccessToken | cActivatedMetadata | cBackgroundUpload
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cURL, D.text),
            cddl(D.cUsername, D.text),
            cddl(D.cPassword, D.text),
            cddl(D.cAccessToken, D.text),
            cddl(D.cActivatedMetadata, D.integer),
            cddl(D.cBackgroundUpload, D.integer),
            cddl(D.cApiProjectId, D.text),
            cddl(D.cSlug, D.text)]
        
        dataBaseHelper.createTable(tableName: D.tServer, columns: columns)
    }
    
    func createReportTable() {
        // c_id | c_title | c_description | c_date | cStatus | c_server_id
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cApiReportId, D.text),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cDate, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)
        ]
        dataBaseHelper.createTable(tableName: D.tReport, columns: columns)
    }
    
    func createReportFilesTable() {
        
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cBytesSent, D.integer),
            cddl(D.cCreatedDate, D.text),
            cddl(D.cUpdatedDate, D.text),
            cddl(D.cReportInstanceId, D.integer, tableName: D.tReport, referenceKey: D.cReportId)
            
        ]
        dataBaseHelper.createTable(tableName: D.tReportInstanceVaultFile, columns: columns)
        
    }
    
    func addServer(server : Server) throws -> Int {
        return try dataBaseHelper.insertInto(tableName: D.tServer,
                                             keyValue: [KeyValue(key: D.cName, value: server.name),
                                                        KeyValue(key: D.cURL, value: server.url),
                                                        KeyValue(key: D.cUsername, value: server.username),
                                                        KeyValue(key: D.cPassword, value: server.password ),
                                                        KeyValue(key: D.cAccessToken, value: server.accessToken),
                                                        KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                                                        KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1),
                                                        KeyValue(key: D.cApiProjectId, value: server.projectId),
                                                        KeyValue(key: D.cSlug, value: server.slug)])
    }
    
    func getServer() -> [Server] {
        var servers : [Server] = []
        do {
            let serversDict = try dataBaseHelper.selectQuery(tableName: D.tServer, andCondition: [])
            
            serversDict.forEach { dict in
                let id = dict[D.cServerId] as? Int
                let name = dict[D.cName] as? String
                let url = dict[D.cURL] as? String
                let username = dict[D.cUsername] as? String
                let password = dict[D.cPassword] as? String
                let token = dict[D.cAccessToken] as? String
                let activatedMetadata = dict[D.cActivatedMetadata] as? Int
                let backgroundUpload = dict[D.cBackgroundUpload] as? Int
                let apiProjectId = dict[D.cApiProjectId] as? String
                let slug = dict[D.cSlug] as? String
                
                servers.append(Server(id:id,
                                      name: name,
                                      serverURL: url,
                                      username: username,
                                      password: password,
                                      accessToken: token,
                                      activatedMetadata: activatedMetadata == 0 ? false : true ,
                                      backgroundUpload: backgroundUpload == 0 ? false : true,
                                      projectId: apiProjectId,
                                      slug:slug))
            }
            
            return servers
            
        } catch {
            return []
        }
    }
    
    func updateServer(server : Server) throws -> Int {
        
        return try dataBaseHelper.update(tableName: D.tServer,
                                         keyValue: [KeyValue(key: D.cName, value: server.name),
                                                    KeyValue(key: D.cURL, value: server.url),
                                                    KeyValue(key: D.cUsername, value: server.username),
                                                    KeyValue(key: D.cPassword, value: server.password),
                                                    KeyValue(key: D.cAccessToken, value: server.accessToken),
                                                    KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                                                    KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1),
                                                    KeyValue(key: D.cApiProjectId, value: server.projectId),
                                                    KeyValue(key: D.cSlug, value: server.slug)],
                                         primarykeyValue: [KeyValue(key: D.cServerId, value: server.id)])
    }
    
    func deleteServer(serverId : Int) throws -> Int {
        return try dataBaseHelper.delete(tableName: D.tServer,
                                         primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
    }
    
    func getReports(reportStatus:[ReportStatus]) -> [Report] {
        
        var reports : [Report] = []
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            
            //            let statusArray = reportStatus.compactMap{KeyValue(key: D.cStatus, value: $0.rawValue) }
            let statusArray = reportStatus.compactMap{ $0.rawValue }
            
            let responseDict = try dataBaseHelper.selectQuery(tableName: D.tReport,
                                                              inCondition: [KeyValues(key:D.cStatus, value: statusArray )],
                                                              joinCondition: joinCondition)
            
            responseDict.forEach { dict in
                
                let id = dict[D.cServerId] as? Int
                let name = dict[D.cName] as? String
                let url = dict[D.cURL] as? String
                let username = dict[D.cUsername] as? String
                let password = dict[D.cPassword] as? String
                let token = dict[D.cAccessToken] as? String
                let activatedMetadata = dict[D.cActivatedMetadata] as? Int
                let backgroundUpload = dict[D.cBackgroundUpload] as? Int
                
                let reportID = dict[D.cReportId] as? Int
                let title = dict[D.cTitle] as? String
                let description = dict[D.cDescription] as? String
                let date = dict[D.cDate] as? String
                let status = dict[D.cStatus] as? Int
                let apiProjectId = dict[D.cApiProjectId] as? String
                let slug = dict[D.cSlug] as? String
                let apiReportId = dict[D.cApiReportId] as? String

                let server = Server(id:id,
                                    name: name,
                                    serverURL: url,
                                    username: username,
                                    password: password,
                                    accessToken: token,
                                    activatedMetadata: activatedMetadata == 0 ? false : true ,
                                    backgroundUpload: backgroundUpload == 0 ? false : true,
                                    projectId: apiProjectId,
                                    slug:slug)
                
                reports.append(Report(id: reportID,
                                      title: title ?? "",
                                      description: description ?? "",
                                      date: date?.getDate() ?? Date(),
                                      status: ReportStatus(rawValue: status ?? 0) ?? .draft,
                                      server: server,
                                      vaultFiles: getVaultFiles(reportID: reportID),
                                      apiID: apiReportId))
            }
            
            return reports
            
        } catch {
            return []
        }
    }
    
    func getReport(reportId:Int) -> Report? {
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            
            let responseDict = try dataBaseHelper.selectQuery(tableName: D.tReport,
                                                              andCondition: [KeyValue(key: D.cReportId, value: reportId)],
                                                              joinCondition: joinCondition)
            if !responseDict.isEmpty, let dict = responseDict.first  {
                
                let id = dict[D.cServerId] as? Int
                let name = dict[D.cName] as? String
                let url = dict[D.cURL] as? String
                let username = dict[D.cUsername] as? String
                let password = dict[D.cPassword] as? String
                let token = dict[D.cAccessToken] as? String
                let activatedMetadata = dict[D.cActivatedMetadata] as? Int
                let backgroundUpload = dict[D.cBackgroundUpload] as? Int
                
                let reportID = dict[D.cReportId] as? Int
                let title = dict[D.cTitle] as? String
                let description = dict[D.cDescription] as? String
                let date = dict[D.cDate] as? String
                let status = dict[D.cStatus] as? Int
                let apiProjectId = dict[D.cApiProjectId] as? String
                let slug = dict[D.cSlug] as? String
                let apiReportId = dict[D.cApiReportId] as? String

                let server = Server(id:id,
                                    name: name,
                                    serverURL: url,
                                    username: username,
                                    password: password,
                                    accessToken: token,
                                    activatedMetadata: activatedMetadata == 0 ? false : true ,
                                    backgroundUpload: backgroundUpload == 0 ? false : true,
                                    projectId: apiProjectId,
                                    slug:slug)
                
                return  Report(id: reportID,
                               title: title ?? "",
                               description: description ?? "",
                               date: date?.getDate() ?? Date(),
                               status: ReportStatus(rawValue: status ?? 0) ?? .draft,
                               server: server,
                               vaultFiles: getVaultFiles(reportID: reportID),
                               apiID: apiReportId)
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func getVaultFiles(reportID:Int?) -> [ReportFile] {
        
        var reportFiles : [ReportFile] = []
        
        do {
            let responseDict = try dataBaseHelper.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                              andCondition: [KeyValue(key: D.cReportInstanceId, value: reportID)])
            
            responseDict.forEach { dict in
                let id = dict[D.cId] as? Int
                let vaultFileId = dict[D.cVaultFileInstanceId] as? String
                let status = dict[D.cStatus] as? Int
                let bytesSent = dict[D.cBytesSent] as? Int
                let createdDate = dict[D.cCreatedDate] as? String
                let updatedDate = dict[D.cUpdatedDate] as? String
                
                let reportFile =  ReportFile(id: id,
                                             fileId: vaultFileId,
                                             status: FileStatus(rawValue: status ?? 0),
                                             bytesSent: bytesSent,
                                             createdDate: createdDate?.getDate(),
                                             updatedDate: updatedDate?.getDate())
                reportFiles.append(reportFile)
            }
            return reportFiles
            
        } catch {
            return []
        }
        
    }
    
    func addReport(report : Report) throws -> Int {
        let reportId = try dataBaseHelper.insertInto(tableName: D.tReport,
                                                     keyValue: [KeyValue(key: D.cTitle, value: report.title),
                                                                KeyValue(key: D.cDescription, value: report.description),
                                                                KeyValue(key: D.cDate, value: report.date?.getDateString()),
                                                                KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                                                KeyValue(key: D.cServerId, value: report.server?.id)])
        
        try report.reportFiles?.forEach({ reportFile in
            
            _ = try dataBaseHelper.insertInto(tableName: D.tReportInstanceVaultFile,
                                              keyValue: [KeyValue(key: D.cReportInstanceId, value: reportId),
                                                         KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                                         KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                                         KeyValue(key: D.cBytesSent, value: 0),
                                                         KeyValue(key: D.cCreatedDate, value: Date().getDateString()),
                                                         KeyValue(key: D.cUpdatedDate, value: Date().getDateString())
                                                        ])
            
            
        })
        return reportId
    }
    
    func updateReport(report : Report) throws -> Report? {
        
        var keyValueArray : [KeyValue]  = []
        
        if let title = report.title {
            keyValueArray.append(KeyValue(key: D.cTitle, value: title))
        }
        
        if let description = report.description {
            keyValueArray.append(KeyValue(key: D.cDescription, value: description))
        }
        
        if let date = report.date {
            keyValueArray.append(KeyValue(key: D.cDate, value: date.getDateString()))
        }
        
        if let status = report.status {
            keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
        }
        
        if let serverId = report.server?.id {
            keyValueArray.append(KeyValue(key: D.cServerId, value: serverId))
        }
        
        if let apiID = report.apiID {
            keyValueArray.append(KeyValue(key: D.cApiReportId, value: apiID))
        }


        _ = try dataBaseHelper.update(tableName: D.tReport,
                                      keyValue: keyValueArray,
                                      primarykeyValue: [KeyValue(key: D.cReportId, value: report.id)])
        
        if let files = report.reportFiles {
            _ = try dataBaseHelper.delete(tableName: D.tReportInstanceVaultFile,
                                          primarykeyValue: [KeyValue(key: D.cReportInstanceId, value: report.id as Any)])
            
            try files.forEach({ reportFile in
                _ = try dataBaseHelper.insertInto(tableName: D.tReportInstanceVaultFile,
                                                  keyValue: [
                                                    
                                                    reportFile.id == nil ? KeyValue(key: D.cId, value: report.id) : nil,
                                                    KeyValue(key: D.cReportInstanceId, value: report.id),
                                                    KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                                    KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                                    KeyValue(key: D.cBytesSent, value: reportFile.bytesSent),
                                                    KeyValue(key: D.cCreatedDate, value: reportFile.createdDate),
                                                    KeyValue(key: D.cUpdatedDate, value: Date().getDateString())
                                                  ])
            })
        }

        guard let reportId = report.id else { return nil }
        return getReport(reportId: reportId)
    }
    
    func updateReportStatus(idReport : Int, status: ReportStatus, date: Date) throws -> Int {
        
        return try dataBaseHelper.update(tableName: D.tReport,
                                         keyValue: [KeyValue(key: D.cStatus, value: status.rawValue),
                                                    KeyValue(key: D.cDate, value: date.getDateString())],
                                         primarykeyValue: [KeyValue(key: D.cReportId, value: idReport)])
    }
    
    func updateReportFile(reportFile:ReportFile) throws -> Int {
        
        var keyValueArray : [KeyValue]  = []
        
        if let status = reportFile.status {
            keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
        }
        
        if let bytesSent = reportFile.bytesSent {
            keyValueArray.append(KeyValue(key: D.cBytesSent, value: bytesSent))
        }

        if let createdDate = reportFile.createdDate {
            keyValueArray.append(KeyValue(key: D.cCreatedDate, value: createdDate.getDateString()))
        }

        if let updatedDate = reportFile.updatedDate {
            keyValueArray.append(KeyValue(key: D.cUpdatedDate, value: updatedDate.getDateString()))
        }

        return try dataBaseHelper.update(tableName: D.tReportInstanceVaultFile,
                                         keyValue: keyValueArray,
                                         primarykeyValue: [KeyValue(key: D.cId, value: reportFile.id)])
    }
    
    func deleteReport(reportId : Int?) throws -> Int {
        
        guard let reportId, let report = self.getReport(reportId: reportId) else { return 0}
        
        guard let array = report.reportFiles?.compactMap({ KeyValue(key: D.cReportInstanceId, value: $0.id as Any) } ) else { return 0}
        
        _ = try dataBaseHelper.delete(tableName: D.tReportInstanceVaultFile,
                                      primarykeyValue: array)
        
        return try dataBaseHelper.delete(tableName: D.tReport,
                                         primarykeyValue: [KeyValue(key: D.cReportId, value: report.id as Any)])
    }
}
