//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import UIKit


class UploadService {
    
    // MARK: - Variables And Properties
    //
    static var shared : UploadService = UploadService()
    
    var activeTasks : [URLSessionTask: CurrentValueSubject<(UploadResponse), APIError>] = [ : ]
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    var hasFilesToUploadOnBackground: Bool {
        let array = activeTasks.values.filter { item -> Bool in
            switch item.value {
            case .progress(let download):
                return download.isOnBackground == true
            case .initial(let isOnBackGround):
                return isOnBackGround == true
            default:
                return false
            }
        }
        return array.count > 0
    }
    
    func pauseDownload(endpoint: APIRequest) { // TO FIX
        
        activeTasks.forEach({ item in
            
            switch item.value.value {
                
            case .progress(let download):
                download.task?.cancel()
                activeTasks[item.key] = nil
                
            default:
                break
            }
        })
    }
    
    func cancelTasksIfNeeded() {
        
        activeTasks.forEach { item in
            
            switch item.value.value {
            case .progress(let download):
                if !download.isOnBackground {
                    // TO FIX Update the report status ?
                    download.task?.cancel()
                    activeTasks[item.key] = nil
                }
            case .initial(let isOnBackground):
                if !isOnBackground {
                    let task = item.key
                    task.cancel()
                    activeTasks[task] = nil
                }
            default:
                break
            }
        }
    }
    
    func startDownload(endpoint: APIRequest, isOnBackground: Bool) -> URLSessionTask? {
        
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            return nil
        }
        
        let download = UploadProgressInfo(fileId: endpoint.fileToUpload?.fileId, url: url,status: .notSubmitted, isOnBackground: isOnBackground)
        
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            guard let fileURL = endpoint.fileToUpload?.url else {
                return nil
            }
            download.task = endpoint.uploadsSession?.uploadTask(with: request, fromFile: fileURL)
            
        } catch {
            
        }
        
        download.task?.resume()
        
        activeTasks[download.task!] = CurrentValueSubject(.progress(progressInfo: download))
        
        return download.task!
    }
    
    func call(endpoint: APIRequest, isOnBackground: Bool) -> URLSessionTask? {
        
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            let task = endpoint.uploadsSession?.dataTask(with: request)
            activeTasks[task!] = CurrentValueSubject(.initial(isOnBackground: isOnBackground))
            task?.resume()
            return task
            
        } catch {
            return nil
        }
    }
}
