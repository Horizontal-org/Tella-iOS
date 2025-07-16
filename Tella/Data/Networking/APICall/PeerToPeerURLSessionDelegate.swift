//
//  PeerToPeerURLSessionDelegate.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//
import Foundation
import Combine

class PeerToPeerURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    var trustedCertificateHash : String?
    var path: String?
    var onReceiveServerCertificateHash: ((String) -> Void)?
    var response = CurrentValueSubject<P2PUploadResponse, APIError>(.initial)
    
    init(path: String?, trustedCertificateHash: String? = nil, onReceiveServerCertificateHash: ((String) -> Void)? = nil) {
        self.path = path
        self.trustedCertificateHash = trustedCertificateHash
        self.onReceiveServerCertificateHash = onReceiveServerCertificateHash
    }

    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        response.send(P2PUploadResponse.didCreateTask(task: task))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        response.send(P2PUploadResponse.progress(progress:Int(bytesSent)))
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            let nsError = error as NSError
            response.send(completion: .failure(APIError.httpCode(nsError.code)))
        } else {
            response.send(completion: .finished)
        }
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let protectionSpace = challenge.protectionSpace
        let host = protectionSpace.host
        
        guard let serverTrust = protectionSpace.serverTrust else {
            debugLog("Missing serverTrust for host")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let certificateData = extractCertificateData(from: serverTrust) else {
            debugLog("Failed to extract certificate data from serverTrust for host")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertificateHash = certificateData.sha256()
        
        // No trusted public key hash: potentially first connection
        guard let trustedHash = trustedCertificateHash else {
            if path == PeerToPeerEndpoint.ping.rawValue {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                onReceiveServerCertificateHash?(serverCertificateHash)
            } else {
                debugLog("No trusted hash and path is non-nil; canceling authentication.")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            return
        }
        
        // Compare hashes
        guard trustedHash == serverCertificateHash else {
            debugLog("Public key hash mismatch")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
    
    func extractCertificateData(from trust: SecTrust) -> Data? {
        guard let certificate = SecTrustGetCertificateAtIndex(trust, 0) else {
            return nil
        }
        let certificateData = SecCertificateCopyData(certificate)
        return Data(certificateData as Data)
    }
}
