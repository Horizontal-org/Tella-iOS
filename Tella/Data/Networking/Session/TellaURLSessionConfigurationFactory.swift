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
    /// Configuration for background uploads.
    func makeBackground(identifier: String) -> URLSessionConfiguration
}

final class TellaURLSessionConfigurationFactory: URLSessionConfigurationFactoryProtocol {

    func makeDefault() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }

    func makeBackground(identifier: String) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.sessionSendsLaunchEvents = true
        config.shouldUseExtendedBackgroundIdleMode = true
        config.isDiscretionary = false
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        return config
    }}
