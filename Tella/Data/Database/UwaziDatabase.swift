//
//  TellaUwaziTemplateDatabase.swift
//  Tella
//
//  Created by Robert Shrestha on 9/14/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

// MARK: - Methods related to UwaziTemplateProtocol
extension TellaDataBase: UwaziTemplateProtocol {
    func createTemplateTableForUwazi() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTemplateId, D.text),
            cddl(D.cEntity, D.text),
            cddl(D.cDownloaded, D.integer),
            cddl(D.cUpdated, D.integer),
            cddl(D.cFavorite, D.integer),
            cddl(D.cServerName, D.text),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)

        ]
        statementBuilder.createTable(tableName: D.tUwaziTemplate, columns: columns)
    }
    func getUwaziTemplate(serverId: Int) throws -> CollectedTemplate? {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziTemplate,
                                                           andCondition: [KeyValue(key: D.cServerId, value: serverId)])
        guard let template = serversDict.first else { return nil }
        return try JSONDecoder().decode(CollectedTemplate.self, from: template)
    }
    func getUwaziTemplate(templateId: Int) throws -> CollectedTemplate? {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziTemplate,
                                                           andCondition: [KeyValue(key: D.cId, value: templateId)])
        guard let template = serversDict.first else { return nil }
        return try JSONDecoder().decode(CollectedTemplate.self, from: template)
    }
    func getAllUwaziTemplate() throws -> [CollectedTemplate] {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziTemplate,
                                                           andCondition: [])
        if !serversDict.isEmpty {
            return try JSONDecoder().decode([CollectedTemplate].self, from: serversDict)
        }
        return []
    }
    func addUwaziTemplate(template: CollectedTemplate) -> CollectedTemplate? {
        do {
            let id = try statementBuilder.insertInto(tableName: D.tUwaziTemplate, keyValue: [
                KeyValue(key: D.cTemplateId, value: template.templateId),
                KeyValue(key: D.cDownloaded, value: 1),
                KeyValue(key: D.cUpdated, value: 1),
                KeyValue(key: D.cFavorite, value: 0),
                KeyValue(key: D.cServerId, value: template.serverId),
                KeyValue(key: D.cServerName, value: template.serverName),
                KeyValue(key: D.cEntity, value: template.entityRowString),
            ])
            template.id = id
            template.isUpdated = true
            template.isDownloaded = true
            return template
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    func deleteAllUwaziTemplate() {
        do {
            try statementBuilder.deleteAll(tableNames: [D.tUwaziTemplate])
        } catch let error {
            debugLog(error)
        }
    }
    func deleteUwaziTemplate(templateId: String) {
        do{
            try statementBuilder.delete(tableName: D.tUwaziTemplate,
                                    primarykeyValue: [KeyValue(key: D.cTemplateId, value: templateId)])
        } catch let error {
            debugLog(error)
        }
    }
    func deleteUwaziTemplate(id: Int) {
        do {
            try statementBuilder.delete(tableName: D.tUwaziTemplate,
                                    primarykeyValue: [KeyValue(key: D.cId, value: id)])
        } catch let error {
            debugLog(error)
        }
    }
}
// MARK: - Methods related to UwaziServerLanguageProtocol
extension TellaDataBase: UwaziServerLanguageProtocol {
    func createUwaziServerTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cURL, D.text),
            cddl(D.cUsername, D.text),
            cddl(D.cPassword, D.text),
            cddl(D.cAccessToken, D.text),
            cddl(D.cLocale, D.text),
        ]
        
        statementBuilder.createTable(tableName: D.tUwaziServer, columns: columns)
    }
    
    func addUwaziServer(server: UwaziServer) -> Int? {
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: server.name),
                               KeyValue(key: D.cURL, value: server.url),
                               KeyValue(key: D.cUsername, value: server.username),
                               KeyValue(key: D.cPassword, value: server.password ),
                               KeyValue(key: D.cAccessToken, value: server.accessToken),
                               KeyValue(key: D.cLocale, value: server.locale)
            ]
            
            
            return try statementBuilder.insertInto(tableName: D.tUwaziServer, keyValue: valuesToAdd)
        } catch let error {
            debugLog(error)
            return nil
        }
    }

    func getUwaziServers() -> [UwaziServer] {
        var servers: [UwaziServer] = []
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziServer, andCondition: [])
            serversDict.forEach { dict in
                servers.append(parseUwaziServer(dictionary: dict))
            }
        } catch {
            debugLog("Error while fetching servers from \(D.tUwaziServer): \(error)")
        }
        
        return servers
    }
    
    func getUwaziServer(serverId: Int) throws -> UwaziServer? {
        let response = try statementBuilder.selectQuery(tableName: D.tUwaziServer,
                                                           andCondition: [KeyValue(key: D.cId, value: serverId)])
        guard let uwaziServerDict = response.first else { return nil }
        
        return parseUwaziServer(dictionary: uwaziServerDict)
        
    }
    
    func parseUwaziServer(dictionary : [String:Any] ) -> UwaziServer {
        let id = dictionary[D.cId] as? Int
        let name = dictionary[D.cName] as? String
        let url = dictionary[D.cURL] as? String
        let username = dictionary[D.cUsername] as? String
        let password = dictionary[D.cPassword] as? String
        let token = dictionary[D.cAccessToken] as? String
        let locale = dictionary[D.cLocale] as? String
        return UwaziServer(id:id,
                           name: name,
                           serverURL: url,
                           username: username,
                           password: password,
                           accessToken: token,
                           locale: locale
        )
    }
    
    func updateUwaziServer(server: UwaziServer) -> Int? {
        do {
            let valuesToUpdate = [KeyValue(key: D.cName, value: server.name),
                                  KeyValue(key: D.cURL, value: server.url),
                                  KeyValue(key: D.cUsername, value: server.username),
                                  KeyValue(key: D.cPassword, value: server.password),
                                  KeyValue(key: D.cAccessToken, value: server.accessToken),
                                  KeyValue(key: D.cLocale, value: server.locale)]

            let serverCondition = [KeyValue(key: D.cId, value: server.id)]
            return try statementBuilder.update(tableName: D.tUwaziServer,
                                           valuesToUpdate: valuesToUpdate,
                                           equalCondition: serverCondition)
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func deleteUwaziServer(serverId : Int) {
        do {
            let serverCondition = [KeyValue(key: D.cId, value: serverId)]

            try statementBuilder.delete(tableName: D.tUwaziServer,
                                    primarykeyValue: serverCondition)

            try statementBuilder.delete(tableName: D.tUwaziTemplate,
                                    primarykeyValue: serverCondition)
        } catch let error {
            debugLog(error)
        }

    }
}
