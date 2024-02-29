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
        
        var resources: [DownloadedResource] = []
        
        do {
            let responseDict = try statementBuilder.selectQuery(tableName: D.tResource)
            
            responseDict.forEach { dict in
                resources.append(getResource(dictionnary: dict))
            }
            
            return resources
        } catch {
            return []
        }
    }
    
    private func getResource(dictionnary: [String: Any]) -> DownloadedResource {
        let id = dictionnary[D.cId] as? String
        let externalId = dictionnary[D.cExternalId] as? String
        let filename = dictionnary[D.cFilename] as? String
        let title = dictionnary[D.cTitle] as? String
        let size = dictionnary[D.cSize] as? String
        let createdAt = dictionnary[D.cCreatedDate] as? String
        let serverId = dictionnary[D.cServerId] as? Int
        
        return DownloadedResource(
            id: id ?? "",
            externalId: externalId ?? "",
            title: title ?? "",
            fileName: filename ?? "",
            size: size ?? "",
            serverId: serverId,
            createdAt: createdAt ?? ""
        )
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
}
