//
//  DropboxDatabase.swift
//  Tella
//
//  Created by gus valbuena on 9/9/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    func createDropboxServerTable() {
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text)
        ]
        
        statementBuilder.createTable(tableName: D.tDropboxServer, columns: columns)
    }
    
    func addDropboxServer(dropboxServer: DropboxServer) -> Result<Int, Error>{
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: dropboxServer.name)]
            
            let serverId = try statementBuilder.insertInto(tableName: D.tDropboxServer, keyValue: valuesToAdd)
            return .success(serverId)
        } catch let error {
            debugLog(error)
            return .failure(RuntimeError(LocalizableCommon.commonError.localized))
        }
    }
    
    func getDropboxServers() -> [DropboxServer] {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tDropboxServer, andCondition: [])
            
            let dropboxServer = try serversDict.decode(DropboxServer.self)

            return dropboxServer
        } catch let error {
            debugLog("Error while fetching servers from \(D.tDropboxServer): \(error)")
            return []
        }
    }
    
    func deleteDroboxServer(serverId: Int) {
        do {
            try statementBuilder.delete(tableName: D.tDropboxServer,
                                        primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
        } catch let error {
            debugLog(error)
        }
    }
}
