//
//  GDriveDatabase.swift
//  Tella
//
//  Created by gus valbuena on 5/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    
    func createGDriveServerTable() {
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cRootFolder, D.text)
        ]
        statementBuilder.createTable(tableName: D.tGDriveServer, columns: columns)
    }
    
    func addGDriveServer(gDriveServer: GDriveServer) -> Result<Int, Error> {
        do {
            let valuesToAdd = [KeyValue(key: D.cName, value: gDriveServer.name),
                               KeyValue(key: D.cRootFolder, value: gDriveServer.rootFolder)
            ]
            
            let serverId = try statementBuilder.insertInto(tableName: D.tGDriveServer, keyValue: valuesToAdd)
            return .success(serverId)
        } catch let error {
            return .failure(error)
        }
    }
    
    func getDriveServers() -> [GDriveServer] {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tGDriveServer, andCondition: [])
            
            let driveServer = try serversDict.decode(GDriveServer.self)            
            return driveServer
        } catch {
            debugLog("Error while fetching servers from \(D.tGDriveServer): \(error)")
            return []
        }
    }
    
    func deleteGDriveServer(serverId: Int) {
        do {
            try statementBuilder.delete(tableName: D.tGDriveServer,
                                        primarykeyValue: [KeyValue(key: D.cId, value: serverId)])
        } catch let error {
            debugLog(error)
        }
    }
    
}
