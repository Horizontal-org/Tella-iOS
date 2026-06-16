//
//  ManualPingSession.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/6/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//
import Combine
import Foundation

/// In-flight manual ping: receiver hash from TLS; `senderShowHash` from the held HTTP body after recipient confirms.
final class ManualPingSession {
    let receiverCertificateHash: AnyPublisher<String, Error>
    private let senderShowHashSource: AnyPublisher<Bool, Error>
    private let task: URLSessionTask
    private var cachedSenderShowHash: Bool?
    private var cacheCancellable: AnyCancellable?
    
    init(
        receiverCertificateHash: AnyPublisher<String, Error>,
        senderShowHash: AnyPublisher<Bool, Error>,
        task: URLSessionTask
    ) {
        self.receiverCertificateHash = receiverCertificateHash
        self.senderShowHashSource = senderShowHash
        self.task = task
        cacheCancellable = senderShowHashSource
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] value in
                self?.cachedSenderShowHash = value
            })
    }
    
    func senderShowHashResponse() -> AnyPublisher<Bool, Error> {
        if let cachedSenderShowHash {
            return Just(cachedSenderShowHash)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return senderShowHashSource
            .handleEvents(receiveOutput: { [weak self] value in
                self?.cachedSenderShowHash = value
            })
            .eraseToAnyPublisher()
    }
    
    func cancel() {
        cacheCancellable?.cancel()
        cacheCancellable = nil
        task.cancel()
    }
}
