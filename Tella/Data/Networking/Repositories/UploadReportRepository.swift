//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias Output = (data: Data?, response: URLResponse)

enum UploadResponse {
    case initial(isOnBackground:Bool)
    case progress(progressInfo: UploadProgressInfo)
    case response(response: Output?)
}

enum APIResponse<Value> {
    case initial
    case response(response: Value?)
    case progress(progressInfo: UploadProgressInfo)
}

extension ReportRepository:URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64 ) {
            
            guard let uploadProgressInfo =  UploadService.shared.activeTasks[task] else { return }
            
            switch uploadProgressInfo.value {
            case .progress(let progressInfo):
                progressInfo.current = Int(totalBytesSent)
                progressInfo.status = .partialSubmitted
                uploadProgressInfo.value = .progress(progressInfo: progressInfo)
                print("totalBytesSent:", totalBytesSent)
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
        
        guard let uploadProgressInfo =  UploadService.shared.activeTasks[dataTask] else { return }
        
        debugLog(data.string())
        
        uploadProgressInfo.value = .response(response: (data ,dataTask.response as! HTTPURLResponse))
        uploadProgressInfo.send(completion: .finished)
        UploadService.shared.activeTasks[dataTask] = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let uploadProgressInfo = UploadService.shared.activeTasks[task] else { return }
        if error == nil {
            uploadProgressInfo.value = .response(response: (nil ,task.response as! HTTPURLResponse))
            uploadProgressInfo.send(completion: .finished)
        } else if let code = (error as? NSError)?.code {
            uploadProgressInfo.send(completion: .failure(APIError.httpCode(code)))
            
        } else {
            uploadProgressInfo.send(completion: .failure(.unexpectedResponse))
        }
        
        UploadService.shared.activeTasks[task] = nil
    }
}

