//
//  UwaziServerDatabase.swift
//  Tella
//
//  Created by Robert Shrestha on 9/14/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
// MARK: - Methods related to Uwazi Server
extension TellaDataBase {
    func createServerTable() {
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
            cddl(D.cSlug, D.text),
            cddl(D.cAutoUpload, D.integer),
            cddl(D.cAutoDelete, D.integer)
        ]
        statementBuilder.createTable(tableName: D.tServer, columns: columns)
    }
    
    func addServer(server : TellaServer)  -> Result<Int, Error> {
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: server.name),
                               KeyValue(key: D.cURL, value: server.url),
                               KeyValue(key: D.cUsername, value: server.username),
                               KeyValue(key: D.cPassword, value: server.password ),
                               KeyValue(key: D.cAccessToken, value: server.accessToken),
                               KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                               KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1),
                               KeyValue(key: D.cApiProjectId, value: server.projectId),
                               KeyValue(key: D.cSlug, value: server.slug),
                               KeyValue(key: D.cAutoUpload, value:server.autoUpload == false ? 0 : 1),
                               KeyValue(key: D.cAutoDelete, value:server.autoDelete == false ? 0 : 1)]
            
            let serverId = try statementBuilder.insertInto(tableName: D.tServer,
                                                           keyValue: valuesToAdd)
            return .success(serverId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }

    func getAutoUploadServer() -> TellaServer? {
        do {
            let serverCondition = [KeyValue(key: D.cAutoUpload, value: 1)]
            let serversDict = try statementBuilder.selectQuery(tableName: D.tServer,
                                                               andCondition:serverCondition)
            if !serversDict.isEmpty, let dict = serversDict.first {
                return getTellaServer(dictionnary: dict)
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func getTellaServers() -> [TellaServer] {
        var servers: [TellaServer] = []
        
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tServer, andCondition: [])
            serversDict.forEach { dict in
                servers.append(getTellaServer(dictionnary: dict))
            }
        } catch {
            debugLog("Error while fetching servers from \(D.tServer): \(error)")
        }

        return servers
    }
    
    func getTellaServerById(id: Int) throws -> TellaServer? {
        let response = try statementBuilder.selectQuery(tableName: D.tServer, andCondition: [KeyValue(key: D.cServerId, value: id)])
        
        guard let tellaServerDict = response.first else { return nil }
        return getTellaServer(dictionnary: tellaServerDict)
    }
    
    func getTellaServer(dictionnary : [String:Any]) -> TellaServer {
        let id = dictionnary[D.cServerId] as? Int
        let name = dictionnary[D.cName] as? String
        let url = dictionnary[D.cURL] as? String
        let username = dictionnary[D.cUsername] as? String
        let password = dictionnary[D.cPassword] as? String
        let token = dictionnary[D.cAccessToken] as? String
        let activatedMetadata = dictionnary[D.cActivatedMetadata] as? Int
        let backgroundUpload = dictionnary[D.cBackgroundUpload] as? Int
        let apiProjectId = dictionnary[D.cApiProjectId] as? String
        let slug = dictionnary[D.cSlug] as? String
        let autoUpload = dictionnary[D.cAutoUpload] as? Int
        let autoDelete = dictionnary[D.cAutoDelete] as? Int

        return TellaServer(id:id,
                      name: name,
                      serverURL: url,
                      username: username,
                      password: password,
                      accessToken: token,
                      activatedMetadata: activatedMetadata == 0 ? false : true ,
                      backgroundUpload: backgroundUpload == 0 ? false : true,
                      projectId: apiProjectId,
                      slug:slug,
                      autoUpload: autoUpload == 0 ? false : true,
                      autoDelete: autoDelete == 0 ? false : true
        )
    }
    
    func updateServer(server : TellaServer) -> Result<Bool, Error> {
        do {
            
            let valuesToUpdate = [KeyValue(key: D.cName, value: server.name),
                                  KeyValue(key: D.cURL, value: server.url),
                                  KeyValue(key: D.cUsername, value: server.username),
                                  KeyValue(key: D.cPassword, value: server.password),
                                  KeyValue(key: D.cAccessToken, value: server.accessToken),
                                  KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                                  KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1),
                                  KeyValue(key: D.cApiProjectId, value: server.projectId),
                                  KeyValue(key: D.cSlug, value: server.slug),
                                  KeyValue(key: D.cAutoUpload, value:server.autoUpload == false ? 0 : 1 ),
                                  KeyValue(key: D.cAutoDelete, value:server.autoDelete == false ? 0 : 1 )]
            
            let serverCondition = [KeyValue(key: D.cServerId, value: server.id)]
            try statementBuilder.update(tableName: D.tServer,
                                        valuesToUpdate: valuesToUpdate,
                                        equalCondition: serverCondition)
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func deleteServer(serverId : Int) -> Result<Bool,Error> {
        do {
            var reportIDs : [Int] = []
            let serverCondition = [KeyValue(key: D.cServerId, value: serverId)]
            
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: serverCondition)
            
            responseDict.forEach { dict in
                if let id = dict[D.cReportId] as? Int {
                    reportIDs.append(id)
                }
            }
            
            try statementBuilder.delete(tableName: D.tServer,
                                        primarykeyValue: serverCondition)
            
            try statementBuilder.delete(tableName: D.tReport,
                                        primarykeyValue: serverCondition)
            
            try statementBuilder.delete(tableName: D.tResource,
                                        primarykeyValue: serverCondition)
            
            if !reportIDs.isEmpty {
                let reportCondition = [KeyValues(key: D.cReportInstanceId, value: reportIDs)]
                try statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                            inCondition: reportCondition)
            }
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func deleteAllServers() -> Result<Bool,Error> {
        do {
            try statementBuilder.deleteAll(tableNames: [D.tServer, D.tReport, D.tReportInstanceVaultFile, D.tUwaziServer, D.tUwaziTemplate, D.tUwaziEntityInstances, D.tUwaziEntityInstanceVaultFile, D.tResource, D.tGDriveServer, D.tGDriveReport, D.tGDriveInstanceVaultFile, D.tNextcloudServer, D.tNextcloudReport, D.tNextcloudInstanceVaultFile])
            
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
        
    }
}
