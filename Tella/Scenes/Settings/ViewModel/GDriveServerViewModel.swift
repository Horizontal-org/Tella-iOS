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

    @Published var selectedDrive: SharedDrive? = nil
    @Published var sharedDriveState: ViewModelState<[SharedDrive]> = .loading
    @Published var createFolderState: ViewModelState<String> = .loaded("")
    
    init(repository: GDriveRepositoryProtocol, mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.gDriveRepository = repository
    }

    func getSharedDrives() {
        gDriveRepository.getSharedDrives()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                switch completion {
                case .finished:
                    break
                case.failure(let error):
                    self.sharedDriveState = .error(error.errorMessage)
                }
            },
            receiveValue: { [weak self] drives in
                self?.sharedDriveState = .loaded(drives)
            })
            .store(in: &cancellables)
    }
    
    
    func createDriveFolder(folderName: String, completion: @escaping () -> Void) {
        self.createFolderState = .loading
        gDriveRepository.createDriveFolder(folderName: folderName, parentId: nil, description: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.createFolderState = .error(error.errorMessage)
                }
            }, receiveValue: { folderId in
                self.createFolderState = .loaded(folderId)
                self.addServer(rootFolder: folderId, rootFolderName: folderName) {
                    completion()
                }
            })
            .store(in: &cancellables)
    }
    
    func addServer(rootFolder: String, rootFolderName: String, completion: @escaping() -> Void ) {
        let server = GDriveServer(rootFolder: rootFolder, rootFolderName: rootFolderName)

        _ = mainAppModel.tellaData?.addGDriveServer(server: server)
        
        completion()
    }
    
    func handleSelectedDrive(drive: SharedDrive) -> Void {
        self.selectedDrive = drive
    }
}
