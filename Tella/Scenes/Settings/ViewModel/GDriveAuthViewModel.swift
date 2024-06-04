//
//  GDriveAuthViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveAuthViewModel: ObservableObject {
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
        self.gDriveRepository = repository
    }

    func handleSignIn(completion: @escaping () -> Void) {
        gDriveRepository.handleSignIn()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        Toast.displayToast(message: error.localizedDescription)
                        break
                    }
                },
                receiveValue: {_ in 
                    completion()
                }
            ).store(in: &cancellables)
    }

    func restorePreviousSignIn() {
        gDriveRepository.restorePreviousSignIn()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch(completion) {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)
    }

    func handleUrl(url: URL) {
        gDriveRepository.handleUrl(url: url)
    }
}
