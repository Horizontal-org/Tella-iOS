//
//  FormChangeTracker.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

/// Generic form state helper that tracks whether watched fields changed.
@MainActor
final class FormChangeTracker: ObservableObject {
    @Published private(set) var hasChanges: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var isTrackingEnabled = false

    func track(_ publishers: [AnyPublisher<Void, Never>]) {
        cancellables.removeAll()

        Publishers.MergeMany(publishers)
            .sink { [weak self] in
                guard let self else { return }
                guard self.isTrackingEnabled else { return }
                self.hasChanges = true
            }
            .store(in: &cancellables)
    }

    func markClean() {
        hasChanges = false
        isTrackingEnabled = true
    }

    func pauseTracking() {
        isTrackingEnabled = false
    }

    func resumeTracking() {
        isTrackingEnabled = true
    }
}

extension Publisher {
    /// Convert any publisher into `Void` events where only change notifications matter.
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        map { _ in () }.eraseToAnyPublisher()
    }
}
