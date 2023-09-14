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
            cddl(D.cTemplateEntity, D.text),
            cddl(D.cTemplateDownloaded, D.integer),
            cddl(D.cTemplateUpdated, D.integer),
            cddl(D.cTemplateFavorite, D.integer),
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
                                                           andCondition: [KeyValue(key: D.cTemplateId, value: templateId)])
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
            KeyValue(key: D.cTemplateDownloaded, value: 1),
            KeyValue(key: D.cTemplateUpdated, value: 1),
            KeyValue(key: D.cTemplateFavorite, value: 0),
            KeyValue(key: D.cServerId, value: template.serverId),
            KeyValue(key: D.cServerName, value: template.serverName),
            KeyValue(key: D.cTemplateEntity, value: template.entityRowString),
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
