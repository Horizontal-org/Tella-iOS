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
            cddl(D.cBackgroundUpload, D.integer)]
        
        dataBaseHelper.createTable(tableName: D.tServer, columns: columns)
    }
    
    func createReportTable() {
        // c_id | c_title | c_description | c_date | cStatus | c_server_id
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
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
            cddl(D.cVaultFileId, D.text),
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
                                                        KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1)
                                                       ])
    }
    
    func getServer() -> [Server] {
        var servers : [Server] = []
        do {
            let serversDict = try dataBaseHelper.selectQuery(tableName: D.tServer, keyValue: [])
            
            serversDict.forEach { dict in
                let id = dict[D.cServerId] as? Int
                let name = dict[D.cName] as? String
                let url = dict[D.cURL] as? String
                let username = dict[D.cUsername] as? String
                let password = dict[D.cPassword] as? String
                let token = dict[D.cAccessToken] as? String
                let activatedMetadata = dict[D.cActivatedMetadata] as? Int
                let backgroundUpload = dict[D.cBackgroundUpload] as? Int
                
                servers.append( Server(id:id,
                                       name: name,
                                       url: url,
                                       username: username,
                                       password: password,
                                       accessToken: token,
                                       activatedMetadata: activatedMetadata == 0 ? false : true ,
                                       backgroundUpload: backgroundUpload == 0 ? false : true))
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
                                                    KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1) ],
                                         primarykeyValue: [KeyValue(key: D.cServerId, value: server.id)])
    }
    
    func deleteServer(serverId : Int) throws -> Int {
        return try dataBaseHelper.delete(tableName: D.tServer,
                                         primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
    }
    
    func getReports(reportStatus:ReportStatus) -> [Report] {
        
        var reports : [Report] = []
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            
            let responseDict = try dataBaseHelper.selectQuery(tableName: D.tReport,
                                                              keyValue: [KeyValue(key: D.cStatus, value: reportStatus.rawValue)],
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
                
                let server = Server(id:id,
                                    name: name,
                                    url: url,
                                    username: username,
                                    password: password,
                                    accessToken: token,
                                    activatedMetadata: activatedMetadata == 0 ? false : true ,
                                    backgroundUpload: backgroundUpload == 0 ? false : true)

                reports.append(Report(id: reportID,
                                      title: title ?? "",
                                      description: description ?? "",
                                      date: date?.getDate() ?? Date(),
                                      status: ReportStatus(rawValue: status ?? 0) ?? .draft,
                                      server: server,
                                      vaultFiles: getVaultFileId(reportID: reportID)))
            }
            
            return reports
            
        } catch {
            return []
        }
    }
    
    func getVaultFileId(reportID:Int?) -> [String] {
       
        var filesId : [String] = []
        
        do {
            let responseDict = try dataBaseHelper.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                              keyValue: [KeyValue(key: D.cReportInstanceId, value: reportID)])
            
            responseDict.forEach { dict in
                guard let vaultFileId = dict[D.cVaultFileId] as? String else {return}
                filesId.append(vaultFileId)
            }
            return filesId
            
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
        
        try report.vaultFiles?.forEach({ vaultFileId in
            print("vaultFile.id", vaultFileId)
            _ = try dataBaseHelper.insertInto(tableName: D.tReportInstanceVaultFile,
                                              keyValue: [KeyValue(key: D.cReportInstanceId, value: reportId),
                                                         KeyValue(key: D.cVaultFileId, value: vaultFileId)])
        })
        
        
        
        return 1
    }
    
    func updateReport(report : Report) throws -> Int {
        _ = try dataBaseHelper.update(tableName: D.tReport,
                                      keyValue: [KeyValue(key: D.cTitle, value: report.title),
                                                 KeyValue(key: D.cDescription, value: report.description),
                                                 KeyValue(key: D.cDate, value: report.date?.getDateString()),
                                                 KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                                 KeyValue(key: D.cServerId, value: report.server?.id)],
                                      primarykeyValue: [KeyValue(key: D.cReportId, value: report.id)])
        
        
        
        _ = try dataBaseHelper.delete(tableName: D.tReportInstanceVaultFile,
                                      primarykeyValue: [KeyValue(key: D.cReportInstanceId, value: report.id as Any)])
        
        try report.vaultFiles?.forEach({ vaultFileId in
            print("vaultFile.id", vaultFileId)
            _ = try dataBaseHelper.insertInto(tableName: D.tReportInstanceVaultFile,
                                              keyValue: [KeyValue(key: D.cReportInstanceId, value: report.id),
                                                         KeyValue(key: D.cVaultFileId, value: vaultFileId)])
        })
        
        
        return 1
    }
    
    func deleteReport(reportId : Int?) throws -> Int {
        return try dataBaseHelper.delete(tableName: D.tReport,
                                         primarykeyValue: [KeyValue(key: D.cReportId, value: reportId as Any)])
    }
    
}
