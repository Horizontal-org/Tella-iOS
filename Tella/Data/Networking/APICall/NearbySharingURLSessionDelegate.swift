//
//  NearbySharingURLSessionDelegate.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//
import Foundation
import Combine

class NearbySharingURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    var trustedCertificateHash : String?
    var path: String?
    var onReceiveServerCertificateHash: ((String) -> Void)?
    var response = CurrentValueSubject<NearbySharingUploadResponse, APIError>(.initial)
    
    init(path: String?, trustedCertificateHash: String? = nil, onReceiveServerCertificateHash: ((String) -> Void)? = nil) {
        self.path = path
        self.trustedCertificateHash = trustedCertificateHash
        self.onReceiveServerCertificateHash = onReceiveServerCertificateHash
    }
    
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        response.send(NearbySharingUploadResponse.didCreateTask(task: task))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        response.send(NearbySharingUploadResponse.progress(progress:Int(bytesSent)))
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        if let error = error as? NSError {
            response.send(completion: .failure(APIError.httpCode(error.code)))
            return
        }
        
        guard let httpResponse = task.response as? HTTPURLResponse else {
            response.send(completion: .failure(APIError.unexpectedResponse))
            return
        }
        
        let statusCode = httpResponse.statusCode
        
        guard HTTPCodes.success.contains(statusCode) else {
            response.send(completion: .failure(APIError.httpCode(statusCode)))
            return
        }
        response.send(completion: .finished)
    }
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        var disposition: URLSession.AuthChallengeDisposition = .cancelAuthenticationChallenge
        var credential: URLCredential?
        
        defer {
            completionHandler(disposition, credential)
        }
        
        let protectionSpace = challenge.protectionSpace
        
        guard let serverTrust = protectionSpace.serverTrust else {
            debugLog("Missing serverTrust")
            return
        }
        
        guard let certificateData = extractCertificateData(from: serverTrust) else {
            debugLog("Failed to extract certificate data")
            return
        }
        
        let serverCertificateHash = certificateData.sha256()
        
        // First-contact flow allowed only for ping
        guard let trustedHash = trustedCertificateHash else {
            guard path == NearbySharingEndpoint.ping.rawValue else {
                debugLog("No trusted hash for non-ping request")
                return
            }
            
            disposition = .useCredential
            credential = URLCredential(trust: serverTrust)
            onReceiveServerCertificateHash?(serverCertificateHash)
            return
        }
        guard trustedHash == serverCertificateHash else {
            debugLog("Certificate hash mismatch")
            return
        }
        disposition = .useCredential
        credential = URLCredential(trust: serverTrust)
    }
    
    private func extractCertificateData(from trust: SecTrust) -> Data? {
        guard let certificate = SecTrustGetCertificateAtIndex(trust, 0) else {
            return nil
        }
        return SecCertificateCopyData(certificate) as Data
    }
}
