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

    init(repository: GDriveRepositoryProtocol = GDriveRepository.shared) {
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
        guard let user = googleUser else {
            print("User not authenticated")
            return
        }
        
        let driveService = GTLRDriveService()
        driveService.authorizer = user.fetcherAuthorizer
        
        let folder = GTLRDrive_File()
        folder.name = folderName
        folder.mimeType = "application/vnd.google-apps.folder"
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        driveService.executeQuery(query) { (ticket, file, error) in
            if let error = error {
                print("Error creating folder: \(error.localizedDescription)")
                return
            }
            
            guard let createdFile = file as? GTLRDrive_File else {
                return
            }
            
            self.addServer(rootFolder: createdFile.identifier ?? "") {
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
