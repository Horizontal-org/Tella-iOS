//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine
import UIKit

class UploadService: NSObject {
    
    // MARK: - Variables And Properties
    
    static var shared : UploadService = UploadService()
    
    private let operationsLock = NSLock()
    private var _activeOperations: [BaseUploadOperation] = []
    
    /// Thread-safe access to active operations. URLSession delegate callbacks run on background threads.
    private func withOperations<T>(_ block: (inout [BaseUploadOperation]) -> T) -> T {
        operationsLock.withLock { block(&_activeOperations) }
    }
    
    var uploadQueue: OperationQueue!
    /// Toast subscriptions keyed by operation. Removed when upload finishes to prevent memory leak.
    private var toastSubscriptions: [ObjectIdentifier: AnyCancellable] = [:]
    private let toastSubscriptionsLock = NSLock()
    
    
    private var backgroundSession: URLSession?
    private var defaultSession: URLSession?
    
    func ensureSessions() {
        if defaultSession == nil {
            let config = URLSessionConfiguration.default
            config.allowsConstrainedNetworkAccess = true
            config.allowsExpensiveNetworkAccess = true
            defaultSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        }
        if backgroundSession == nil {
            let config = URLSessionConfiguration.background(withIdentifier: UploadConstants.backgroundSessionIdentifier)
            config.sessionSendsLaunchEvents = true
            config.shouldUseExtendedBackgroundIdleMode = true
            config.allowsConstrainedNetworkAccess = true
            config.allowsExpensiveNetworkAccess = true
            config.isDiscretionary = false
            backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            // Cancel any tasks from a previous run (e.g. app killed during upload).
            // New operations will create fresh tasks
            backgroundSession?.getAllTasks { tasks in
                tasks.forEach { $0.cancel() }
            }
        }
    }
    
    func session(forBackground: Bool) -> URLSession {
        ensureSessions()
        return forBackground ? backgroundSession! : defaultSession!
    }

    override init() {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        uploadQueue = queue
    }
    
    func reset() {
        // Cancel operations & clear list
        withOperations { ops in
            ops.forEach { $0.cancel() }
            ops.removeAll()
        }
        
        // Cancel toast subscriptions
        toastSubscriptionsLock.withLock {
            toastSubscriptions.values.forEach { $0.cancel() }
            toastSubscriptions.removeAll()
        }
        
        defaultSession = nil
        backgroundSession = nil
        
    }
    
    var hasFilesToUploadOnBackground: Bool {
        withOperations { operations in
            !operations.filter { $0.uploadTasksDict.values.count != 0 }.isEmpty
        }
    }
    
    func pauseUpload(reportId: Int?) {
        guard let reportId else { return }
        withOperations { operations in
            guard let operation = operations.first(where: { $0.report?.id == reportId}) else { return }
            operation.pauseSendingReport()
            operations.removeAll(where: { $0.report?.id == reportId && $0.type != .autoUpload })
        }
    }

    func cancelTasksIfNeeded() {
        withOperations { operations in
            let toCancel = operations.filter { $0.report?.server?.backgroundUpload == false }
            toCancel.forEach { $0.pauseSendingReport() }
            operations.removeAll(where: { $0.report?.server?.backgroundUpload == false })
        }
    }
    
    func cancelSendingReport(reportId:Int?) {
        withOperations { operations in
            let operation = operations.first(where: { $0.report?.id == reportId })
            operation?.cancelSendingReport()
            operations.removeAll(where: { $0.report?.id == reportId && (operation?.type != .autoUpload) })
        }
    }
    
    func initAutoUpload(mainAppModel: MainAppModel ) {
        
        let autoUploadServer = mainAppModel.tellaData?.getAutoUploadServer()
        
        let urlSession = session(forBackground: autoUploadServer?.backgroundUpload ?? false)

        let operation = AutoUpload(urlSession: urlSession, mainAppModel: mainAppModel, reportRepository: ReportRepository(), type: .autoUpload)
        withOperations { $0.append(operation) }
        uploadQueue.addOperation(operation)
        
        displayReportToast(operation: operation)
    }
    
    func checkUploadReportOperation(reportId:Int?) -> CurrentValueSubject<UploadResponse?,APIError>?  {
        withOperations { operations in
            operations.first(where: { $0.report?.id == reportId })?.response
        }
    }
    
