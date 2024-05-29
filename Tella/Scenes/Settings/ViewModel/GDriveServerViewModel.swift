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
    var mainAppModel : MainAppModel
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var sharedDrives: [SharedDrive] = []

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared, mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.gDriveRepository = repository
        restorePreviousSignIn()
    }

    func restorePreviousSignIn() {
        Task {
            do {
                try await gDriveRepository.restorePreviousSignIn()
                self.getSharedDrives()
            } catch let error {
                Toast.displayToast(message: error.localizedDescription)
            }
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
                    debugLog(error)
                    Toast.displayToast(message: error.localizedDescription)
                }
            },
            receiveValue: { [weak self] drives in
                self?.sharedDrives = drives
            })
            .store(in: &cancellables)
    }
    
    
    func createDriveFolder(folderName: String, completion: @escaping () -> Void) {
        gDriveRepository.createDriveFolder(
            googleUser: self.googleUser,
            folderName: folderName) { folderName in
                self.addServer(rootFolder: folderName) {
                    completion()
                }
            }
    }
    
    func addServer(rootFolder: String, completion: @escaping() -> Void ) {
        let server = GDriveServer(rootFolder: rootFolder)

        _ = mainAppModel.tellaData?.addGDriveServer(server: server)
        
        completion()
    }
}
