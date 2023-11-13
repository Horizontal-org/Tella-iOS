//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation
import SQLite3
import SQLCipher

class TellaDataBase {
    private var dataBaseHelper : DataBaseHelper
    private(set) var statementBuilder : SQLiteStatementBuilder
    
    init(key: String?) {
        // TODO: inject these thing to the class of that
        dataBaseHelper = DataBaseHelper()
        dataBaseHelper.openDatabases(key: key)
        statementBuilder = SQLiteStatementBuilder(dbPointer: dataBaseHelper.dbPointer)
        checkVersions()
    }
    
    func checkVersions() {
        do {
            let oldVersion = try statementBuilder.getCurrentDatabaseVersion()
            
            switch oldVersion {
            case 0:
                createTables()
               // alterTable()
            case 1:
                alterTable()
                createTables()
            case 2:
                createTemplateTableForUwazi()
                createUwaziServerTable()
            default :
                break
            }
            try statementBuilder.setNewDatabaseVersion(version: D.databaseVersion)
        } catch let error {
            debugLog(error)
        }
    }
    
    func createTables() {
        createServerTable()
        createReportTable()
        createReportFilesTable()
        createLanguageTableForUwazi()
        createTemplateTableForUwazi()
        createUwaziServerTable()
    }
}
