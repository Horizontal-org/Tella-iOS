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
    
    var activeDownloads : [URLSessionTask: CurrentValueSubject<(UploadResponse), APIError>] = [ : ]
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    var hasFilesToUploadOnBackground: Bool {
        let array = activeDownloads.values.filter { item -> Bool in
            switch item.value {
            case .progress(let download):
                return download.isOnBackground == true
            default:
                return false
            }
        }
        return array.count > 0
    }
    
    func pauseDownload(endpoint: APIRequest) {
        
        activeDownloads.forEach({ item in
            
            switch item.value.value {
                
            case .progress(let download):
                guard download.isDownloading else {
                    return
                }
                download.task?.cancel()
                activeDownloads[item.key] = nil
                
            default:
                break
            }
            
        })
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
        
        download.isDownloading = true
        
        activeDownloads[download.task!] = CurrentValueSubject(.progress(progressInfo: download))
        
        return download.task!
    }
    
    func clearDownloads() {
        activeDownloads.removeAll()
    }
    
    
    func call(endpoint: APIRequest, isOnBackground: Bool) -> URLSessionTask? {
        
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            let task = endpoint.uploadsSession?.dataTask(with: request)
            activeDownloads[task!] = CurrentValueSubject(.initial)
            task?.resume()
            return task
            
        } catch {
            return nil
        }
    }
}