    func addUploadReportOperation(report: Report, mainAppModel: MainAppModel) -> CurrentValueSubject<UploadResponse?,APIError>  {
        if let reportId = report.id {
            let existingResponse = withOperations { operations -> CurrentValueSubject<UploadResponse?, APIError>? in
                // Drop stale operations for the same report so resume can create a fresh one.
                operations.removeAll(where: {
                    $0.report?.id == reportId &&
                    ($0.isCancelled || $0.isFinished) &&
                    $0.type != .autoUpload
                })
                // Any remaining operation for this report is active; reuse its response to avoid duplicates.
                return operations.first(where: { $0.report?.id == reportId })?.response
            }
            if let existingResponse {
                return existingResponse
            }
        }
        
        let urlSession = session(forBackground: report.server?.backgroundUpload ?? false)
        
        let operation = UploadReportOperation(report: report, urlSession: urlSession, mainAppModel: mainAppModel, reportRepository: ReportRepository(), type: .uploadReport)
        withOperations { $0.append(operation) }
        uploadQueue.addOperation(operation)
        
        displayReportToast(operation: operation)
        
        return operation.response
    }
    
    func addAutoUpload(file: VaultFileDB)  {
        if let operation: AutoUpload = withOperations({ $0.first(where: { $0.type == .autoUpload }) }) as? AutoUpload {
            operation.addFile(file: file)
        }
    }
    
    func sendUnsentReports(mainAppModel: MainAppModel) {
        guard let unsentReports = mainAppModel.tellaData?.getUnsentReports() else { return }
        
        unsentReports.forEach { report in
            guard let reportId = report.id else { return }
            
            // if an operation already exists for this report, skip
            let alreadyActive = withOperations { ops in
                ops.contains(where: { $0.report?.id == reportId && !$0.isCancelled && !$0.isFinished })
            }
            guard !alreadyActive else { return }
            
            let urlSession = session(forBackground: report.server?.backgroundUpload ?? false)
            
            let operation = UploadReportOperation(
                report: report,
                urlSession: urlSession,
                mainAppModel: mainAppModel,
                reportRepository: ReportRepository(),
                type: .unsentReport
            )
            withOperations { $0.append(operation) }
            uploadQueue.addOperation(operation)
            
            displayReportToast(operation: operation)
        }
    }
    func displayReportToast(operation: BaseUploadOperation) {
        let operationId = ObjectIdentifier(operation)
        let cancellable = operation.response.sink(receiveCompletion: { [weak self] _ in
            self?.removeToastSubscription(operationId: operationId)
        }, receiveValue: { [weak self] response in
            self?.handleReportResponse(response: response)
            // AutoUpload is long-lived and emits .finish multiple times (once per report).
            // Only remove subscription for single-use operations.
            if case .finish = response, operation.type != .autoUpload {
                self?.removeToastSubscription(operationId: operationId)
            }
        })
        toastSubscriptionsLock.withLock { toastSubscriptions[operationId] = cancellable }
    }
    
    private func removeToastSubscription(operationId: ObjectIdentifier) {
        toastSubscriptionsLock.withLock {
            toastSubscriptions[operationId]?.cancel()
            toastSubscriptions[operationId] = nil
        }
    }
    
    func handleReportResponse(response: UploadResponse?) {
        switch response {
        case .finish(let isAutoDelete, let title):
            self.displaySubmittedToast(title: title)
            if isAutoDelete {
                self.displayDeletedToast(title: title)
            }
        default:
            break
        }
    }
    
    func displaySubmittedToast(title: String?) {
        let message = String(format: LocalizableReport.reportSubmittedToast.localized, title ?? "")
        Toast.displayToast(message: message)
    }
    
    func displayDeletedToast(title: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let message = String(format: LocalizableReport.reportDeletedToast.localized, title ?? "")
            Toast.displayToast(message: message)
        }
    }
}

extension UploadService: URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64 ) {
            let operation = withOperations { $0.first { $0.uploadTasksDict[task] != nil } }
            operation?.didSend(bytesSent: Int(totalBytesSent), task: task as? URLSessionUploadTask)
        }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = AppDelegate.instance,
               let completion = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completion()
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let operation = withOperations { $0.first { $0.uploadTasksDict[task] != nil } }
        operation?.didComplete(task: task, error: error)
        
        finalizeBackgroundUploadsIfNeeded(for: session)
    }
    
    private func finalizeBackgroundUploadsIfNeeded(for session: URLSession) {
        guard session.configuration.identifier == UploadConstants.backgroundSessionIdentifier else { return }
        
        session.getAllTasks { tasks in
            let active = tasks.filter { $0.state == .running || $0.state == .suspended }
            
            guard active.isEmpty else { return }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .backgroundUploadsDidFinish, object: nil)
                
                if let appDelegate = AppDelegate.instance,
                   let completion = appDelegate.backgroundSessionCompletionHandler {
                    appDelegate.backgroundSessionCompletionHandler = nil
                    completion()
                }
            }
        }
    }
}


