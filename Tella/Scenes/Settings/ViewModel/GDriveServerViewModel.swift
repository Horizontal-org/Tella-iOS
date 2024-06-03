//
//  GDriveServerViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveServerViewModel: ObservableObject {
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var sharedDrives: [SharedDrive] = []

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
        self.gDriveRepository = repository
        restorePreviousSignIn()
    }

    func restorePreviousSignIn() {
        gDriveRepository.restorePreviousSignIn {
            self.getSharedDrives()
        }
    }

    func getSharedDrives() {
        gDriveRepository.getSharedDrives()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                switch completion {
                case .finished:
                    break
                case.failure(let error):
                    debugLog("error fetching drives: \(error.localizedDescription)")
                }
            },
            receiveValue: { [weak self] drives in
                self?.sharedDrives = drives
            })
            .store(in: &cancellables)
    }
}
