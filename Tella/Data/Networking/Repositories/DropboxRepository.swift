//
//  DropboxRepository.swift
//  Tella
//
//  Created by gus valbuena on 9/3/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import SwiftyDropbox

protocol DropboxRepositoryProtocol {
    func handleSignIn() async throws
    func ensureSignedIn() async throws
    func signOut()
    func uploadReport(title: String, description: String, files: [(URL, String)]) async throws
}

class DropboxRepository: DropboxRepositoryProtocol {
    private var client: DropboxClient?
    private var isCancelled = false
    private let networkMonitor: NetworkMonitor
    private var subscribers: Set<AnyCancellable> = []
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    
    init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
        setupNetworkMonitor()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.connectionDidChange.sink { isConnected in
            self.networkStatusSubject.send(isConnected)
        }.store(in: &subscribers)
    }
    
    func setupDropbox() {
        guard let dropboxAppKey = ConfigurationManager.getValue(DropboxAuthConstants.dropboxAppKey) else  {
            debugLog("Dropbox App Key not found")
            
            return
        }
        
        DropboxClientsManager.setupWithAppKey(dropboxAppKey)
    }
    
    func handleSignIn() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                let scopeRequest = ScopeRequest(scopeType: .user, scopes: [DropboxAuthConstants.filesContentRead, DropboxAuthConstants.filesContentWrite], includeGrantedScopes: false)
                
                DropboxClientsManager.authorizeFromControllerV2(
                    UIApplication.shared,
                    controller: UIApplication.shared.rootViewController,
                    loadingStatusDelegate: nil,
                    openURL: { (url: URL) -> Void in
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    },
                    scopeRequest: scopeRequest
                )
                continuation.resume()
            }
        }
    }
    
    func uploadReport(title: String, description: String, files: [(URL, String)]) async throws {
            try await ensureSignedIn()
            guard let client = self.client else {
                throw NSError(domain: "DropboxRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dropbox client is not initialized"])
            }
            
            let basePath = "/\(title)"
            
            // Create the report folder
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                client.files.createFolderV2(path: basePath).response { response, error in
                    if let error = error {
                        dump(error)
                        continuation.resume(throwing: error)
                    } else {
                        print("Folder created successfully at path: \(basePath)")
                        continuation.resume()
                    }
                }
            }
            
            // Upload description as a text file
            let descriptionData = description.data(using: .utf8) ?? Data()
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                client.files.upload(path: "\(basePath)/description.txt", input: descriptionData).response { response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        print("Description file uploaded successfully to path: \(basePath)/description.txt")
                        continuation.resume()
                    }
                }
            }
            
            // Upload each file
            for (fileURL, fileName) in files {
                let fileData = try Data(contentsOf: fileURL)
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    client.files.upload(path: "\(basePath)/\(fileName)", input: fileData).response { response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            print("File uploaded successfully to path: \(basePath)/\(fileName)")
                            continuation.resume()
                        }
                    }
                }
            }
        }

    
    func ensureSignedIn() async throws {
        if self.client == nil {
            if let client = DropboxClientsManager.authorizedClient {
                self.client = client
            } else {
                try await handleSignIn()
            }
        }
    }
    
    func signOut() {
        DropboxClientsManager.unlinkClients()
        client = nil
    }
}
