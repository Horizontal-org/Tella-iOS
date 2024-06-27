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
    func login() //async throws
    func checkServer()
}



class NextCloudRepository {
    
    private let kRemotePhpFiles = "remote.php/dav/files/"
    let configServerUrl = "https://cloud.wearehorizontal.org/"
    let configUsername = ""
    let configPassword = ""

    
    init() {
        // Setup should be checked if the server is already in Database or not
        setUp()
    }
    
    func setUp() {
        NextcloudKit.shared.setup(account: self.configUsername, user: self.configUsername, userId: self.configUsername , password: self.configPassword, urlBase: self.configServerUrl  )
    }
    
    func checkServer(serverUrl: String) {
        NextcloudKit.shared.checkServer(serverUrl: configServerUrl) { error in
            print(error)
            if error == .success {
                print("success")
            }else {
                print("failure")
            }
        }
    }
    
    func createFolder() {
        var fullURL = self.configServerUrl + self.kRemotePhpFiles + "username"  + "/foldername"
        print(fullURL)
        NextcloudKit.shared.createFolder(serverUrlFileName: fullURL) { account, ocId, date, error in
            print(account, "account")
        }
    }
    
}
