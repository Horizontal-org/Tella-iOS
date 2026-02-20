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
            defaultSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        if backgroundSession == nil {
            let config = URLSessionConfiguration.background(withIdentifier: UploadConstants.backgroundSessionIdentifier)
            config.sessionSendsLaunchEvents = true
            backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
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
    
    static func reset() {
        shared = UploadService()
    }
    
    var hasFilesToUploadOnBackground: Bool {
        withOperations { operations in
            !operations.filter { $0.uploadTasksDict.values.count != 0 }.isEmpty
        }
    }
    
    func pauseUpload(reportId: Int?) {
        withOperations { operations in
            let operation = operations.first(where: { $0.report?.id == reportId })
            operation?.pauseSendingReport()
            operations.removeAll(where: { $0.report?.id == reportId && (operation?.type != .autoUpload) })
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
        
        let urlSession = session(forBackground: autoUploadServer?.autoUpload ?? false)
        
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
    
    func addUploadReportOperation(report:Report, mainAppModel: MainAppModel ) -> CurrentValueSubject<UploadResponse?,APIError>  {
        
        let urlSession = session(forBackground: report.server?.backgroundUpload ?? false)
        
        let operation = UploadReportOperation(report: report, urlSession: urlSession, mainAppModel: mainAppModel, reportRepository: ReportRepository(), type: .uploadReport)
        withOperations { $0.append(operation) }
        uploadQueue.addOperation(operation)
        
        displayReportToast(operation: operation)
        
        return operation.response
    }
    
    func addAutoUpload(file: VaultFileDB)  {
        let nonAutoUploadOperation = withOperations { $0.first(where: { $0.report?.currentUpload == true && $0.type != .autoUpload }) }
        if let nonAutoUploadOperation {
            cancelSendingReport(reportId: nonAutoUploadOperation.report?.id)
        }
        
        if let operation: AutoUpload = withOperations({ $0.first(where: { $0.type == .autoUpload }) }) as? AutoUpload {
            operation.addFile(file:file)
        }
    }
    
    func sendUnsentReports(mainAppModel:MainAppModel) {
        
        guard let unsentReports = mainAppModel.tellaData?.getUnsentReports() else { return }
        
        unsentReports.forEach { report in
            
            let urlSession = session(forBackground: report.server?.backgroundUpload ?? false)
            
            let operation = UploadReportOperation(report: report, urlSession: urlSession, mainAppModel: mainAppModel, reportRepository: ReportRepository(), type: .unsentReport)
            withOperations { $0.append(operation) }
            uploadQueue.addOperation(operation)
            
            displayReportToast(operation:operation)
        }
    }
    
    func displayReportToast(operation: BaseUploadOperation) {
        let operationId = ObjectIdentifier(operation)
        let cancellable = operation.response.sink(receiveCompletion: { [weak self] _ in
            self?.removeToastSubscription(operationId: operationId)
        }, receiveValue: { [weak self] response in
            self?.handleReportResponse(response: response)
            if case .finish = response {
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


