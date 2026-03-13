//
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
import UIKit

class BaseUploadOperation: Operation {
    
    public var report: Report?
    public var urlSession: URLSession!
    public var mainAppModel: MainAppModel!
    
    let reportRepository: ReportRepository
    
    public var reportVaultFiles: [ReportVaultFile]? = nil
    var initialResponse = CurrentValueSubject<UploadResponse?,APIError>(.initial)
    var response = CurrentValueSubject<UploadResponse?,APIError>(.initial)
    
    public var uploadTasksDict : [URLSessionTask: String] = [:]
    
    var filesToUpload : [FileToUpload] = []
    var subscribers : Set<AnyCancellable> = []
    var type: OperationType!
    
    public var apiCancellables: Set<AnyCancellable> = []
    static let newServerVersion = "1.4.0"
    
    override init() {
        self.reportRepository = ReportRepository()
        super.init()
    }
    
    override func cancel() {
        super.cancel()
    }
    
    func pauseSendingReport() {
        _ = uploadTasksDict.keys.compactMap({$0.cancel()})
        self.cancel()
        uploadTasksDict.removeAll()
        apiCancellables.removeAll()
        updateReport(reportStatus: .submissionPaused)
        
    }
    
    func cancelSendingReport() {
        _ = uploadTasksDict.keys.compactMap({$0.cancel()})
        uploadTasksDict.removeAll()
        apiCancellables.removeAll()
        
        self.cancel()
        
    }
    
    func stopConnection() {
        _ = uploadTasksDict.keys.compactMap({$0.cancel()})
        uploadTasksDict.removeAll()
        updateReport(reportStatus: .submissionPending)
        self.filesToUpload.removeAll()
        apiCancellables.removeAll()
    }
    
    func autoPauseReport() {
        updateReport(reportStatus: .submissionAutoPaused)
        _ = uploadTasksDict.keys.compactMap({$0.cancel()})
        uploadTasksDict.removeAll()
        apiCancellables.removeAll()
    }
    
    override func main() {
        handleInialResponse()
    }
    
    init(urlSession: URLSession, mainAppModel: MainAppModel, reportRepository: ReportRepository, type: OperationType) {
        self.urlSession = urlSession
        self.mainAppModel = mainAppModel
        self.reportRepository = reportRepository
        self.type = type
        super.init()
    }
    
    func handleInialResponse() {
        self.initialResponse.sink { completion in
            
        } receiveValue: { uploadResponse in
            switch uploadResponse {
            case .progress(let progressInfo):
                
                let file = self.reportVaultFiles?.first(where: {$0.id == progressInfo.fileId})
                let instanceId = file?.instanceId
                
                let totalByteSent = self.updateReportFile(fileStatus: progressInfo.status,
                                                          id: instanceId,
                                                          bytesSent: progressInfo.bytesSent,
                                                          current: progressInfo.current)
                
                
                self.response.send(UploadResponse.progress(progressInfo: UploadProgressInfo(bytesSent:totalByteSent,
                                                                                            fileId: progressInfo.fileId,
                                                                                            status: progressInfo.status,
                                                                                            reportStatus: self.report?.status)))
                self.checkAllFilesAreUploaded()
                
            case .createReport(let apiId, let reportStatus, let error):
                self.updateReport(apiID:apiId, reportStatus: reportStatus)
                self.response.send(UploadResponse.createReport(apiId: apiId, reportStatus: reportStatus, error: error))
                
            case .initial:
                break
            case .finish:
                break
            case .none:
                break
            }
        }.store(in: &subscribers)
        
    }
    
    func updateReport(apiID: String? = nil, reportStatus: ReportStatus?) {
        
        self.report?.status = reportStatus ?? .unknown
        if apiID != nil {
            self.report?.apiID = apiID
        }
        let report = Report(id: self.report?.id,
                            status: reportStatus,
                            apiID: apiID)
        
        mainAppModel.tellaData?.updateReport(report: report)
    }
    
