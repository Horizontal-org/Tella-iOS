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
        //        createReportFilesTable()
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
    
    //    func createReportFilesTable() {
    //        // c_id | c_vaultFile_id | c_report_id
    //        let columns = [
    //            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
    //            cddl(D.cVaultFileId, D.integer),
    //            cddl(D.cReportId, D.integer, tableName: D.tReport, referenceKey: D.cId)]
    //        dataBaseHelper.createTable(tableName: D.tReportFiles, columns: columns)
    //    }
    
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
                                      server: server))
            }
            
            return reports
            
        } catch {
            return []
        }
    }
    
    func addReport(report : Report) throws -> Int {
        return try dataBaseHelper.insertInto(tableName: D.tReport,
                                             keyValue: [KeyValue(key: D.cTitle, value: report.title),
                                                        KeyValue(key: D.cDescription, value: report.description),
                                                        KeyValue(key: D.cDate, value: report.date?.getDateString()),
                                                        KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                                        KeyValue(key: D.cServerId, value: report.server?.id)])
    }
    
    func updateReport(report : Report) throws -> Int {
        return try dataBaseHelper.update(tableName: D.tReport,
                                         keyValue: [KeyValue(key: D.cTitle, value: report.title),
                                                    KeyValue(key: D.cDescription, value: report.description),
                                                    KeyValue(key: D.cDate, value: report.date?.getDateString()),
                                                    KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                                    KeyValue(key: D.cServerId, value: report.server?.id)],
                                         primarykeyValue: [KeyValue(key: D.cReportId, value: report.id)])
    }
    
    func deleteReport(reportId : Int?) throws -> Int {
        return try dataBaseHelper.delete(tableName: D.tReport,
                                         primarykeyValue: [KeyValue(key: D.cReportId, value: reportId as Any)])
    }
    
}
