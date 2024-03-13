//
//  ResourceDatabase.swift
//  Tella
//
//  Created by gus valbuena on 2/15/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    func createResourceTable() {
        let columns = [
            cddl(D.cId, D.text, primaryKey: true, autoIncrement: false),
            cddl(D.cExternalId, D.text),
            cddl(D.cFilename, D.text),
            cddl(D.cTitle, D.text),
            cddl(D.cSize, D.text),
            cddl(D.cCreatedDate, D.text),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)
        ]
        
        statementBuilder.createTable(tableName: D.tResource, columns: columns)
    }
    
    func getDownloadedResources() -> [DownloadedResource] {
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tResource, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tResource, joinCondition: joinCondition)

            let decodedResources = try responseDict.decode(DownloadedResource.self)
            
            return decodedResources
        } catch {
            return []
        }
    }
    
    func addDownloadedResource(resource: Resource, serverId: Int)  -> Result<String, Error> {
        do {
            let uniqueId = UUID().uuidString
            let valuesToAdd = [KeyValue(key: D.cId, value: uniqueId),
                               KeyValue(key: D.cExternalId, value: resource.id),
                               KeyValue(key: D.cFilename, value: resource.fileName),
                               KeyValue(key: D.cTitle, value: resource.title),
                               KeyValue(key: D.cSize, value: resource.size),
                               KeyValue(key: D.cCreatedDate, value: resource.createdAt),
                               KeyValue(key: D.cServerId, value: serverId)
            ]
            
            try statementBuilder.insertInto(tableName: D.tResource, keyValue: valuesToAdd)

            return .success(uniqueId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func deleteDownloadedResource(resourceId: String) -> Result <Bool, Error> {
        do {
            let condition = [KeyValue(key: D.cId, value: resourceId)]
            
            try statementBuilder.delete(tableName: D.tResource, primarykeyValue: condition)
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func getResourcesByServerId(serverId: Int) -> Result<[String], Error> {
        do {
            var resourcesId: [String] = []
            let condition = [KeyValue(key: D.cServerId, value: serverId)]
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tResource, andCondition: condition)
            
            responseDict.forEach { dict in
                resourcesId.append(dict[D.cId] as! String)
            }
            
            return .success(resourcesId)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
}