    func updateReportFile(fileStatus:FileStatus, id:Int?, bytesSent:Int? = nil, current:Int? = nil ) -> Int {
        guard let id else { return 0 }
        
        _ =  self.reportVaultFiles?.compactMap { _ in
            let file = self.reportVaultFiles?.first(where: {$0.instanceId == id})
            
            file?.status = fileStatus
            
            if let bytesSent {
                file?.bytesSent = bytesSent
            }
            
            if let current {
                file?.current = current
            }
            return file
        }
        
        let file = self.reportVaultFiles?.first(where: {$0.instanceId == id})
        let totalBytesSent = (file?.current ?? 0)  + (file?.bytesSent ?? 0)
        
        mainAppModel.tellaData?.updateReportFile(reportFile: ReportFile(id: id,
                                                                        status: fileStatus,
                                                                        bytesSent: totalBytesSent))
        return totalBytesSent
    }
    
    private func checkAllFilesAreUploaded() {
        
        guard let reportVaultFiles = self.reportVaultFiles else { return }
        
        let filesAreUploaded = reportVaultFiles.filter { $0.status != .submissionError && $0.status != .submitted }
        guard filesAreUploaded.isEmpty else { return }
        
        let filesNotSubmitted = reportVaultFiles.filter { $0.status != .submitted }
        
        let success = filesNotSubmitted.isEmpty
        if success {
            self.updateReport(reportStatus: .submitted)
        } else {
            self.updateReport(reportStatus: .submissionError)
            return
        }
        
        if let currentUpload = self.report?.currentUpload, currentUpload , let autoDelete = self.report?.server?.autoDelete, autoDelete {
            self.deleteCurrentAutoReport()
            self.response.send(.finish(isAutoDelete: true, title: self.report?.title))
        } else  {
            self.response.send(.finish(isAutoDelete: false, title: self.report?.title))
        }
        
        self.report = nil
        self.cancel()
        self.filesToUpload.removeAll()
    }
    
    func deleteCurrentAutoReport() {
        let deleteReportResult = mainAppModel.tellaData?.deleteReport(reportId: self.report?.id)
        
        if case .success = deleteReportResult {
            guard let reportVaultFiles = self.reportVaultFiles else {return}
            let reportVaultFilesIds = reportVaultFiles.compactMap{ $0.id}
            mainAppModel.vaultFilesManager?.deleteVaultFile(fileIds: reportVaultFilesIds)
        }
    }
    
    // MARK: - CREATE REPORT (Publisher)
    
    /// Builds reportVaultFiles from report and vault file manager. Override to add behavior (e.g. updateReport).
    func prepareReportToSend(report: Report?) {
        guard let report else { return }
        
        let vaultFileResult = mainAppModel.vaultFilesManager?.getVaultFiles(ids: report.reportFiles?.compactMap { $0.fileId } ?? [])
        var reportVaultFiles: [ReportVaultFile] = []
        
        report.reportFiles?.forEach { reportFile in
            if let vaultFile = vaultFileResult?.first(where: { reportFile.fileId == $0.id }) {
                reportVaultFiles.append(ReportVaultFile(reportFile: reportFile, vaultFile: vaultFile))
            }
        }
        
        self.reportVaultFiles = reportVaultFiles
    }
    
    private func guardNetworkConnected() -> Bool {
        guard mainAppModel.networkMonitor.isConnected else {
            updateReport(reportStatus: .submissionPending)
            return false
        }
        return true
    }
    
