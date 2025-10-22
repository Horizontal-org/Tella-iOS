//
//  TellaUwaziTemplateDatabase.swift
//  Tella
//
//  Created by Robert Shrestha on 9/14/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

// MARK: - Methods related to UwaziTemplateProtocol
extension TellaDataBase: UwaziTemplateProtocol {
    func createTemplateTableForUwazi() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cTemplateId, D.text),
            cddl(D.cEntity, D.text),
            cddl(D.cRelationships, D.text),
            cddl(D.cDownloaded, D.integer),
            cddl(D.cUpdated, D.integer),
            cddl(D.cFavorite, D.integer),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)
            
        ]
        statementBuilder.createTable(tableName: D.tUwaziTemplate, columns: columns)
    }
    func addRelationshipColumnToUwaziTemplate() {
        do {
            try statementBuilder.addColumnOn(tableName: D.tUwaziTemplate, columnName: D.cRelationships, type: D.text)
        } catch let error {
            debugLog(error)
        }
    }
    func getUwaziTemplate(serverId: Int) throws -> CollectedTemplate? {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziTemplate,
                                                           andCondition: [KeyValue(key: D.cServerId, value: serverId)])
        guard let template = serversDict.first else { return nil }
        return try JSONDecoder().decode(CollectedTemplate.self, from: template)
    }
    func getUwaziTemplate(templateId: Int?) throws -> CollectedTemplate? {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziTemplate,
                                                           andCondition: [KeyValue(key: D.cId, value: templateId)])
        guard let template = serversDict.first else { return nil }
        return try JSONDecoder().decode(CollectedTemplate.self, from: template)
    }
    func getAllUwaziTemplate() throws -> [CollectedTemplate] {

        let responseDict = try statementBuilder.selectQuery(tableName: D.tUwaziTemplate)
        
        return try responseDict.compactMap({ dict in
            
            let template =  try dict.decode(CollectedTemplate.self)
            
            let server = try getUwaziServer(serverId: template.serverId)
            template.serverName = server?.name
            return template
        })
    }
    
    func addUwaziTemplate(template: CollectedTemplate) -> Result<CollectedTemplate, Error> {
        do {
            let templateDictionary = template.dictionary
            let valuesToAdd = templateDictionary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            try statementBuilder.insertInto(tableName: D.tUwaziTemplate, keyValue: valuesToAdd)
            return .success(template)
        } catch let error {
            return .failure(error)
        }
    }
    
    func updateUwaziTemplate(template: CollectedTemplate) -> Int? {
        do {
            let templateDictionary = template.dictionary
            let valuesToUpdate = templateDictionary.compactMap({ KeyValue(key: $0.key, value: $0.value )})
            let templateCondition = [KeyValue(key: D.cId, value: template.id)]
            return try statementBuilder.update(tableName: D.tUwaziTemplate,
                                               valuesToUpdate: valuesToUpdate,
                                               equalCondition: templateCondition)
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
    
    func deleteUwaziTemplate(id: Int) -> Result<Bool,Error> {
        
        do {
            try statementBuilder.delete(tableName: D.tUwaziTemplate,
                                        primarykeyValue: [KeyValue(key: D.cId, value: id)])
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
}
// MARK: - Methods related to UwaziServerLanguageProtocol
extension TellaDataBase: UwaziServerLanguageProtocol {
    
    func createUwaziServerTable() {
        let columns = [ cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
                        cddl(D.cName, D.text),
                        cddl(D.cURL, D.text),
                        cddl(D.cUsername, D.text),
                        cddl(D.cPassword, D.text),
                        cddl(D.cAccessToken, D.text),
                        cddl(D.cLocale, D.text)]
        
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
    
    func getUwaziServer(serverId: Int?) throws -> UwaziServer? {
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
    
    func deleteUwaziServer(serverId : Int) -> Result<Void,Error> {
        do {
            let serverCondition = [KeyValue(key: D.cId, value: serverId)]
            
            try statementBuilder.delete(tableName: D.tUwaziServer,
                                        primarykeyValue: serverCondition)
            
            let templateCondition = [KeyValue(key: D.cServerId, value: serverId)]

            try statementBuilder.delete(tableName: D.tUwaziTemplate,
                                        primarykeyValue: templateCondition)

            try statementBuilder.delete(tableName: D.tUwaziEntityInstances,
                                        primarykeyValue: templateCondition)
            return .success
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
}


protocol UwaziEntityInstanceProtocol {
    func createUwaziEntityInstancesTable()
    
}

// MARK: - Methods related to UwaziEntityInstance

extension TellaDataBase:UwaziEntityInstanceProtocol {
    
    func createUwaziEntityInstancesTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cLocalTemplateId, D.integer, true),
            cddl(D.cMetadata, D.text, true),
            cddl(D.cTitle, D.text, true),
            cddl(D.cStatus, D.integer, true , 0),
            cddl(D.cUpdatedDate, D.float, true , 0),
            cddl(D.cType, D.text, true),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)
        ]
        statementBuilder.createTable(tableName: D.tUwaziEntityInstances, columns: columns)
    }
    
    func createUwaziEntityInstanceVaultFileTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.integer, true),
            cddl(D.cStatus, D.integer, true , 0),
            cddl(D.cUwaziEntityInstanceId, D.integer, tableName: D.tUwaziEntityInstances, referenceKey: D.cId)
        ]
        statementBuilder.createTable(tableName: D.tUwaziEntityInstanceVaultFile, columns: columns)
    }
    
    
    func addUwaziEntityInstance(entityInstance : UwaziEntityInstance) -> Result<Int, Error> {
        
        do {
            
            let entityInstanceDictionnary = entityInstance.dictionary
            
            let valuesToAdd = entityInstanceDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let entityInstanceId = try statementBuilder.insertInto(tableName: D.tUwaziEntityInstances,
                                                                   keyValue:valuesToAdd)
            
            _ = entityInstance.files.compactMap({$0.entityInstanceId = entityInstanceId})
            
            try entityInstance.files.forEach({ widgetMediaFiles in
                
                let widgetMediaFilesDictionnary = widgetMediaFiles.dictionary
                let fileValuesToAdd = widgetMediaFilesDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
                try statementBuilder.insertInto(tableName: D.tUwaziEntityInstanceVaultFile,
                                                keyValue: fileValuesToAdd)
            })
            return .success(entityInstanceId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    // MARK: TODO
    func updateUwaziEntityInstance(entityInstance : UwaziEntityInstance) -> Result<Int, Error> {
        
        
        do {
            
            let entityInstanceDictionnary = entityInstance.dictionary
            
            let valuesToUpdate = entityInstanceDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            let entityInstanceCondition = [KeyValue(key: D.cId, value: entityInstance.id)]
            
            let entityInstanceId = try statementBuilder.update(tableName: D.tUwaziEntityInstances, 
                                                               valuesToUpdate: valuesToUpdate,
                                                               equalCondition: entityInstanceCondition)

            let condition = [KeyValue(key: D.cUwaziEntityInstanceId, value: entityInstance.id)]
            
            try statementBuilder.delete(tableName: D.tUwaziEntityInstanceVaultFile,
                                        primarykeyValue:condition )

            try entityInstance.files.forEach({ widgetMediaFiles in
                let widgetMediaFilesDictionnary = widgetMediaFiles.dictionary
                let fileValuesToAdd = widgetMediaFilesDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
                try statementBuilder.insertInto(tableName: D.tUwaziEntityInstanceVaultFile,
                                                keyValue: fileValuesToAdd)
            })
            return .success(entityInstanceId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func getUwaziEntityInstance(entityStatus:[EntityStatus]) -> [UwaziEntityInstance] {
        
        do {
            
            let statusArray = entityStatus.compactMap{ $0.rawValue }
            
            let responseDict = try statementBuilder.getSelectQuery(tableName: D.tUwaziEntityInstances,
                                                                   inCondition: [KeyValues(key:D.cStatus, value: statusArray)])
            
            return try responseDict.compactMap({ dict in
                let entityInstance = try dict.decode(UwaziEntityInstance.self)
                
                
                let server = try getUwaziServer(serverId: entityInstance.serverId)
                entityInstance.server = server
                
                let collectedTemplate = try getUwaziTemplate(templateId: entityInstance.templateId)
                entityInstance.collectedTemplate = collectedTemplate
                
                entityInstance.files = getVaultFiles(instanceId: entityInstance.id)
                return entityInstance
            })
        } catch let error {
            debugLog(error)
            return []
        }
    }
    
    func getUwaziEntityInstance(entityId:Int) -> UwaziEntityInstance? {
        
        do {
            let entityInstanceCondition = [KeyValue(key: D.cId, value: entityId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tUwaziEntityInstances,
                                                                andCondition: entityInstanceCondition)
            
            guard let entityInstance = try responseDict.first?.decode(UwaziEntityInstance.self) else  {return nil}
            
            let server = try getUwaziServer(serverId: entityInstance.serverId)
            entityInstance.server = server
            
            let collectedTemplate = try getUwaziTemplate(templateId: entityInstance.templateId)
            entityInstance.collectedTemplate = collectedTemplate
            
            entityInstance.files = getVaultFiles(instanceId: entityInstance.id)
            return entityInstance

        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getVaultFiles(instanceId:Int?) -> [UwaziEntityInstanceFile] {
        
        do {
            guard let instanceId else {return [] }
            let instanceCondition = [KeyValue(key: D.cUwaziEntityInstanceId, value: instanceId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tUwaziEntityInstanceVaultFile,
                                                                andCondition: instanceCondition)
            let entityInstances = try responseDict.decode(UwaziEntityInstanceFile.self)
            return entityInstances
            
        } catch {
            return []
        }
    }
    
    func deleteEntityInstance(entityId : Int) -> Result<Bool,Error> {
        do {
            guard let entity = self.getUwaziEntityInstance(entityId: entityId) else {
                return .failure(RuntimeError("No Entity is selected"))
            }
            try deleteEntityInstanceFiles(entityIds: [entityId])
            
            let entityCondition = [KeyValue(key: D.cId, value: entity.id)]
            try statementBuilder.delete(tableName: D.tUwaziEntityInstances,
                                        primarykeyValue: entityCondition)
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    private func deleteEntityInstanceFiles(entityIds:[Int]) throws {
        let entityCondition = [KeyValues(key: D.cUwaziEntityInstanceId, value: entityIds)]
        try statementBuilder.delete(tableName: D.tUwaziEntityInstanceVaultFile,
                                    inCondition: entityCondition)
    }
    
}
