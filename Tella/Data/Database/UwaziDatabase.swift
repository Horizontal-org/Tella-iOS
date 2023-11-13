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
    func createLanguageTableForUwazi() {
        let columns = [
            cddl(D.cLocaleId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cServerId, D.integer),
            cddl(D.cLocale, D.text),
        ]
        statementBuilder.createTable(tableName: D.tUwaziServerLanguage, columns: columns)
    }
    
    func createUwaziServerTable() {
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cURL, D.text),
            cddl(D.cUsername, D.text),
            cddl(D.cPassword, D.text),
            cddl(D.cAccessToken, D.text),
            cddl(D.cServerType, D.integer),
            cddl(D.cCookie, D.text)
        ]
        
        statementBuilder.createTable(tableName: D.tUwaziServer, columns: columns)
    }
    
    func addUwaziServer(server: UwaziServer) -> Int? {
        let valuesToAdd = [KeyValue(key: D.cName, value: server.name),
                           KeyValue(key: D.cURL, value: server.url),
                           KeyValue(key: D.cUsername, value: server.username),
                           KeyValue(key: D.cPassword, value: server.password ),
                           KeyValue(key: D.cAccessToken, value: server.accessToken),
                           KeyValue(key: D.cCookie, value: server.cookie),
                           KeyValue(key: D.cServerType, value:server.serverType?.rawValue)
        ]
        
        
        return statementBuilder.insertInto(tableName: D.tUwaziServer, keyValue: valuesToAdd)
    }
    func addUwaziLocale(locale: UwaziLocale) -> Int? {
        return statementBuilder.insertInto(tableName: D.tUwaziServerLanguage, keyValue: [
            KeyValue(key: D.cLocale, value: locale.locale),
            KeyValue(key: D.cServerId, value: locale.serverId),
        ])
    }

    func updateLocale(localeId: Int, locale: String) -> Int? {
        let valuesToUpdate = [KeyValue(key: D.cLocale, value: locale)]
        let serverCondition = [KeyValue(key: D.cLocaleId, value: localeId)]
        return statementBuilder.update(tableName: D.tUwaziServerLanguage,
                                       keyValue: valuesToUpdate,
                                       primarykeyValue: serverCondition)
    }

    func getUwaziLocale(serverId: Int) -> UwaziLocale? {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziServerLanguage,
                                                               andCondition: [KeyValue(key: D.cServerId, value: serverId)])
            guard let locale = serversDict.first else { return nil }
            return try JSONDecoder().decode(UwaziLocale.self, from: locale)
        }catch let error {
            debugLog(error.localizedDescription)
            return nil
        }
    }
    func getAllUwaziLocale() throws -> [UwaziLocale] {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziServerLanguage,
                                                           andCondition: [])
        if !serversDict.isEmpty {
            return try JSONDecoder().decode([UwaziLocale].self, from: serversDict)
        }
        return []
    }

    func deleteUwaziLocale(serverId : Int) {
        statementBuilder.delete(tableName: D.tUwaziServerLanguage,
                                primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
    }

    func deleteAllUwaziLocale() throws -> Int {
        return try statementBuilder.deleteAll(tableNames: [D.tUwaziServerLanguage])
    }
}
