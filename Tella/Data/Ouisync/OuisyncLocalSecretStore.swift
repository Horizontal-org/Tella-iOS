//
//  OuisyncLocalSecretStore.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

final class OuisyncLocalSecretStore {
    
    private enum Constants {
        static let service = "org.horizontal.tella.ios.ouisync"
        static let account = "local-secret-key"
    }
    
    private let keychainStore = KeychainStore()

    func saveSecretKey(_ data: Data) -> Bool {
        
        return keychainStore.saveGenericPassword(
            data,
            service: Constants.service,
            account: Constants.account
        )
    }
    
    func recoverSecretKey() -> Data? {
        keychainStore.recoverGenericPassword(
            service: Constants.service,
            account: Constants.account
        )
    }
}
