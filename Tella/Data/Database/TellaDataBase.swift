//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3
import SQLCipher


protocol UwaziServerLanguageProtocol {
    func createLanguageTableForUwazi()
    func addUwaziLocaleWith(locale: UwaziLocale) throws -> Int
    func getUwaziLocaleWith(serverId: Int) throws -> UwaziLocale?
    func getAllUwaziLocale() throws -> [UwaziLocale]
    func deleteUwaziLocaleWith(serverId : Int) throws
    func deleteAllUwaziLocale() throws -> Int
}

class TellaDataBase: UwaziServerLanguageProtocol {
    
    private var dataBaseHelper : DataBaseHelper
    private var statementBuilder : SQLiteStatementBuilder
    
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
    }
    func alterTable() {
        let column = cddl(D.cServerType,D.integer, true, ServerConnectionType.tella.rawValue)
        statementBuilder.alterTable(tableName: D.tServer, column: column)
    }

    func createServerTable() {
        // c_id | c_name | c_url | c_username | c_password | cAccessToken | cActivatedMetadata | cBackgroundUpload
        let columns = [
            cddl(D.cServerId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cName, D.text),
            cddl(D.cURL, D.text),
            cddl(D.cUsername, D.text),
            cddl(D.cPassword, D.text),
            cddl(D.cAccessToken, D.text),
            cddl(D.cActivatedMetadata, D.integer),
            cddl(D.cBackgroundUpload, D.integer),
            cddl(D.cApiProjectId, D.text),
            cddl(D.cSlug, D.text),
            cddl(D.cAutoUpload, D.integer),
            cddl(D.cAutoDelete, D.integer),
            cddl(D.cServerType, D.integer)
        ]
        statementBuilder.createTable(tableName: D.tServer, columns: columns)
    }

    
    func createReportTable() {
        // c_id | c_title | c_description | c_date | cStatus | c_server_id
        let columns = [
            cddl(D.cReportId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cApiReportId, D.text),
            cddl(D.cTitle, D.text),
            cddl(D.cDescription, D.text),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cStatus, D.integer),
            cddl(D.cCurrentUpload, D.integer),
            cddl(D.cServerId, D.integer, tableName: D.tServer, referenceKey: D.cServerId)
        ]
        statementBuilder.createTable(tableName: D.tReport, columns: columns)
    }
    
    func createReportFilesTable() {
        
        let columns = [
            cddl(D.cId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cVaultFileInstanceId, D.text),
            cddl(D.cStatus, D.integer),
            cddl(D.cBytesSent, D.integer),
            cddl(D.cCreatedDate, D.float),
            cddl(D.cUpdatedDate, D.float),
            cddl(D.cReportInstanceId, D.integer, tableName: D.tReport, referenceKey: D.cReportId)
            
        ]
        statementBuilder.createTable(tableName: D.tReportInstanceVaultFile, columns: columns)
        
    }
    
    func addServer(server : Server) throws -> Int {
        let valuesToAdd = [KeyValue(key: D.cName, value: server.name),
                           KeyValue(key: D.cURL, value: server.url),
                           KeyValue(key: D.cUsername, value: server.username),
                           KeyValue(key: D.cPassword, value: server.password ),
                           KeyValue(key: D.cAccessToken, value: server.accessToken),
                           KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                           KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1),
                           KeyValue(key: D.cApiProjectId, value: server.projectId),
                           KeyValue(key: D.cSlug, value: server.slug),
                           KeyValue(key: D.cAutoUpload, value:server.autoUpload == false ? 0 : 1),
                           KeyValue(key: D.cAutoDelete, value:server.autoDelete == false ? 0 : 1),
                           KeyValue(key: D.cServerType, value:server.serverType)
        ]
        return try statementBuilder.insertInto(tableName: D.tServer,
                                               keyValue: valuesToAdd)
    }


    
    func getServer() -> [Server] {
        var servers : [Server] = []
        do {
            let serversDict = try statementBuilder.selectQuery(tableName: D.tServer, andCondition: [])
            
            serversDict.forEach { dict in
                servers.append(getServer(dictionnary: dict))
            }
            
            return servers
            
        } catch {
            return []
        }
    }
    
    func getAutoUploadServer() -> Server? {
        
        do {
            let serverCondition = [KeyValue(key: D.cAutoUpload, value: 1)]
            let serversDict = try statementBuilder.selectQuery(tableName: D.tServer,
                                                               andCondition:serverCondition )
            
            if !serversDict.isEmpty, let dict = serversDict.first {
                return getServer(dictionnary: dict)
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func updateServer(server : Server) throws -> Int {
        let valuesToUpdate = [KeyValue(key: D.cName, value: server.name),
                              KeyValue(key: D.cURL, value: server.url),
                              KeyValue(key: D.cUsername, value: server.username),
                              KeyValue(key: D.cPassword, value: server.password),
                              KeyValue(key: D.cAccessToken, value: server.accessToken),
                              KeyValue(key: D.cActivatedMetadata, value: server.activatedMetadata == false ? 0 : 1),
                              KeyValue(key: D.cBackgroundUpload, value: server.backgroundUpload == false ? 0 : 1),
                              KeyValue(key: D.cApiProjectId, value: server.projectId),
                              KeyValue(key: D.cSlug, value: server.slug),
                              KeyValue(key: D.cAutoUpload, value:server.autoUpload == false ? 0 : 1 ),
                              KeyValue(key: D.cAutoDelete, value:server.autoDelete == false ? 0 : 1 )]
        
        let serverCondition = [KeyValue(key: D.cServerId, value: server.id)]
        return try statementBuilder.update(tableName: D.tServer,
                                           keyValue: valuesToUpdate,
                                           primarykeyValue: serverCondition)
    }
    
    func deleteServer(serverId : Int) throws {
        
        var reportIDs : [Int] = []
        let serverCondition = [KeyValue(key: D.cServerId, value: serverId)]
        do {
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: serverCondition)
            
            responseDict.forEach { dict in
                if let id = dict[D.cReportId] as? Int {
                    reportIDs.append(id)
                }
            }
        } catch {
            
        }
        
        try statementBuilder.delete(tableName: D.tServer,
                                    primarykeyValue: serverCondition)
        
        try statementBuilder.delete(tableName: D.tReport,
                                    primarykeyValue: serverCondition)
        
        if !reportIDs.isEmpty {
            let reportCondition = [KeyValues(key: D.cReportInstanceId, value: reportIDs)]
            try statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                        inCondition: reportCondition)
        }
        
    }
    
    func deleteAllServers() throws -> Int {
        return try statementBuilder.deleteAll(tableNames: [D.tServer, D.tReport, D.tReportInstanceVaultFile, D.tUwaziServerLanguage])
    }

    func getReports(reportStatus:[ReportStatus]) -> [Report] {
        
        var reports : [Report] = []
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            
            //            let statusArray = reportStatus.compactMap{KeyValue(key: D.cStatus, value: $0.rawValue) }
            let statusArray = reportStatus.compactMap{ $0.rawValue }
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                inCondition: [KeyValues(key:D.cStatus, value: statusArray )],
                                                                joinCondition: joinCondition)
            
            responseDict.forEach { dict in
                reports.append(getReport(dictionnary: dict))
            }
            
            return reports
            
        } catch {
            return []
        }
    }
    
    func getReport(reportId:Int) -> Report? {
        
        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            let reportCondition = [KeyValue(key: D.cReportId, value: reportId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: reportCondition,
                                                                joinCondition: joinCondition)
            if !responseDict.isEmpty, let dict = responseDict.first  {
                return  getReport(dictionnary: dict)
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func getCurrentReport() -> Report? {
        
        do {
            
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
            let reportCondition = [KeyValue(key: D.cCurrentUpload, value: 1)]
            
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                                andCondition: reportCondition,
                                                                joinCondition: joinCondition)
            
            if !responseDict.isEmpty, let dict = responseDict.first  {
                
                let reportID = dict[D.cReportId] as? Int
                
                let files = getVaultFiles(reportID: reportID)
                
                let filteredFile = files.filter{(Date().timeIntervalSince($0.updatedDate ?? Date())) < 1800 }

                if !filteredFile.isEmpty {
                    return getReport(dictionnary: dict)
                }
                
            }
            
            return nil
        } catch {
            return nil
        }
    }
    
    func getVaultFile(reportFileId:Int) -> ReportFile? {
        do {
            
            let reportFileCondition = [KeyValue(key: D.cId, value: reportFileId)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                                andCondition: reportFileCondition)
            
            if !responseDict.isEmpty, let dict = responseDict.first {
                let id = dict[D.cId] as? Int
                let vaultFileId = dict[D.cVaultFileInstanceId] as? String
                let status = dict[D.cStatus] as? Int
                let bytesSent = dict[D.cBytesSent] as? Int
                let createdDate = dict[D.cCreatedDate] as? Double
                let updatedDate = dict[D.cUpdatedDate] as? Double
                
                return  ReportFile(id: id,
                                   fileId: vaultFileId,
                                   status: FileStatus(rawValue: status ?? 0),
                                   bytesSent: bytesSent,
                                   createdDate: createdDate?.getDate(),
                                   updatedDate: updatedDate?.getDate())
                
            }
            return nil
            
        } catch {
            return nil
        }
        
    }
    
    func getVaultFiles(reportID:Int?) -> [ReportFile] {
        
        var reportFiles : [ReportFile] = []
        
        do {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: reportID)]
            let responseDict = try statementBuilder.selectQuery(tableName: D.tReportInstanceVaultFile,
                                                                andCondition: reportFilesCondition)
            
            responseDict.forEach { dict in
                let id = dict[D.cId] as? Int
                let vaultFileId = dict[D.cVaultFileInstanceId] as? String
                let status = dict[D.cStatus] as? Int
                let bytesSent = dict[D.cBytesSent] as? Int
                let createdDate = dict[D.cCreatedDate] as? Double
                let updatedDate = dict[D.cUpdatedDate] as? Double
                
                let reportFile =  ReportFile(id: id,
                                             fileId: vaultFileId,
                                             status: FileStatus(rawValue: status ?? 0),
                                             bytesSent: bytesSent,
                                             createdDate: createdDate?.getDate(),
                                             updatedDate: updatedDate?.getDate())
                reportFiles.append(reportFile)
            }
            return reportFiles
            
        } catch {
            return []
        }
        
    }
    
    func addReport(report : Report) throws -> Int {
        let currentUpload = ((report.currentUpload == false) || (report.currentUpload == nil)) ? 0 : 1
        
        let reportValuesToAdd = [KeyValue(key: D.cTitle, value: report.title),
                                 KeyValue(key: D.cDescription, value: report.description),
                                 KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                 KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                                 KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                 KeyValue(key: D.cServerId, value: report.server?.id),
                                 KeyValue(key: D.cCurrentUpload, value:currentUpload )]
        
        let reportId = try statementBuilder.insertInto(tableName: D.tReport,
                                                       keyValue:reportValuesToAdd)
        
        try report.reportFiles?.forEach({ reportFile in
            
            let reportFileValuesToAdd = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                         KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                         KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                         KeyValue(key: D.cBytesSent, value: 0),
                                         KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                         KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
            
            try statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                            keyValue: reportFileValuesToAdd)
            
            
        })
        return reportId
    }
    
    func updateReport(report : Report) throws -> Report? {
        
        var keyValueArray : [KeyValue]  = []
        
        if let title = report.title {
            keyValueArray.append(KeyValue(key: D.cTitle, value: title))
        }
        
        if let description = report.description {
            keyValueArray.append(KeyValue(key: D.cDescription, value: description))
        }
        
        keyValueArray.append(KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()))
        
        if let status = report.status {
            keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
        }
        
        if let serverId = report.server?.id {
            keyValueArray.append(KeyValue(key: D.cServerId, value: serverId))
        }
        
        if let apiID = report.apiID {
            keyValueArray.append(KeyValue(key: D.cApiReportId, value: apiID))
        }
        
        
        if let currentUpload = report.currentUpload {
            keyValueArray.append(KeyValue(key: D.cCurrentUpload, value: currentUpload == false ? 0 : 1))
        }
        
        let reportCondition = [KeyValue(key: D.cReportId, value: report.id)]
        try statementBuilder.update(tableName: D.tReport,
                                    keyValue: keyValueArray,
                                    primarykeyValue: reportCondition)
        
        if let files = report.reportFiles {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: report.id as Any)]
            
            try statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                        primarykeyValue:reportFilesCondition )
            
            try files.forEach({ reportFile in
                let reportFileValuesToAdd = [
                    
                    reportFile.id == nil ? nil : KeyValue(key: D.cId, value: reportFile.id),
                    KeyValue(key: D.cReportInstanceId, value: report.id),
                    KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                    KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                    KeyValue(key: D.cBytesSent, value: reportFile.bytesSent),
                    KeyValue(key: D.cCreatedDate, value: reportFile.createdDate),
                    KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
                
                try statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                                keyValue: reportFileValuesToAdd)
            })
        }
        
        guard let reportId = report.id else { return nil }
        return getReport(reportId: reportId)
    }
    
    func updateReportStatus(idReport : Int, status: ReportStatus, date: Date) throws -> Int {
        
        let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                              KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
        let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]
        
        return try statementBuilder.update(tableName: D.tReport,
                                           keyValue: valuesToUpdate,
                                           primarykeyValue: reportCondition)
    }
    
    @discardableResult
    func resetCurrentUploadReport() throws -> Int {
        let reportCondition = [KeyValue(key: D.cCurrentUpload, value: 1)]
        let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                            andCondition: reportCondition )
        
        if !responseDict.isEmpty, let dict = responseDict.first  {
            let reportID = dict[D.cReportId] as? Int
            let valuesToUpdate = [KeyValue(key: D.cCurrentUpload, value: 0),
                                  KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
            let reportCondition = [KeyValue(key: D.cReportId, value: reportID)]
            
            return try statementBuilder.update(tableName: D.tReport,
                                               keyValue: valuesToUpdate,
                                               primarykeyValue:reportCondition)
        }
        return 0
    }
    
    @discardableResult
    func updateReportFile(reportFile:ReportFile) throws -> Int {
        
        var keyValueArray : [KeyValue]  = []
        
        if let status = reportFile.status {
            keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
        }
        
        if let bytesSent = reportFile.bytesSent {
            keyValueArray.append(KeyValue(key: D.cBytesSent, value: bytesSent))
        }
        
        keyValueArray.append(KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()))
        
        let primarykey = [KeyValue(key: D.cId, value: reportFile.id)]
        return try statementBuilder.update(tableName: D.tReportInstanceVaultFile,
                                           keyValue: keyValueArray,
                                           primarykeyValue: primarykey)
    }
    
    func addReportFile(fileId:String?, reportId:Int) throws -> Int {
        let reportFileValues = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                KeyValue(key: D.cVaultFileInstanceId, value: fileId),
                                KeyValue(key: D.cStatus, value: FileStatus.notSubmitted.rawValue),
                                KeyValue(key: D.cBytesSent, value: 0),
                                KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
        
        
        return  try statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                                keyValue: reportFileValues)
    }
    
    func deleteReport(reportId : Int?) {
        
        guard let reportId, let report = self.getReport(reportId: reportId) else { return }
        
        deleteReportFiles(reportIds: [reportId])
        
        let reportCondition = [KeyValue(key: D.cReportId, value: report.id as Any)]
        
        statementBuilder.delete(tableName: D.tReport,
                                primarykeyValue: reportCondition)
    }
    
    func deleteSubmittedReport() {
        
        let submittedReports = self.getReports(reportStatus: [.submitted])
        let reportIds = submittedReports.compactMap{$0.id}
        
        deleteReportFiles(reportIds: reportIds)
        
        let reportCondition = [KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
        
        statementBuilder.delete(tableName: D.tReport,
                                primarykeyValue: reportCondition)
    }
    // MARK: CRUD operation for Language table for Uwazu
    // TODO: Add these thing to a new class and set a protocol for abstraction
    func createLanguageTableForUwazi() {
        let columns = [
            cddl(D.cLocaleId, D.integer, primaryKey: true, autoIncrement: true),
            cddl(D.cServerId, D.integer),
            cddl(D.cLocale, D.text),
        ]
        statementBuilder.createTable(tableName: D.tUwaziServerLanguage, columns: columns)
    }

    func addUwaziLocaleWith(locale: UwaziLocale) throws -> Int {
        return try statementBuilder.insertInto(tableName: D.tUwaziServerLanguage, keyValue: [
            KeyValue(key: D.cLocale, value: locale.locale),
            KeyValue(key: D.cServerId, value: locale.serverId),
        ])
    }

    func updateLocale(localeId: Int, locale: String) throws -> Int {

        let valuesToUpdate = [KeyValue(key: D.cLocale, value: locale)]

        let serverCondition = [KeyValue(key: D.cLocaleId, value: localeId)]
        return try statementBuilder.update(tableName: D.tUwaziServerLanguage,
                                           keyValue: valuesToUpdate,
                                           primarykeyValue: serverCondition)
    }
    func getUwaziLocaleWith(serverId: Int) throws -> UwaziLocale? {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziServerLanguage,
                                                         andCondition: [KeyValue(key: D.cServerId, value: serverId)])
        guard let locale = serversDict.first else { return nil }
        return try self.parseDicToObjectOf(type: UwaziLocale.self, dic: locale)
    }
    func getAllUwaziLocale() throws -> [UwaziLocale] {
        let serversDict = try statementBuilder.selectQuery(tableName: D.tUwaziServerLanguage,
                                                         andCondition: [])
        if !serversDict.isEmpty {
            return try self.parseDicToObjectOf(type: [UwaziLocale].self, dic: serversDict)
        }
        return []
    }

    func deleteUwaziLocaleWith(serverId : Int) throws {
        statementBuilder.delete(tableName: D.tUwaziServerLanguage,
                                         primarykeyValue: [KeyValue(key: D.cServerId, value: serverId)])
    }

    func deleteAllUwaziLocale() throws -> Int {
        return try statementBuilder.deleteAll(tableNames: [D.tUwaziServerLanguage])
    }
    func deleteReportFiles(reportIds:[Int]) {
        let reportCondition = [KeyValues(key: D.cReportInstanceId, value: reportIds)]
        statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                inCondition: reportCondition)
    }

    private func getServer(dictionnary : [String:Any] ) -> Server {
        let id = dictionnary[D.cServerId] as? Int
        let name = dictionnary[D.cName] as? String
        let url = dictionnary[D.cURL] as? String
        let username = dictionnary[D.cUsername] as? String
        let password = dictionnary[D.cPassword] as? String
        let token = dictionnary[D.cAccessToken] as? String
        let activatedMetadata = dictionnary[D.cActivatedMetadata] as? Int
        let backgroundUpload = dictionnary[D.cBackgroundUpload] as? Int
        let apiProjectId = dictionnary[D.cApiProjectId] as? String
        let slug = dictionnary[D.cSlug] as? String
        let autoUpload = dictionnary[D.cAutoUpload] as? Int
        let autoDelete = dictionnary[D.cAutoDelete] as? Int
        let servertType = dictionnary[D.cServerType] as? Int
        return Server(id:id,
                      name: name,
                      serverURL: url,
                      username: username,
                      password: password,
                      accessToken: token,
                      activatedMetadata: activatedMetadata == 0 ? false : true ,
                      backgroundUpload: backgroundUpload == 0 ? false : true,
                      projectId: apiProjectId,
                      slug:slug,
                      autoUpload: autoUpload == 0 ? false : true,
                      autoDelete: autoDelete == 0 ? false : true,
                      serverType: ServerConnectionType(rawValue: servertType ?? 1)
        )
    }

    private func getReport(dictionnary : [String:Any] ) -> Report {
        let reportID = dictionnary[D.cReportId] as? Int
        let title = dictionnary[D.cTitle] as? String
        let description = dictionnary[D.cDescription] as? String
        let createdDate = dictionnary[D.cCreatedDate] as? Double
        let updatedDate = dictionnary[D.cUpdatedDate] as? Double
        let status = dictionnary[D.cStatus] as? Int
        let apiReportId = dictionnary[D.cApiReportId] as? String
        let currentUpload = dictionnary[D.cCurrentUpload] as? Int
        return Report(id: reportID,
                      title: title ?? "",
                      description: description ?? "",
                      createdDate: createdDate?.getDate() ?? Date(),
                      updatedDate: updatedDate?.getDate() ?? Date(),
                      status: ReportStatus(rawValue: status ?? 0) ?? .draft,
                      server: getServer(dictionnary: dictionnary),
                      vaultFiles: getVaultFiles(reportID: reportID),
                      apiID: apiReportId,
                      currentUpload: currentUpload == 0 ? false : true)
    }
}
extension TellaDataBase {
    func parseDicToObjectOf<T:Codable>(type: T.Type, dic: Any) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dic)
        let decodedValues = try JSONDecoder().decode(T.self, from: data)
        return decodedValues
    }
}

