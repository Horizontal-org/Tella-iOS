//
//  NextcloudDatabase.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    
    func createNextcloudServerTable() {
        let columns = [ cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
                        cddl(D.cName, D.text),
                        cddl(D.cURL, D.text),
                        cddl(D.cUsername, D.text),
                        cddl(D.cPassword, D.text),
                        cddl(D.cUserId, D.text),
                        cddl(D.cRootFolder, D.text)]
        
        statementBuilder.createTable(tableName: D.tNextcloudServer, columns: columns)
    }
    
    func addNextcloudServer(server: NextcloudServer) -> Int? {
        do {
            
            let nextcloudServerDictionnary = server.dictionary
            let valuesToAdd = nextcloudServerDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let serverId = try statementBuilder.insertInto(tableName: D.tNextcloudServer, keyValue: valuesToAdd)
            return serverId
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func updateNextcloudServer(server: NextcloudServer) -> Int? {
        do {
            
            let nextcloudServerDictionnary = server.dictionary
            let valuesToUpdate = nextcloudServerDictionnary.compactMap({KeyValue(key: $0.key, value: $0.value)})
            
            let serverCondition = [KeyValue(key: D.cId, value: server.id)]
            return try statementBuilder.update(tableName: D.tNextcloudServer,
                                               valuesToUpdate: valuesToUpdate,
                                               equalCondition: serverCondition)
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getNextcloudServer() -> [NextcloudServer] {
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tNextcloudServer)
            let server = try serversDict.decode(NextcloudServer.self)
            return server
        } catch {
            debugLog("Error while fetching servers from \(D.tNextcloudServer): \(error)")
            return []
        }
    }
    
    func deleteNextcloudServer(serverId: Int) -> Bool {
        do {
            try statementBuilder.delete(tableName: D.tNextcloudServer,
                                        primarykeyValue: [KeyValue(key: D.cId, value: serverId)])
            return true
        } catch let error {
            debugLog(error)
            return false
        }
    }
}
