//
//  TellaUwaziLanguageDatabase.swift
//  Tella
//
//  Created by Robert Shrestha on 9/14/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
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
