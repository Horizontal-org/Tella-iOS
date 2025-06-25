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
    
    var trustedPublicKeyHash : String?
    var path: String?
    var onReceiveServerPublicKeyHash: ((String) -> Void)?
    var response = CurrentValueSubject<P2PUploadResponse, APIError>(.initial)
    
    init(path: String?, trustedPublicKeyHash: String? = nil, onReceiveServerPublicKeyHash: ((String) -> Void)? = nil) {
        self.path = path
        self.trustedPublicKeyHash = trustedPublicKeyHash
        self.onReceiveServerPublicKeyHash = onReceiveServerPublicKeyHash
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progressInfo = P2PUploadProgressInfo(bytesSent: totalBytesSent,
                                                 current:totalBytesExpectedToSend)
        response.send(P2PUploadResponse.progress(progressInfo:progressInfo))
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        debugLog("didReceive data \(data.string())")

    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugLog("didCompleteWithError error \(String(describing: error))")
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
            debugLog("Missing serverTrust for host: \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let publicKeyData = extractPublicKey(from: serverTrust) else {
            debugLog("Failed to extract public key from serverTrust for host: \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverPublicKeyHash = publicKeyData.sha256()
        debugLog("Received server public key hash: \(serverPublicKeyHash)")
        debugLog("Expected trusted public key hash: \(trustedPublicKeyHash ?? "nil")")
        
        // No trusted public key hash: potentially first connection
        guard let trustedHash = trustedPublicKeyHash else {
            if path == PeerToPeerEndpoint.ping.rawValue {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                onReceiveServerPublicKeyHash?(serverPublicKeyHash)
            } else {
                debugLog("No trusted hash and path is non-nil; canceling authentication.")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            return
        }
        
        // Compare hashes
        guard trustedHash == serverPublicKeyHash else {
            debugLog("Public key hash mismatch! Expected \(trustedHash), got \(serverPublicKeyHash)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
    
    func extractPublicKey(from trust: SecTrust) -> Data? {
        guard let certificate = SecTrustGetCertificateAtIndex(trust, 0),
              let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return nil
        }
        return publicKeyData
    }
}
