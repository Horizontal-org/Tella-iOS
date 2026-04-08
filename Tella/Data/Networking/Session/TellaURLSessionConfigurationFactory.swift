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

    /// Short timeouts, no connectivity wait   / Nearby Sharing HTTP to a peer
    func makeNearbySharing() -> URLSessionConfiguration

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
    
    func makeNearbySharing() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 10
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
