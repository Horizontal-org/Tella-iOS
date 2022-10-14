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
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
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
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cDate, D.text),
            cddl(D.cStatus, D.text),
            cddl(D.cServerId, D.text, tableName: D.tServer, referenceKey: D.cId)
        ]
        dataBaseHelper.createTable(tableName: D.tReport, columns: columns)
    }
    
    func createReportFilesTable() {
        // c_id | c_vaultFile_id | c_report_id
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileId, D.integer),
            cddl(D.cReportId, D.integer, tableName: D.tReport, referenceKey: D.cId)]
        dataBaseHelper.createTable(tableName: D.tReportFiles, columns: columns)
    }
    
    func addServer(server : Server) throws -> Int {
        return try dataBaseHelper.insertInto(tableName: D.tServer,
                                             keyValue: [KeyValue(key: D.cName, value: server.name),
                                                        KeyValue(key: D.cURL, value: server.url),
                                                        KeyValue(key: D.cUsername, value: server.username),
                                                        KeyValue(key: D.cPassword, value: server.password),
                                                        KeyValue(key: D.cAccessToken, value: server.accessToken as Any),
                                                        KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                                                        KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1)
                                                       ])
    }
    
    func getServer() -> [Server] {
        var servers : [Server] = []
        do {
            let serversDict = try dataBaseHelper.selectQuery(tableName: D.tServer, keyValue: [])
            
            serversDict.forEach { dict in
                if let id = dict[D.cId] as? Int,
                   let name = dict[D.cName] as? String,
                   let url = dict[D.cURL] as? String,
                   let username = dict[D.cUsername] as? String,
                   let password = dict[D.cPassword] as? String,
                   let token = dict[D.cAccessToken] as? String,
                   let activatedMetadata = dict[D.cActivatedMetadata] as? Int,
                   let backgroundUpload = dict[D.cBackgroundUpload] as? Int
                {
                    servers.append( Server(id:id,
                                           name: name,
                                           url: url,
                                           username: username,
                                           password: password,
                                           accessToken: token,
                                           activatedMetadata: activatedMetadata == 0 ? false : true ,
                                           backgroundUpload: backgroundUpload == 0 ? false : true))
                }
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
                                                    KeyValue(key: D.cAccessToken, value: server.accessToken as Any),
                                                    KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                                                    KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1) ],
                                         primarykeyValue: [KeyValue(key: D.cId, value: server.id as Any)])
    }
    
    func deleteServer(server : Server) throws -> Int {
        return try dataBaseHelper.delete(tableName: D.tServer,
                                         primarykeyValue: [KeyValue(key: D.cId, value: server.id as Any)])
    }
    
    func getReports()  {
        
    }
    
    func addReport() {
        
    }
    
    func updateReport()   {
        
    }
}
