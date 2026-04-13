//
//  NetworkSessionProvider.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/3/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

/// Provides URLSessions for API calls and uploads. Centralizes session configuration.
final class NetworkSessionProvider {
    
    private let configurationFactory: URLSessionConfigurationFactoryProtocol = TellaURLSessionConfigurationFactory()
    
    /// Shared session for API calls
    private(set) lazy var apiSession: URLSession = {
        URLSession(configuration: configurationFactory.makeDefault())
    }()

    init() {}
    
    func makeDefaultUploadSession(delegate: URLSessionDelegate) -> URLSession {
        URLSession(
            configuration: configurationFactory.makeDefault(),
            delegate: delegate,
            delegateQueue: nil
        )
    }
    
    func makeBackgroundUploadSession(delegate: URLSessionDelegate) -> URLSession {
        URLSession(
            configuration: configurationFactory.makeBackground(identifier: UploadConstants.backgroundSessionIdentifier),
            delegate: delegate,
            delegateQueue: nil
        )
    }
}
