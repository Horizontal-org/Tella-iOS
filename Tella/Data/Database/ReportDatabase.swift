//
//  UwaziReportDatabase.swift
//  Tella
//
//  Created by Robert Shrestha on 9/14/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaDataBase {
    func createReportTable() {
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


    func getReports(reportStatus:[ReportStatus]) -> [Report] {

        var reports : [Report] = []

        do {
            let joinCondition = [JoinCondition(tableName: D.tServer,
                                               firstItem: JoinItem(tableName: D.tReport, columnName: D.cServerId),
                                               secondItem: JoinItem(tableName: D.tServer, columnName: D.cServerId))]
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

    func addReport(report : Report) -> Int? {
        let currentUpload = ((report.currentUpload == false) || (report.currentUpload == nil)) ? 0 : 1

        let reportValuesToAdd = [KeyValue(key: D.cTitle, value: report.title),
                                 KeyValue(key: D.cDescription, value: report.description),
                                 KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                 KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()),
                                 KeyValue(key: D.cStatus, value: report.status?.rawValue),
                                 KeyValue(key: D.cServerId, value: report.server?.id),
                                 KeyValue(key: D.cCurrentUpload, value:currentUpload )]

        guard let reportId = statementBuilder.insertInto(tableName: D.tReport,
                                                         keyValue:reportValuesToAdd) else { return nil }

        report.reportFiles?.forEach({ reportFile in

            let reportFileValuesToAdd = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                         KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                                         KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                                         KeyValue(key: D.cBytesSent, value: 0),
                                         KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                         KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]

            statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                        keyValue: reportFileValuesToAdd)


        })
        return reportId
    }

    func updateReport(report : Report) -> Report? {

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
        statementBuilder.update(tableName: D.tReport,
                                keyValue: keyValueArray,
                                primarykeyValue: reportCondition)

        if let files = report.reportFiles {
            let reportFilesCondition = [KeyValue(key: D.cReportInstanceId, value: report.id as Any)]

            statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                    primarykeyValue:reportFilesCondition )

            files.forEach({ reportFile in
                let reportFileValuesToAdd = [

                    reportFile.id == nil ? nil : KeyValue(key: D.cId, value: reportFile.id),
                    KeyValue(key: D.cReportInstanceId, value: report.id),
                    KeyValue(key: D.cVaultFileInstanceId, value: reportFile.fileId),
                    KeyValue(key: D.cStatus, value: reportFile.status?.rawValue),
                    KeyValue(key: D.cBytesSent, value: reportFile.bytesSent),
                    KeyValue(key: D.cCreatedDate, value: reportFile.createdDate),
                    KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]

                statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
                                            keyValue: reportFileValuesToAdd)
            })
        }

        guard let reportId = report.id else { return nil }
        return getReport(reportId: reportId)
    }

    func updateReportStatus(idReport : Int, status: ReportStatus, date: Date) -> Int? {

        let valuesToUpdate = [KeyValue(key: D.cStatus, value: status.rawValue),
                              KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]
        let reportCondition = [KeyValue(key: D.cReportId, value: idReport)]

        return statementBuilder.update(tableName: D.tReport,
                                       keyValue: valuesToUpdate,
                                       primarykeyValue: reportCondition)
    }

    @discardableResult
    func resetCurrentUploadReport() throws -> Int? {
        let reportCondition = [KeyValue(key: D.cCurrentUpload, value: 1)]
        let responseDict = try statementBuilder.selectQuery(tableName: D.tReport,
                                                            andCondition: reportCondition )

        if !responseDict.isEmpty, let dict = responseDict.first  {
            let reportID = dict[D.cReportId] as? Int
            let valuesToUpdate = [KeyValue(key: D.cCurrentUpload, value: 0),
                                  KeyValue(key: D.cStatus, value: ReportStatus.submitted.rawValue)]
            let reportCondition = [KeyValue(key: D.cReportId, value: reportID)]

            return statementBuilder.update(tableName: D.tReport,
                                           keyValue: valuesToUpdate,
                                           primarykeyValue:reportCondition)
        }
        return 0
    }

    @discardableResult
    func updateReportFile(reportFile:ReportFile) -> Int? {

        var keyValueArray : [KeyValue]  = []

        if let status = reportFile.status {
            keyValueArray.append(KeyValue(key: D.cStatus, value: status.rawValue))
        }

        if let bytesSent = reportFile.bytesSent {
            keyValueArray.append(KeyValue(key: D.cBytesSent, value: bytesSent))
        }

        keyValueArray.append(KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble()))

        let primarykey = [KeyValue(key: D.cId, value: reportFile.id)]
        return statementBuilder.update(tableName: D.tReportInstanceVaultFile,
                                       keyValue: keyValueArray,
                                       primarykeyValue: primarykey)
    }

    func addReportFile(fileId:String?, reportId:Int) -> Int? {
        let reportFileValues = [KeyValue(key: D.cReportInstanceId, value: reportId),
                                KeyValue(key: D.cVaultFileInstanceId, value: fileId),
                                KeyValue(key: D.cStatus, value: FileStatus.notSubmitted.rawValue),
                                KeyValue(key: D.cBytesSent, value: 0),
                                KeyValue(key: D.cCreatedDate, value: Date().getDateDouble()),
                                KeyValue(key: D.cUpdatedDate, value: Date().getDateDouble())]


        return statementBuilder.insertInto(tableName: D.tReportInstanceVaultFile,
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
    func deleteReportFiles(reportIds:[Int]) {
        let reportCondition = [KeyValues(key: D.cReportInstanceId, value: reportIds)]
        statementBuilder.delete(tableName: D.tReportInstanceVaultFile,
                                inCondition: reportCondition)
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
