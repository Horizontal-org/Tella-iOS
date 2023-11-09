//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


protocol VaultDataBaseProtocol {
    func createVaultTable()
    func addVaultFile(file : VaultFileDB, parentId: String?) throws -> Result<Int,Error>
    func getVaultFiles(parentId: String?, filter: FilterType?, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String?, name: String?) -> Result<Bool, Error>
    func moveVaultFile(fileIds: [String], newParentId: String?) -> Result<Bool, Error>
    func deleteVaultFile(ids: [String]) -> Result<Bool, Error>
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
    
    
    init(key: String?) throws {
        dataBaseHelper = try DataBaseHelper(key: key, databaseName: VaultD.databaseName)
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
            cddl(VaultD.cMimeType, VaultD.text),
            cddl(VaultD.cThumbnail, VaultD.blob),
            cddl(VaultD.cName, VaultD.text, true),
            cddl(VaultD.cCreated, VaultD.real, true),
            cddl(VaultD.cDuration, VaultD.real),
            cddl(VaultD.cSize, VaultD.integer, true, 0),
            cddl(VaultD.cWidth, VaultD.real),
            cddl(VaultD.cHeight, VaultD.real)
        ]
        statementBuilder.createTable(tableName: VaultD.tVaultFile, columns: columns)
    }
    
    func addVaultFile(file : VaultFileDB, parentId: String?) -> Result<Int,Error> {
        
        do {
            let parentId = parentId ?? VaultD.rootId
            let defaultThumbnail = "".data(using: .utf8)
            
            let valuesToAdd = [KeyValue(key: VaultD.cId, value: file.id),
                               KeyValue(key: VaultD.cParentId, value: parentId),
                               KeyValue(key: VaultD.cType, value: file.type.rawValue),
                               KeyValue(key: VaultD.cMimeType, value: file.mimeType),
                               KeyValue(key: VaultD.cThumbnail, value: file.thumbnail ?? defaultThumbnail),
                               KeyValue(key: VaultD.cName, value:file.name),
                               KeyValue(key: VaultD.cCreated, value:Date().getDateDouble()),
                               KeyValue(key: VaultD.cDuration, value:file.duration),
                               KeyValue(key: VaultD.cSize, value:file.size),
                               KeyValue(key: VaultD.cWidth, value:file.width),
                               KeyValue(key: VaultD.cHeight, value:file.height)
            ]
            
            let id = try statementBuilder.insertInto(tableName: VaultD.tVaultFile,
                                                     keyValue: valuesToAdd)
            
            return .success(id)
        } catch let error {
            debugLog(error)
            return .failure(error)
        }
    }
    
    func getVaultFiles(parentId: String?, filter: FilterType?, sort: FileSortOptions?) -> [VaultFileDB] {
        do {
            
            let parentId = parentId ?? VaultD.rootId
            
            let filterConditions = getFilterConditions(filter: filter, parentId: parentId)
            
            let sortCondition = getSortCondition(fileSortOption: sort)
            
            let vaultFilesDict = try statementBuilder.getSelectQuery(tableName: VaultD.tVaultFile,
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
            
            let vaultFilesDict = try statementBuilder.getSelectQuery(tableName: VaultD.tVaultFile,
                                                                     equalCondition:[KeyValue(key: VaultD.cId, value: id)])
            let vaultFiles = vaultFilesDict.compactMap{VaultFileDB.init(dictionnary: $0)}
            
            return vaultFiles.first
            
        } catch let error {
            debugLog(error)
            return nil
        }
    }
    
    func getVaultFiles(ids: [String]) -> [VaultFileDB] {
        do {
            
            let vaultCondition =  [KeyValues(key: VaultD.cId, value:ids)]
            
            let vaultFilesDict = try statementBuilder.getSelectQuery(tableName: VaultD.tVaultFile,
                                                                     inCondition: vaultCondition)
            let vaultFiles = vaultFilesDict.compactMap{VaultFileDB.init(dictionnary: $0)}
            return vaultFiles
            
        } catch {
            return []
        }
    }
    
    func getRecentVaultFiles() -> [VaultFileDB] {
        
        do {
            
            let sortCondition = SortCondition(column: VaultD.cCreated, sortDirection: SortDirection.desc.rawValue)
            let equalCondition = [KeyValue(key: VaultD.cType,value: VaultFileType.file.rawValue)]
            
            let vaultFilesDict = try statementBuilder.getSelectQuery(tableName: VaultD.tVaultFile,
                                                                     equalCondition: equalCondition,
                                                                     sortCondition: [sortCondition],
                                                                     limit: 10)
            
            let vaultFiles = vaultFilesDict.compactMap{VaultFileDB.init(dictionnary: $0)}
            return vaultFiles
            
        } catch {
            return []
        }
        
    }
    
    func renameVaultFile(id: String?, name: String?) -> Result<Bool, Error> {
        
        do {
            
            let valuesToUpdate = [KeyValue(key: VaultD.cName, value: name)]
            let vaultCondition = [KeyValue(key: VaultD.cId, value: id)]
            
            try statementBuilder.update(tableName: VaultD.tVaultFile,
                                        keyValue: valuesToUpdate,
                                        primarykeyValue: vaultCondition)
            return .success(true)
        } catch let error {
            debugLog(error)
            return .failure(error)
            
        }
    }
    
    func moveVaultFile(fileIds: [String], newParentId: String?) -> Result<Bool, Error> {
        
        let parentId = newParentId ?? VaultD.rootId
        
        do {
            
            let valuesToUpdate = [KeyValue(key: VaultD.cParentId, value: parentId)]
            //            let vaultCondition = [KeyValue(key: VaultD.cId, value: id)]
            let vaultCondition = fileIds.compactMap({KeyValue(key: VaultD.cId, value: $0) })
            
            try statementBuilder.update(tableName: VaultD.tVaultFile,
                                        keyValue: valuesToUpdate,
                                        primarykeyValue: vaultCondition)
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
            
        }
    }
    
    func deleteVaultFile(ids: [String]) -> Result<Bool, Error> {
        do {
            
            let vaultCondition = [KeyValues(key: VaultD.cId, value: ids)]
            
            try statementBuilder.delete(tableName: VaultD.tVaultFile,
                                        inCondition: vaultCondition)
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
            
        }
    }
    
    func deleteAllVaultFiles() -> Result<Bool, Error> {
        do {
            try statementBuilder.deleteAll(tableNames: [VaultD.tVaultFile])
            return .success(true)
            
        } catch let error {
            debugLog(error)
            return .failure(error)
            
        }
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
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.text.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.pdf.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.word.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.excel.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.powerPoint.rawValue, sqliteOperator: .and),
                                                 KeyValue(key: VaultD.cMimeType, value: FilterPattern.pages.rawValue, sqliteOperator: .and)]
            
        case .audioVideo:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value:  FilterPattern.audio.rawValue),
                                              KeyValue(key: VaultD.cMimeType, value:  FilterPattern.video.rawValue, sqliteOperator: .or)]
            
        case .documents:
            filterCondition.likeConditions = [KeyValue(key: VaultD.cMimeType, value: FilterPattern.text.rawValue, sqliteOperator: .or)]
            filterCondition.inCondition = [KeyValues(key: VaultD.cMimeType, value: [FilterPattern.pdf.rawValue,
                                                                                    FilterPattern.word.rawValue,
                                                                                    FilterPattern.excel.rawValue,
                                                                                    FilterPattern.powerPoint.rawValue,
                                                                                    FilterPattern.pages.rawValue,
                                                                                    FilterPattern.zip.rawValue])]
            
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
    case asc = "asc"
    case desc = "desc"
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
    case word = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case powerPoint = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case excel = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case pages = "application/x-iwork-pages-sffpages"
    case zip = "application/zip"
}
