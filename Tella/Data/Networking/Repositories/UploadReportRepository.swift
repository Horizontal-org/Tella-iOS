//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit

enum UploadResponse {
    case progress(progressInfo: UploadProgressInfo)
    case response(data: FileDTO)
}

extension ReportRepository:URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64 ) {
            
            guard let url = task.currentRequest?.url else { return }
            guard let uploadProgressInfo =  UploadService.shared.activeDownloads[url] else { return }
            
            switch uploadProgressInfo.value {
            case .progress(let progressInfo):
                progressInfo.current = Int(totalBytesSent)
                progressInfo.size = Int(totalBytesExpectedToSend)
                progressInfo.status = .partialSubmitted
                uploadProgressInfo.value = .progress(progressInfo: progressInfo)
                break
            default:
                break
            }
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
        
        guard let url = dataTask.currentRequest?.url else { return }
        guard let uploadProgressInfo =  UploadService.shared.activeDownloads[url] else { return }
        
        do {
            debugLog(data.string())
            let response: FileDTO  = try  data.decoded()
            uploadProgressInfo.value = .response(data: response)
            uploadProgressInfo.send(completion: .finished)
        } catch {
            uploadProgressInfo.send(completion: .failure(.unexpectedResponse))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let url = task.currentRequest?.url else { return }
        guard let uploadProgressInfo = UploadService.shared.activeDownloads[url] else { return }
        
        switch uploadProgressInfo.value {
        case .progress(let progressInfo):
            progressInfo.status = .notSubmitted
            uploadProgressInfo.value = .progress(progressInfo: progressInfo)
            break
        default:
            break
        }
        uploadProgressInfo.send(completion: .failure(.unexpectedResponse))
    }
    
}

