//
//  GDriveOutboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveOutboxViewModel: OutboxMainViewModel<GDriveServer> {
    private let gDriveRepository: GDriveRepositoryProtocol
    
    init(mainAppModel: MainAppModel,
         reportsViewModel : ReportMainViewModel,
         reportId : Int?,
         repository: GDriveRepository,
         shouldStartUpload: Bool = false
    ) {
        self.gDriveRepository = repository
        super.init(mainAppModel: mainAppModel, reportsViewModel: reportsViewModel, reportId: reportId)
        
        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
        if shouldStartUpload {
            self.submitReport()
        } else {
            // treat
        }
    }
    
    
    override func initVaultFile(reportId: Int?) {
        if let reportId, let report = self.mainAppModel.tellaData?.getDriveReport(id: reportId) {
            let vaultFileResult  = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap{$0.fileId} ?? [])
            
            var files: [ReportVaultFile] = []
            
            report.reportFiles?.forEach({ reportFile in
                if let vaultFile = vaultFileResult?.first(where: {reportFile.fileId == $0.id}) {
                    let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                    files.append(reportVaultFile)
                }
            })
            
            self.reportViewModel = ReportViewModel(id: report.id,
                                                               title: report.title ?? "",
                                                               description: report.description ?? "",
                                                               files: files,
                                                               reportFiles: report.reportFiles ?? [],
                                                               server: report.server,
                                                               status: report.status,
                                                               apiID: nil)
        }
    }
    
    override func submitReport() {
        performSubmission()
    }
    
    func performSubmission() {
        gDriveRepository.createDriveFolder(
            folderName: reportViewModel.title,
            parentId: reportViewModel.server?.rootFolder,
            description: reportViewModel.description
        )
        .receive(on: DispatchQueue.main)
        .flatMap { folderId in
            self.uploadFiles(to: folderId)
        }
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.updateReportStatus(reportStatus: .submitted)
                    self.showSubmittedReport()
                    break
                case .failure(let error):
                    debugLog(error)
                }
            },
            receiveValue: { result in
                dump(result)
            }
        ).store(in: &subscribers)
    }
    
    private func uploadFiles(to folderId: String) -> AnyPublisher<Void, Error> {
        let uploadPublishers = reportViewModel.files.map { file -> AnyPublisher<String, Error> in
            guard let fileUrl = self.mainAppModel.vaultManager.loadVaultFileToURL(file: file) else {
                return Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
            }
            return gDriveRepository.uploadFile(fileURL: fileUrl, mimeType: file.mimeType ?? "", folderId: folderId)
        }
        
        return Publishers.MergeMany(uploadPublishers)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    override func updateReportStatus(reportStatus: ReportStatus) {
        self.reportViewModel.status = reportStatus
        
        guard let id = reportViewModel.id else { return }

        mainAppModel.tellaData?.updateDriveReportStatus(idReport: id, status: reportStatus)
    }
}
