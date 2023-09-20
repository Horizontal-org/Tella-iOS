//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol VaultDataBaseProtocol {
    func createVaultTable()
    func addVaultFile(file : VaultFileDB, parentId: String?)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String, name: String?)
    func moveVaultFile(fileIds: [String], newParentId: String?)
    func deleteVaultFile(ids: [String])
}

protocol DataBase {
    var dataBaseHelper : DataBaseHelper { get }
    var statementBuilder : SQLiteStatementBuilder { get  }
    func checkVersions()
    func createTables()
}

class VaultDatabase : DataBase, VaultDataBaseProtocol {

    var dataBaseHelper: DataBaseHelper
    var statementBuilder: SQLiteStatementBuilder
  
    private var rootId = "11223344-5566-4777-8899-aabbccddeeff";
    
    init(key: String?) {
        dataBaseHelper = DataBaseHelper(key: key, databaseName: VaultD.databaseName)
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
            cddl(VaultD.cDuration, VaultD.real),
            cddl(VaultD.cAnonymous, VaultD.integer, true, 0),
            cddl(VaultD.cSize, VaultD.integer, true, 0)
            // Resolution ?
        ]
        statementBuilder.createTable(tableName: VaultD.tVaultFile, columns: columns)
    }
    
    func addVaultFile(file : VaultFileDB, parentId: String?) {
        
        let parentId = parentId ?? self.rootId
        
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
    
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB] {
        do {
            
            let parentId = parentId ?? self.rootId

            let filterConditions = getFilterConditions(filter: filter, parentId: parentId)
            
            let sortCondition = getSortCondition(fileSortOption: sort)
            
            let vaultFilesDict = try statementBuilder.selectQuery(tableName: VaultD.tVaultFile,
                                                                  equalCondition: filterConditions.equalCondition,
                                                                  differentCondition: filterConditions.differentCondition,
                                                                  inCondition: filterConditions.inCondition,
                                                                  sortCondition: [sortCondition],
                                                                  likeConditions: filterConditions.likeConditions,
                                                                  notLikeConditions: filterConditions.notLikeConditions )
            
            let vaultFiles = vaultFilesDict.compactMap{VaultFileDB.init(dictionnary: $0)}
            return vaultFiles
            
        } catch {
            return []
        }
    }
    
    func getVaultFile(id: String?) -> VaultFileDB? {
        do {
            
            let vaultFilesDict = try statementBuilder.selectQuery(tableName: VaultD.tVaultFile,
                                                                  equalCondition:[KeyValue(key: VaultD.cId, value: id)])
            
            let vaultFile: [VaultFileDB] =  try self.parseDicToObjectOf(type: [VaultFileDB].self, dic: vaultFilesDict)
            return vaultFile.first
            
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        do {
            
            let vaultCondition =  [KeyValues(key: VaultD.cId, value:ids)]
            
            let vaultFilesDict = try statementBuilder.selectQuery(tableName: VaultD.tVaultFile,
                                                                  inCondition: vaultCondition)
            
            let vaultFiles: [VaultFileDB] =  try self.parseDicToObjectOf(type: [VaultFileDB].self, dic: vaultFilesDict)
            return vaultFiles
            
        } catch {
            return []
        }
    }
    
    func getRecentVaultFiles() -> [VaultFileDB] {

        do {

            let sortCondition = SortCondition(column: VaultD.cCreated, sortDirection: SortDirection.desc.rawValue)
            let differentCondition = [KeyValue(key: VaultD.cType,value: VaultFileType.directory.rawValue)]

            let vaultFilesDict = try statementBuilder.selectQuery(tableName: VaultD.tVaultFile,
                                                                  differentCondition: differentCondition,
                                                                  sortCondition: [sortCondition],
                                                                  limit: 10)
            
            let vaultFiles = vaultFilesDict.compactMap{VaultFileDB.init(dictionnary: $0)}
            return vaultFiles
            
        } catch {
            return []
        }

     }
    
    func renameVaultFile(id: String, name: String?) {
        
        do {
            
            let valuesToUpdate = [KeyValue(key: VaultD.cName, value: name)]
            let vaultCondition = [KeyValue(key: VaultD.cId, value: id)]
            
            try statementBuilder.update(tableName: VaultD.tVaultFile,
                                        keyValue: valuesToUpdate,
                                        primarykeyValue: vaultCondition)
            
        } catch let error {
            debugLog(error)
        }
    }
    
    func moveVaultFile(fileIds: [String], newParentId: String?) {
        
        let parentId = newParentId ?? self.rootId

        do {
            
            let valuesToUpdate = [KeyValue(key: VaultD.cParentId, value: parentId)]
//            let vaultCondition = [KeyValue(key: VaultD.cId, value: id)]
            let vaultCondition = fileIds.compactMap({KeyValue(key: VaultD.cId, value: $0) })

            try statementBuilder.update(tableName: VaultD.tVaultFile,
                                        keyValue: valuesToUpdate,
                                        primarykeyValue: vaultCondition)
            
        } catch let error {
            debugLog(error)
        }
    }
    
    func deleteVaultFile(ids: [String]) {
        
        let vaultCondition = [KeyValues(key: VaultD.cId, value: ids)]
        
        statementBuilder.delete(tableName: VaultD.tVaultFile,
                                inCondition: vaultCondition)
        
    }
    
    func getFilterConditions(filter:FilterType?, parentId:String?) -> FilterCondition {
        
        let filterCondition = FilterCondition()
        
        if filter == nil {
            filterCondition.equalCondition = [KeyValue(key: VaultD.cParentId, value: parentId)]
        }
        
        switch filter {
            
        case .audio:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.audio.rawValue)]
            
        case .pdf:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.pdf.rawValue)]
            
        case .video:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.video.rawValue)]
            
        case .photo:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.image.rawValue)]
            
        case .others:
            filterCondition.notLikeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.audio.rawValue),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.video.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.image.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.text.rawValue, sqliteOperator: .and)]
            
        case .audioVideo:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value:  FilterPattern.audio.rawValue),
                                              KeyValue(key: VaultD.cMimeType, value:  FilterPattern.video.rawValue, sqliteOperator: .or)]
            
        case .documents:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.text.rawValue)]
            filterCondition.inCondition = [KeyValues(key: VaultD.cMimeType, value: [FilterPattern.pdf.rawValue,
                                                                                    FilterPattern.word.rawValue,
                                                                                    FilterPattern.excel.rawValue,
                                                                                    FilterPattern.powerPoint.rawValue,
                                                                                    FilterPattern.zip.rawValue],sqliteOperator: .or)]
            
        case .allWithoutDirectory:
            filterCondition.differentCondition = [KeyValue(key: VaultD.cType,value: VaultFileType.directory.rawValue)]
            
        case .photoVideo:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value:  FilterPattern.image.rawValue),
                                              KeyValue(key: VaultD.cMimeType, value:  FilterPattern.video.rawValue, sqliteOperator: .or)]
            
        case .audioPhotoVideo:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value:  FilterPattern.image.rawValue),
                                              KeyValue(key: VaultD.cMimeType, value:  FilterPattern.video.rawValue, sqliteOperator: .or),
                                              KeyValue(key: VaultD.cMimeType, value:  FilterPattern.audio.rawValue, sqliteOperator: .or)]

        default:
            filterCondition.equalCondition = [KeyValue(key: VaultD.cParentId, value: parentId)]
        }
        
        return filterCondition
    }
    
    func getSortCondition(fileSortOption:FileSortOptions?) -> SortCondition {
        
        switch fileSortOption {
            
        case .nameAZ:
            return SortCondition(column: VaultD.cName,sortDirection: SortDirection.asc.rawValue)
            
        case .nameZA:
            return SortCondition(column: VaultD.cName, sortDirection: SortDirection.desc.rawValue)
            
        case .newestToOldest:
            return SortCondition(column: VaultD.cCreated, sortDirection: SortDirection.desc.rawValue)
            
        case .oldestToNewest:
            return SortCondition(column: VaultD.cCreated, sortDirection: SortDirection.asc.rawValue)
            
        default:
            return SortCondition(column: VaultD.cName,sortDirection: SortDirection.asc.rawValue)
        }
    }
}

enum SortDirection : String {
    case asc = "ASC"
    case desc = "DESC"
}

enum FileSortOptions : ActionType {
    case nameAZ
    case nameZA
    case newestToOldest
    case oldestToNewest
}

class FilterCondition {
    
    var equalCondition: [KeyValue] = []
    var differentCondition: [KeyValue] = []
    var inCondition: [KeyValues] = []
    var notInCondition: [KeyValues] = []
    var likeConditions: [KeyValue] = []
    var notLikeConditions: [KeyValue] = []
    
    init() {
        
    }
}

enum FilterPattern :String {
    case audio = "audio/%"
    case video = "video/%"
    case image = "image/%"
    case text = "text/%"
    case pdf = "application/pdf"
    case word = "application/msword"
    case excel = "application/vnd.ms-excel"
    case powerPoint = "application/mspowerpoint"
    case zip = "application/zip"
}
