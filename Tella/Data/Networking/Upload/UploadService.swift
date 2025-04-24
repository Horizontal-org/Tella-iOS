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
    
    fileprivate var activeOperations: [BaseUploadOperation] = []

    var uploadQueue: OperationQueue!
    private var subscribers = Set<AnyCancellable>()
    
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
        let operations = activeOperations.filter({$0.uploadTasksDict.values.count != 0 && $0.taskType == .uploadTask})
        return !operations.isEmpty
    }
    
    func pauseDownload(reportId:Int?) {
        let operation = activeOperations.first(where: {$0.report?.id == reportId})
        operation?.pauseSendingReport()
        activeOperations.removeAll(where: {$0.report?.id == reportId && (operation?.type != .autoUpload)})
    }
    
    func cancelTasksIfNeeded() {
        let operations = activeOperations.filter({$0.report?.server?.backgroundUpload == false || $0.taskType == .dataTask})
        operations.forEach { operation in
            operation.pauseSendingReport()
        }
        activeOperations.removeAll(where:{$0.report?.server?.backgroundUpload == false || $0.taskType == .dataTask})
    }
    
    func cancelSendingReport(reportId:Int?) {
        let operation = activeOperations.first(where: {$0.report?.id == reportId})
        operation?.cancelSendingReport()
        activeOperations.removeAll(where: {$0.report?.id == reportId && (operation?.type != .autoUpload)})
    }
    
    func initAutoUpload(mainAppModel: MainAppModel ) {
        
        let autoUploadServer = mainAppModel.tellaData?.getAutoUploadServer()
        
        let urlSession = URLSession(
            configuration: autoUploadServer?.autoUpload ?? false ? .background(withIdentifier: "org.wearehorizontal.tella") : .default ,
            delegate: self,
            delegateQueue: nil)
        
        let operation = AutoUpload(urlSession: urlSession, mainAppModel: mainAppModel, type: .autoUpload)
        activeOperations.append(operation)
        uploadQueue.addOperation(operation)
        
        displayReportToast(operation: operation)
    }
    
    func checkUploadReportOperation(reportId:Int?) -> CurrentValueSubject<UploadResponse?,APIError>?  {
        guard let operation = activeOperations.first(where: {$0.report?.id == reportId}) else { return nil}
        return operation.response
    }
    
    func addUploadReportOperation(report:Report, mainAppModel: MainAppModel ) -> CurrentValueSubject<UploadResponse?,APIError>  {
        
        let urlSession = URLSession(
            configuration: report.server?.backgroundUpload ?? false ? .background(withIdentifier: "org.wearehorizontal.tella") : .default ,
            delegate: self,
            delegateQueue: nil)
        
        let operation = UploadReportOperation(report: report, urlSession: urlSession, mainAppModel: mainAppModel, type: .uploadReport)
        activeOperations.append(operation)
        uploadQueue.addOperation(operation)
        
        displayReportToast(operation: operation)
        
        return operation.response
    }
    
    func addAutoUpload(file: VaultFileDB)  {
        
        let nonAutoUploadOperation = activeOperations.first(where: {$0.report?.currentUpload == true && $0.type != .autoUpload})
        if let nonAutoUploadOperation {
            cancelSendingReport(reportId: nonAutoUploadOperation.report?.id)
        }

        if let operation: AutoUpload = activeOperations.first(where:{$0.type == .autoUpload }) as? AutoUpload {
            operation.addFile(file:file)
        }
    }
    
    func sendUnsentReports(mainAppModel:MainAppModel) {
        
        guard let unsentReports = mainAppModel.tellaData?.getUnsentReports() else { return }
        
        unsentReports.forEach { report in
            let urlSession = URLSession(
                configuration: report.server?.backgroundUpload ?? false ? .background(withIdentifier: "org.wearehorizontal.tella") : .default ,
                delegate: self,
                delegateQueue: nil)
            
            let operation = UploadReportOperation(report: report, urlSession: urlSession, mainAppModel: mainAppModel, type: .unsentReport)
            activeOperations.append(operation)
            uploadQueue.addOperation(operation)
            
            displayReportToast(operation:operation)
        }
    }
    
    func displayReportToast(operation:BaseUploadOperation) {
        
        operation.response.sink(receiveCompletion: { completion in
        }, receiveValue: { response in
            self.handleReportResponse(response:response)
        }).store(in: &subscribers)
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
            
            let operation = activeOperations.first{$0.uploadTasksDict[task] != nil}
            operation?.update(responseFromDelegate: URLSessionTaskResponse(current: Int(totalBytesSent), task: task as? URLSessionUploadTask))
        }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = AppDelegate.instance,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let operation = activeOperations.first{$0.uploadTasksDict[dataTask] != nil}
        operation?.update(responseFromDelegate: URLSessionTaskResponse(task: dataTask , data: data, response: dataTask.response as? HTTPURLResponse))
        operation?.uploadTasksDict.removeValue(forKey: dataTask)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let operation = activeOperations.first{$0.uploadTasksDict[task] != nil}
        if error == nil {
            
            operation?.update(responseFromDelegate: URLSessionTaskResponse(task: task , data: nil, response: task.response as? HTTPURLResponse))
            
        } else if let _ = (error as? NSError)?.code {
            operation?.update(responseFromDelegate: URLSessionTaskResponse(task: task , data: nil, response: nil, error: error))
            
        } else {
            operation?.update(responseFromDelegate: URLSessionTaskResponse(task: task , data: nil, response: nil, error: error))
            
        }
    }
}


