//
//  TellaURLSessionConfigurationFactory.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/3/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

protocol URLSessionConfigurationFactoryProtocol {
    /// Configuration for API calls and foreground uploads
    func makeDefault() -> URLSessionConfiguration
    
    /// Configuration for nearby sharing file uploads on the local network
    /// Longer than connect requests to better tolerate large file transfer setup
    func makeNearbySharingUploadLocal() -> URLSessionConfiguration
    
    /// Configuration for nearby sharing local API requests (hash/register/prepare/close)
    func makeNearbySharingLocal() -> URLSessionConfiguration
    
    /// Configuration for background uploads.
    func makeBackground(identifier: String) -> URLSessionConfiguration
    
}

final class TellaURLSessionConfigurationFactory: URLSessionConfigurationFactoryProtocol {
    
    func makeDefault() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 60
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }
    
    func makeNearbySharingUploadLocal() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 30
        config.allowsCellularAccess = false
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }
    
    func makeNearbySharingLocal() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 10
        config.allowsCellularAccess = false
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }
    
    func makeBackground(identifier: String) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 60
        config.sessionSendsLaunchEvents = true
        config.shouldUseExtendedBackgroundIdleMode = true
        config.isDiscretionary = false
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }
}
