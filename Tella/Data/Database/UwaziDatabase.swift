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
    func addUwaziTemplate(template: CollectedTemplate) -> CollectedTemplate {
        let id = statementBuilder.insertInto(tableName: D.tUwaziTemplate, keyValue: [
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
    }
    func deleteAllUwaziTemplate() throws -> Int {
        return try statementBuilder.deleteAll(tableNames: [D.tUwaziTemplate])
    }
    func deleteUwaziTemplate(templateId: String) {
        statementBuilder.delete(tableName: D.tUwaziTemplate,
                                primarykeyValue: [KeyValue(key: D.cTemplateId, value: templateId)])
    }
    func deleteUwaziTemplate(id: Int) {
        statementBuilder.delete(tableName: D.tUwaziTemplate,
                                primarykeyValue: [KeyValue(key: D.cId, value: id)])
    }
}
// MARK: - Methods related to UwaziServerLanguageProtocol
extension TellaDataBase: UwaziServerLanguageProtocol {
    func createUwaziServerTable() {
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cURL, D.text),
            cddl(D.cUsername, D.text),
            cddl(D.cPassword, D.text),
            cddl(D.cAccessToken, D.text),
            cddl(D.cLocale, D.text),
            cddl(D.cServerType, D.integer)
        ]
        
        statementBuilder.createTable(tableName: D.tUwaziServer, columns: columns)
    }
    
    func addUwaziServer(server: UwaziServer) -> Int? {
        let valuesToAdd = [KeyValue(key: D.cName, value: server.name),
                           KeyValue(key: D.cURL, value: server.url),
                           KeyValue(key: D.cUsername, value: server.username),
                           KeyValue(key: D.cPassword, value: server.password ),
                           KeyValue(key: D.cAccessToken, value: server.accessToken),
                           KeyValue(key: D.cLocale, value: server.locale),
                           KeyValue(key: D.cServerType, value:server.serverType?.rawValue)
        ]
        
        
        return statementBuilder.insertInto(tableName: D.tUwaziServer, keyValue: valuesToAdd)
    }
    
    func getUwaziServer(serverId: Int) throws -> UwaziServer? {
        let response = try statementBuilder.selectQuery(tableName: D.tUwaziServer,
                                                           andCondition: [KeyValue(key: D.cServerId, value: serverId)])
        guard let uwaziServerDict = response.first else { return nil }
        
        return parseUwaziServer(dictionary: uwaziServerDict)
        
    }
    
    func parseUwaziServer(dictionary : [String:Any] ) -> UwaziServer {
        let id = dictionary[D.cServerId] as? Int
        let name = dictionary[D.cName] as? String
        let url = dictionary[D.cURL] as? String
        let username = dictionary[D.cUsername] as? String
        let password = dictionary[D.cPassword] as? String
        let token = dictionary[D.cAccessToken] as? String
        let servertType = dictionary[D.cServerType] as? Int
        let locale = dictionary[D.cLocale] as? String
        return UwaziServer(id:id,
                           name: name,
                           serverURL: url,
                           username: username,
                           password: password,
                           accessToken: token,
                           locale: locale,
                           serverType: ServerConnectionType(rawValue: servertType ?? 0)
        )
    }
    
    func updateUwaziServer(server: UwaziServer) -> Int? {
        let valuesToUpdate = [KeyValue(key: D.cName, value: server.name),
                              KeyValue(key: D.cURL, value: server.url),
                              KeyValue(key: D.cUsername, value: server.username),
                              KeyValue(key: D.cPassword, value: server.password),
                              KeyValue(key: D.cAccessToken, value: server.accessToken),
                              KeyValue(key: D.cLocale, value: server.locale)]

        let serverCondition = [KeyValue(key: D.cServerId, value: server.id)]
        return statementBuilder.update(tableName: D.tUwaziServer,
                                       keyValue: valuesToUpdate,
                                       primarykeyValue: serverCondition)
    }
}
