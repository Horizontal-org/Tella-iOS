//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol VaultDataBaseProtocol {
    func createVaultTable()
    func addVaultFile(file : VaultFileDB, parentId: String)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: Sort?) -> [VaultFileDB]
    func getVaultFile(id: String) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func renameVaultFile(id: String, name: String?)
    func moveVaultFile(id: String, newParentId: String)
    func deleteVaultFile(fileId: String)
}

protocol DataBase {
    var dataBaseHelper : DataBaseHelper { get }
    var statementBuilder : SQLiteStatementBuilder { get  }
}

class VaultDataBase : DataBase, VaultDataBaseProtocol {
    
    internal var dataBaseHelper: DataBaseHelper
    internal var statementBuilder: SQLiteStatementBuilder
    
    init(key: String?) {
        dataBaseHelper = DataBaseHelper()
        dataBaseHelper.openDatabases(key: key, databaseName: VaultD.databaseName)
        statementBuilder = SQLiteStatementBuilder(dbPointer: dataBaseHelper.dbPointer)
        checkVersions()
    }
    
    func checkVersions() {
        do {
            let oldVersion = try statementBuilder.getCurrentDatabaseVersion()
            
            switch oldVersion {
            case 0:
                createTables()
                
            default :
                break
            }
            
            try statementBuilder.setNewDatabaseVersion(version: VaultD.databaseVersion)
            
        } catch let error {
            debugLog(error)
        }
    }
    
    func createTables() {
        createVaultTable()
    }
    
    func createVaultTable() {
        
        let columns = [
            cddl(VaultD.cId, VaultD.text, primaryKey: true, autoIncrement: false),
            cddl(VaultD.cParentId, VaultD.text),
            cddl(VaultD.cType, VaultD.integer, true),
            cddl(VaultD.cHash, VaultD.text), //?
            cddl(VaultD.cMetadata, VaultD.text),
            cddl(VaultD.cMimeType, VaultD.text),
            cddl(VaultD.cThumbnail, VaultD.blob),
            cddl(VaultD.cName, VaultD.text, true),
            cddl(VaultD.cCreated, VaultD.real, true),
            cddl(VaultD.cDuration, VaultD.real, true, 0),
            cddl(VaultD.cAnonymous, VaultD.integer, true, 0),
            cddl(VaultD.cSize, VaultD.integer, true, 0)
            // Resolution ?
        ]
        statementBuilder.createTable(tableName: VaultD.tVaultFile, columns: columns)
    }
    
    func addVaultFile(file : VaultFileDB, parentId: String) {
        
        let valuesToAdd = [KeyValue(key: VaultD.cId, value: file.id),
                           KeyValue(key: VaultD.cParentId, value: parentId),
                           KeyValue(key: VaultD.cType, value: file.type.rawValue),
                           KeyValue(key: VaultD.cHash, value: file.hash), // why signature of file
                           KeyValue(key: VaultD.cMetadata, value: file.metadata ), // Json
                           KeyValue(key: VaultD.cMimeType, value: file.mimeType),
                           KeyValue(key: VaultD.cThumbnail, value: file.thumbnail),
                           KeyValue(key: VaultD.cName, value:file.name),
                           KeyValue(key: VaultD.cCreated, value:Date().getDateDouble()),
                           KeyValue(key: VaultD.cDuration, value:file.duration),
                           KeyValue(key: VaultD.cSize, value:file.size)
        ]
        
        do {
            try statementBuilder.insertInto(tableName: VaultD.tVaultFile,
                                            keyValue: valuesToAdd)
            
        } catch let error {
            debugLog(error)
        }
        
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: Sort?) -> [VaultFileDB] {
        do {
            let vaultFilesDict = try statementBuilder.selectQuery(tableName: VaultD.tVaultFile) // filter ? sort ?
            let vaultFiles: [VaultFileDB] =  try self.parseDicToObjectOf(type: [VaultFileDB].self, dic: vaultFilesDict)
            return vaultFiles
            
        } catch {
            return []
        }
    }
    
    func getVaultFile(id: String) -> VaultFileDB? {
        return nil
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        do {
            let vaultFilesDict = try statementBuilder.selectQuery(tableName: VaultD.tVaultFile) // filter ? sort ?
            let vaultFiles: [VaultFileDB] =  try self.parseDicToObjectOf(type: [VaultFileDB].self, dic: vaultFilesDict)
            return vaultFiles
            
        } catch {
            return []
        }
    }
    
    
    func renameVaultFile(id: String, name: String?) {
        
    }
    
    func moveVaultFile(id: String, newParentId: String) {
        
    }
    
    func deleteVaultFile(fileId: String) {
        // database.setTransactionSuccessful()
    }
    
}