    func sendReport() {
        guard guardNetworkConnected() else { return }
        
        guard let report else { return }
        
        updateReport(reportStatus: .submissionInProgress)
        
        reportRepository.createReport(report: report)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let err) = completion {
                    self.initialResponse.send(.createReport(apiId: nil, reportStatus: .submissionError, error: err))
                }
            } receiveValue: { [weak self] reportAPI in
                guard let self, !self.isCancelled else { return }
                
                let apiID = reportAPI.id
                
                let emptyFiles = self.report?.reportFiles?.isEmpty ?? true
                let status = emptyFiles ? ReportStatus.submitted : ReportStatus.submissionInProgress
                
                self.initialResponse.send(.createReport(apiId: apiID, reportStatus: status, error: nil))
                self.report?.apiID = apiID
                
                self.uploadFiles()
            }
            .store(in: &apiCancellables)
    }
    
    func uploadFiles() {
        guard !isCancelled, guardNetworkConnected() else { return }
        
        guard let apiID = self.report?.apiID,
              let accessToken = report?.server?.accessToken,
              let serverUrl = report?.server?.url
        else { return }
        let version = report?.server?.version
        
        if let filesToUpload = reportVaultFiles?.filter({ $0.status != .submitted }) {
            if filesToUpload.isEmpty {
                self.checkAllFilesAreUploaded()
            } else {
                filesToUpload.forEach { reportVaultFile in
                    guard !self.isCancelled else { return }
                    let url = mainAppModel.vaultManager.loadVaultFileToURL(file: reportVaultFile)
                    guard let url else { return }
                    let syncedBytesSent = max(0, min(reportVaultFile.bytesSent, reportVaultFile.size))
                    let remainingBytes = max(0, reportVaultFile.size - syncedBytesSent)
                    
                    let fileToUpload = FileToUpload(idReport: apiID,
                                                    fileUrlPath: url,
                                                    baseDecryptedURL: url,
                                                    accessToken: accessToken,
                                                    serverURL: serverUrl,
                                                    fileName: reportVaultFile.name,
                                                    fileExtension: reportVaultFile.fileExtension,
                                                    fileId: reportVaultFile.id,
                                                    fileSize: reportVaultFile.size,
                                                    bytesSent: syncedBytesSent,
                                                    remainingBytesToSend: remainingBytes,
                                                    uploadOnBackground: report?.server?.backgroundUpload ?? false,
                                                    version: version)
                    
                    self.filesToUpload.append(fileToUpload)
                    
                    self.checkFileSizeOnServer(fileToUpload: fileToUpload)
                }
            }
        }
    }
    
    func checkFileSizeOnServer(fileToUpload: FileToUpload) {
        guard guardNetworkConnected() else { return }
        
        reportRepository.headReportFile(fileToUpload: fileToUpload)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    self.initialResponse.send(.progress(progressInfo: .init(fileId: fileToUpload.fileId, status: .submissionError)))
                }
            } receiveValue: { [weak self] size in
                guard let self, !self.isCancelled else { return }
                
                if size > fileToUpload.fileSize {
                    debugLog("Server file size exceeds local file size")
                    self.initialResponse.send(
                        .progress(
                            progressInfo: UploadProgressInfo(fileId: fileToUpload.fileId, status: .submissionError)
                        )
                    )
                    return
                }
                
                self.initialResponse.send(
                    .progress(
                        progressInfo: UploadProgressInfo(
                            bytesSent: size,
                            current: 0,
                            fileId: fileToUpload.fileId,
                            status: .partialSubmitted
                        )
                    )
                )
                
                self.putReportFile(fileId: fileToUpload.fileId, size: size)
            }
            .store(in: &apiCancellables)
    }
    
    func postReportFile(fileId: String?) {
        guard guardNetworkConnected() else { return }
        
        guard  let fileToUpload = filesToUpload.first(where: {$0.fileId == fileId}) else {return}
        
        reportRepository.postFile(fileToUpload: fileToUpload)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure = completion {
                    self.initialResponse.send(.progress(progressInfo: .init(fileId: fileToUpload.fileId, status: .submissionError)))
                }
            } receiveValue: { [weak self] result in
                guard let self else { return }
                self.initialResponse.send(UploadResponse.progress(progressInfo: UploadProgressInfo(fileId: fileId, status: FileStatus.submitted)))
            }
            .store(in: &apiCancellables)
    }
    
    func putReportFile(fileId: String?, size: Int) {
        guard !isCancelled else { return }
        guard guardNetworkConnected() else { return }
        guard let session = self.urlSession else { return }
        guard let fileId else { return }
        guard let fileToUpload = filesToUpload.first(where: { $0.fileId == fileId }) else { return }
        
        if size > fileToUpload.fileSize {
            debugLog("Invalid resume offset: server file larger than local file")
            initialResponse.send(.progress(progressInfo: .init(fileId: fileId, status: .submissionError)))
            return
        }
        
        let syncedBytesSent = max(0, min(size, fileToUpload.fileSize))
        fileToUpload.bytesSent = syncedBytesSent
        fileToUpload.remainingBytesToSend = max(0, fileToUpload.fileSize - syncedBytesSent)
        
        if fileToUpload.remainingBytesToSend == 0 {
            if fileToUpload.version == BaseUploadOperation.newServerVersion {
                self.initialResponse.send(
                    UploadResponse.progress(
                        progressInfo: UploadProgressInfo(fileId: fileId, status: FileStatus.submitted)
                    )
                )
            } else {
                self.initialResponse.send(
                    UploadResponse.progress(
                        progressInfo: UploadProgressInfo(fileId: fileId, status: FileStatus.uploaded)
                    )
                )
                self.postReportFile(fileId: fileId)
            }
            return
        }
        
        var inputURL = fileToUpload.baseDecryptedURL
        // Re-load from vault if temp file was cleaned up (e.g. iOS temp cleanup between head and extract)
        if !mainAppModel.vaultManager.fileExists(at: inputURL.path),
           let reportVaultFile = reportVaultFiles?.first(where: { $0.id == fileId }),
           let reloadedURL = mainAppModel.vaultManager.loadVaultFileToURL(file: reportVaultFile) {
            inputURL = reloadedURL
            fileToUpload.baseDecryptedURL = reloadedURL
        }
        
        if syncedBytesSent > 0 {
            do {
                let outputURL = try mainAppModel.vaultManager.extract(
                    from: inputURL,
                    offsetSize: syncedBytesSent
                )
                fileToUpload.fileUrlPath = outputURL
                
            } catch let error {
                debugLog("extract failed: \(error.localizedDescription)")
                initialResponse.send(.progress(progressInfo: .init(fileId: fileId, status: .submissionError)))
                return
            }
        }
        
        let path = fileToUpload.fileUrlPath.path
        
        guard mainAppModel.vaultManager.fileExists(at: path),
              mainAppModel.vaultManager.isReadableFile(at: path) else {
            debugLog("Upload file missing/unreadable")
            initialResponse.send(.progress(progressInfo: .init(fileId: fileId, status: .submissionError)))
            return
        }
        
        do {
            let task = try reportRepository.makePutReportFileUploadTask(
                fileToUpload: fileToUpload,
                session: session
            )
            uploadTasksDict[task] = fileId
            task.resume()
        } catch {
            debugLog("PUT report file request failed")
            initialResponse.send(.progress(progressInfo: .init(fileId: fileId, status: .submissionError)))
        }
    }
    
    func didSend(bytesSent: Int?, task: URLSessionTask?) {
        guard let task else { return }
        let fileId = uploadTasksDict[task]
        
        self.initialResponse.send(UploadResponse.progress(progressInfo: UploadProgressInfo(current: bytesSent, fileId: fileId, status: FileStatus.partialSubmitted)))
    }
    
    func didComplete(task: URLSessionTask?, error: Error?) {
        guard let task else { return }
        let fileId = uploadTasksDict[task]
        uploadTasksDict.removeValue(forKey: task)
        
        let httpSuccess: Bool = {
            guard error == nil else { return false }
            guard let httpResponse = task.response as? HTTPURLResponse else { return false }
            return HTTPCodes.success.contains(httpResponse.statusCode)
        }()
        
        if !httpSuccess {
            debugLog("Upload task failed or server error")
            self.initialResponse.send(UploadResponse.progress(progressInfo: UploadProgressInfo(fileId: fileId, status: FileStatus.submissionError)))
            return
        }
        
        guard let fileToUpload = filesToUpload.first(where: { $0.fileId == fileId }) else { return }
        
        if fileToUpload.version == BaseUploadOperation.newServerVersion {
            self.initialResponse.send(UploadResponse.progress(progressInfo: UploadProgressInfo(fileId: fileId, status: FileStatus.submitted)))
        } else {
            self.initialResponse.send(UploadResponse.progress(progressInfo: UploadProgressInfo(fileId: fileId, status: FileStatus.uploaded)))
            self.postReportFile(fileId: fileId)
        }
        
        let current = fileToUpload.fileUrlPath
        mainAppModel.vaultManager.deleteFiles(files: [current])
        
        let base = fileToUpload.baseDecryptedURL
        if base != fileToUpload.fileUrlPath {
            mainAppModel.vaultManager.deleteFiles(files: [base])
        }
    }
}
