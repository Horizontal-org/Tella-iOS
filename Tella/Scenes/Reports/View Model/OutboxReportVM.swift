//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI
import Combine

class OutboxReportVM: ObservableObject {
    
    var mainAppModel : MainAppModel
    var reportsViewModel : ReportsViewModel
    
    @Published var reportViewModel : ReportViewModel = ReportViewModel()
    
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var percentUploaded : Float = 0.0
    @Published var percentUploadedInfo : String = "Waiting for connection"
    @Published var uploadedFiles : String = ""
    
    @Published var isLoading : Bool = false
    @Published var isSubmissionInProgress: Bool = false
    @Published var shouldShowSubmittedReportView : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    private var filesToUpload : [FileToUpload] = []
    private var uploadProgressInfoArray : [UploadProgressInfo] = []
    private var reportRepository = ReportRepository()
    
    init(mainAppModel: MainAppModel, reportsViewModel : ReportsViewModel, reportId : Int?, shouldStartUpload: Bool = false) {
        
        self.mainAppModel = mainAppModel
        self.reportsViewModel = reportsViewModel
        
        initVaultFile(reportId: reportId)
        
        initializeProgressionInfos()
        
        if shouldStartUpload {
            self.submitReport()
        }
    }
    
    func initVaultFile(reportId: Int?) {
        
        if let reportId, let report = self.mainAppModel.vaultManager.tellaData.getReport(reportId: reportId) {
            
            var vaultFileResult : Set<VaultFile> = []
            
            mainAppModel.vaultManager.root.getFile(root: mainAppModel.vaultManager.root,
                                                   vaultFileResult: &vaultFileResult,
                                                   ids: report.reportFiles?.compactMap{$0.fileId} ?? [])
            var files : [ReportVaultFile] = []
            
            report.reportFiles?.forEach({ reportFile in
                if let vaultFile = vaultFileResult.first(where: {reportFile.fileId == $0.id}) {
                    let reportVaultFile = ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile)
                    files.append(reportVaultFile)
                }
            })
            
            
            self.reportViewModel = ReportViewModel(id: report.id,
                                                   title: report.title ?? "",
                                                   description: report.description ?? "",
                                                   files: files, server: report.server,
                                                   status: report.status,
                                                   apiID: report.apiID)
            
            self.isSubmissionInProgress = report.status == .submissionInProgress
        }
        
    }
    
    func initializeProgressionInfos() {
        progressFileItems = self.reportViewModel.files.compactMap{ProgressFileItemViewModel(file: $0, progression: "0/" + $0.size.getFormattedFileSize())}
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + $1.size}
        self.uploadedFiles = " \(self.reportViewModel.files.count) files, 0/\(totalSize.getFormattedFileSize()) uploaded"
    }
    
    func saveReport() {
        
        let report = Report(id: reportViewModel.id,
                            title: reportViewModel.title,
                            description: reportViewModel.description,
                            date: Date(),
                            status: reportViewModel.status,
                            server: reportViewModel.server,
                            vaultFiles: self.reportViewModel.files.compactMap{ ReportFile(fileId: $0.id,
                                                                                          status: .notSubmitted,
                                                                                          totalBytesSent: 0,
                                                                                          createdDate: Date(),
                                                                                          updatedDate: Date())},
                            apiID: reportViewModel.apiID)
        
        do {
            let _ = try mainAppModel.vaultManager.tellaData.updateReport(report: report)
            
        } catch {
            
        }
    }
    
    func updateReportStatus(reportStatus:ReportStatus) {
        guard let id = reportViewModel.id else { return  }
        
        do {
            let _ = try mainAppModel.vaultManager.tellaData.updateReportStatus(idReport: id, status: reportStatus)
            
        } catch {
            
        }
    }
    
    func updateReportFile(fileStatus:FileStatus, id:Int?, totalBytesSent:Int ) {
        guard let id else { return  }
        
        do {
            let _ = try mainAppModel.vaultManager.tellaData.updateReportFile(reportFile: ReportFile(id: id,
                                                                                                    status: fileStatus,
                                                                                                    totalBytesSent: totalBytesSent))
            
        } catch {
            
        }
    }
    
    func pauseSubmission() {
        self.isSubmissionInProgress = false
        DispatchQueue.global(qos: .background).async {
            self.updateReportStatus(reportStatus: .submissionPartialParts)
            self.reportRepository.pause(self.filesToUpload)
        }
    }
    
    func submitReport() {
        self.isSubmissionInProgress = true
        DispatchQueue.global(qos: .background).async {
            self.updateReportStatus(reportStatus: .submissionInProgress)
            if self.reportViewModel.apiID == nil {
                self.createReport()
            } else {
                self.uploadReportFiles()
            }
        }
    }
    
    
    func createReport()   {
        //        DispatchQueue.main.async {
        //            // self.isLoading = true
        //        }
        
        let report = Report(id: reportViewModel.id,
                            title: reportViewModel.title,
                            description: reportViewModel.description,
                            date: Date(),
                            status: reportViewModel.status,
                            server: reportViewModel.server,
                            vaultFiles: self.reportViewModel.files.compactMap{ReportFile(fileId: $0.id,
                                                                                         status: .notSubmitted,
                                                                                         totalBytesSent: 0,
                                                                                         createdDate: Date(),
                                                                                         updatedDate: Date()) })
        
        self.reportRepository.createReport(report: report)
            .sink(
                receiveCompletion: { completion in
                    //                    self.isLoading = false
                    
                    switch completion {
                        
                    case .failure:
                        self.updateReportStatus(reportStatus: .submissionError)
                        
                    case .finished:
                        break
                    }
                },
                receiveValue: { result in
                    
                    switch result {
                    case .response(let response):
                        self.reportViewModel.apiID = response?.id
                        if self.reportViewModel.files.isEmpty {
                            self.reportViewModel.status = .submitted
                        }
                        self.saveReport()
                        
                        if self.reportViewModel.files.isEmpty {
                            self.showSubmittedReport()
                        }
                        
                        self.uploadReportFiles()
                        
                    default:
                        break
                    }
                    
                }
            )
            .store(in: &subscribers)
    }
    
    func showSubmittedReport() {
        self.shouldShowSubmittedReportView = true
    }
    
    func uploadReportFiles() {
        
        if isSubmissionInProgress {
            
            guard let apiID = reportViewModel.apiID, let accessToken = reportViewModel.server?.accessToken, let serverUrl = reportViewModel.server?.url else { return }
            
            reportViewModel.files.forEach({ reportVaultFile in
                
                let vaultFileInfo = mainAppModel.loadFileInfos(file: reportVaultFile)
                guard let vaultFileInfo else { return }
                
                let fileToUpload = FileToUpload(idReport: apiID,
                                                fileUrlPath: vaultFileInfo.url,
                                                accessToken: accessToken,
                                                serverURL: serverUrl,
                                                data: vaultFileInfo.data,
                                                fileName: reportVaultFile.fileName,
                                                fileExtension: reportVaultFile.fileExtension,
                                                fileId: reportVaultFile.id,
                                                fileSize: reportVaultFile.size,
                                                bytesSent: reportVaultFile.totalBytesSent ?? 0,
                                                uploadOnBackground: reportViewModel.server?.backgroundUpload ?? false)
                
                self.filesToUpload.append(fileToUpload)
                self.checkFileSizeOnServer(fileToUpload: fileToUpload)
            })
        }
    }
    
    func checkFileSizeOnServer(fileToUpload:FileToUpload) {
        
        if isSubmissionInProgress   {
            
            self.reportRepository.checkFileSizeOnServer(file: fileToUpload)
            
                .sink(receiveCompletion: { completion in
                    
                    switch completion {
                        
                    case .failure:
                        self.checkFileSizeOnServer(fileToUpload: fileToUpload)
                        
                    case .finished:
                        break
                    }
                }, receiveValue: { result in
                    
                    switch result {
                    case .response(let response):
                        self.update(fileToUpload: fileToUpload, sizeResult: response)
                        
                    default:
                        break
                    }
                }) .store(in: &subscribers)
        }
    }
    
    func update(fileToUpload:FileToUpload,sizeResult : ServerFileSize? ) {
        
        let file = self.reportViewModel.files.first(where: {$0.id == fileToUpload.fileId})
        if  let fileSize = file?.size, let sizeResult = sizeResult?.size, sizeResult >= fileSize  {
            self.postReportFile(fileToUpload: fileToUpload)
            
        } else {
            file?.totalBytesSent = (sizeResult?.size ) ?? 0
            
            let instanceId = file?.instanceId
            
            self.updateReportFile(fileStatus: .partialSubmitted, id: instanceId, totalBytesSent:  (sizeResult?.size) ?? 0)
            
            if let fileUrlPath = self.mainAppModel.saveDataToTempFile(data: fileToUpload.data?.extract(size: sizeResult?.size), fileName: fileToUpload.fileName, pathExtension: fileToUpload.fileExtension) {
                fileToUpload.fileUrlPath = fileUrlPath
            }
            fileToUpload.data = fileToUpload.data?.extract(size: sizeResult?.size)
            self.putReportFile(fileToUpload: fileToUpload)
        }
    }
    
    func putReportFile(fileToUpload:FileToUpload) {
        
        if isSubmissionInProgress {
            
            self.reportRepository.putReport(file: fileToUpload)
                .sink(receiveCompletion: { completion in
                    
                    switch completion {
                    case .failure:
                        self.checkFileSizeOnServer(fileToUpload: fileToUpload)
                        
                    case .finished:
                        break
                    }
                },
                      receiveValue: { result in
                    
                    switch result {
                    case .progress(let uploadProgressInfo):
                        
                        self.updateProgressInfos(uploadProgressInfo: uploadProgressInfo)
                        
                        let instanceId = self.reportViewModel.files.first(where: {$0.id == fileToUpload.fileId})?.instanceId
                        let totalBytesSent = self.reportViewModel.files.first(where: {$0.id == fileToUpload.fileId})?.totalBytesSent
                        
                        self.updateReportFile(fileStatus: .partialSubmitted, id: instanceId, totalBytesSent: Int(uploadProgressInfo.current + (totalBytesSent ?? 0)))
                        
                    case .response:
                        self.postReportFile(fileToUpload: fileToUpload)
                    case .initial:
                        break
                    }
                }).store(in: &subscribers)
        }
    }
    
    func postReportFile(fileToUpload:FileToUpload) {
        
        if isSubmissionInProgress {
            
            self.reportRepository.postReport(file: fileToUpload)
                .sink(receiveCompletion: { completion in
                    
                    switch completion {
                    case .failure:
                        break
                        
                    case .finished:
                        break
                    }
                },
                      receiveValue: { result in
                    switch result {
                    case .response(let response):
                        
                        if let success = response?.success, success {
                            if let item = self.uploadProgressInfoArray.filter ({$0.fileId == fileToUpload.fileId}).first {
                                item.status = .submitted
                            }
                            self.checkAllFilesAreUploaded()
                            
                        } else  {
                            self.checkFileSizeOnServer(fileToUpload: fileToUpload)
                        }
                        
                    default:
                        break
                    }
                }
                )
                .store(in: &subscribers)
        }
    }
    
    private func updateProgressInfos(uploadProgressInfo : UploadProgressInfo) {
        
        if let index = self.uploadProgressInfoArray.firstIndex(where:({$0.fileId == uploadProgressInfo.fileId})) {
            self.uploadProgressInfoArray.remove(at: index)
        }
        self.uploadProgressInfoArray.append(uploadProgressInfo)
        
        // Formatted progress info
        let totalBytesSent = self.reportViewModel.files.first(where: {$0.id == uploadProgressInfo.fileId})?.totalBytesSent
        let totalUploaded = self.uploadProgressInfoArray.reduce(0) { $0 + $1.current} + (totalBytesSent ?? 0)
        let totalSize = self.reportViewModel.files.reduce(0) { $0 + $1.size}
        
        if totalSize > 0 {
            
            let percentUploaded = Float(totalUploaded) / Float(totalSize)
            let formattedTotalUploaded = totalUploaded.getFormattedFileSize().getFileSizeWithoutUnit()
            let formattedTotalSize = totalSize.getFormattedFileSize()
            
            DispatchQueue.main.async {
                // Progress Files Progress
                self.percentUploadedInfo = "\(Int(percentUploaded * 100))% uploaded"
                self.percentUploaded = Float(percentUploaded)
                self.uploadedFiles = " \(self.reportViewModel.files.count) files, \(formattedTotalUploaded)/\(formattedTotalSize) uploaded"
                
                //Progress File Items
                if let currentItem = self.progressFileItems.first(where: {$0.file.id == uploadProgressInfo.fileId}) {
                    currentItem.progression = "\(uploadProgressInfo.current.getFormattedFileSize().getFileSizeWithoutUnit())/\(currentItem.file.size.getFormattedFileSize())"
                }
                self.objectWillChange.send()
            }
        }
    }
    
    private func checkAllFilesAreUploaded() {
        
        // Check if all the files are submitted
        
        let isNotFishUploading = self.uploadProgressInfoArray.filter{$0.status != .submitted}
        
        if isNotFishUploading.isEmpty {
            
            self.updateReportStatus(reportStatus: .submitted)
            
            DispatchQueue.main.async {
                self.showSubmittedReport()
            }
        }
    }
}
