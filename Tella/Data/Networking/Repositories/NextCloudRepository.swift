//
//  NextCloudRepository.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import NextcloudKit
import Combine

protocol NextCloudRepositoryProtocol {
    func login(serverUrl: String, username: String, password: String) async throws
    func checkServer(serverUrl: String) async throws
    func createFolder(folderName: String) async throws
}

class NextCloudRepository: NextCloudRepositoryProtocol {
    
    private let kRemotePhpFiles = "remote.php/dav/files/"
    // Those attributes must be removed from here
    let configServerUrl = "https://cloud.wearehorizontal.org/"
    let configUsername = ""
    let configPassword = ""
    
    init() {
        // Setup should be checked if the server is already in Database or not
        setUp()
    }
    
    func setUp() {
        // Using 'configUsername', 'configServerUrl' and 'configServerUrl' from DB
        // We should check if server exist in database and retrieve data from DB
        NextcloudKit.shared.setup(account: self.configUsername, user: self.configUsername, userId: self.configUsername , password: self.configPassword, urlBase: self.configServerUrl  )
    }
    
    func checkServer(serverUrl: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.checkServer(serverUrl: serverUrl) { result in
                if result == .success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: RuntimeError(result.errorDescription))
                }
            }
        }
    }
    
    func login(serverUrl: String, username: String, password: String) async throws {
        NextcloudKit.shared.setup(account: username, user: username, userId: username , password: password, urlBase: serverUrl  )
        try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.getUserProfile { account, userProfile, data, result in
                if result == .success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: RuntimeError(result.errorDescription))
                }
            }
        }
    }

    
    func createFolder(folderName: String) {
        var fullURL = self.configServerUrl + self.kRemotePhpFiles + "username"  + "/" + folderName // This fullURL should be updated
        print(fullURL)
        NextcloudKit.shared.createFolder(serverUrlFileName: fullURL) { account, ocId, date, error in
            print(account, "account")
            // Save account in DB after creating the folder in Nextcloud
        }
    }
    
}
