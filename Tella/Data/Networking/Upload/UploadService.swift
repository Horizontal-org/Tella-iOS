//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine


class UploadService {
    
    // MARK: - Variables And Properties
    //
    static var shared : UploadService = UploadService()
    
    var activeDownloads : [URL: CurrentValueSubject<UploadResponse, APIError>] = [ : ]
    
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
        
        guard let  url = endpoint.url else {
            return
        }
        
        switch activeDownloads[url]?.value {
            
        case .progress(let download):
            guard download.isDownloading else {
                return
            }
            download.task?.cancel()
            activeDownloads[url] = nil
            
        default:
            break
        }
    }
    
    func startDownload(endpoint: APIRequest, isOnBackground: Bool) {
        
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            return
        }
        
        if activeDownloads[url]?.value != nil {
            activeDownloads[url] = nil
        }
        
        let download = UploadProgressInfo(fileId: endpoint.fileToUpload?.fileId, url: url,status: .notSubmitted, isOnBackground: isOnBackground)
        
        do {
            let request = try endpoint.urlRequest()
            request.curlRepresentation()
            guard let fileURL = endpoint.fileToUpload?.url else {
                return
            }
            download.task = endpoint.uploadsSession?.uploadTask(with: request, fromFile: fileURL)
            
        } catch {
            
        }
        
        download.task?.resume()
        
        download.isDownloading = true
        
        activeDownloads[url] = CurrentValueSubject(.progress(progressInfo: download))
    }
    
    func clearDownloads() {
        activeDownloads.removeAll()
    }
}
