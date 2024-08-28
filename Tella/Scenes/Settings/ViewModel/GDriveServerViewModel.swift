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
    var serverCreateFolderVM: ServerCreateFolderViewModel

    @Published var selectedDrive: SharedDrive? = nil
    @Published var sharedDriveState: ViewModelState<[SharedDrive]> = .loading
    
    init(repository: GDriveRepositoryProtocol, mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.gDriveRepository = repository   
        self.serverCreateFolderVM = ServerCreateFolderViewModel(headerViewSubtitleText: LocalizableSettings.gDriveCreatePersonalFolderDesc.localized, imageIconName: "gdrive.icon")

        self.serverCreateFolderVM.createFolderAction = createDriveFolder
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
    
    func createDriveFolder() {
        self.serverCreateFolderVM.createFolderState = .loading
        let folderName = serverCreateFolderVM.folderName
        
        gDriveRepository.createDriveFolder(folderName: folderName, parentId: nil, description: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.serverCreateFolderVM.createFolderState = .error(error.errorMessage)
                }
            }, receiveValue: { folderId in
                self.addServer(rootFolder: folderId, rootFolderName: folderName) //TODO: We should handle the failure case
                self.serverCreateFolderVM.createFolderState = .loaded(true)
            })
            .store(in: &cancellables)
    }
    
    func addServer(rootFolder: String, rootFolderName: String) { //TODO:  Must check failure
        let server = GDriveServer(rootFolder: rootFolder, rootFolderName: rootFolderName)
        _ = mainAppModel.tellaData?.addGDriveServer(server: server)
    }
    
    func handleSelectedDrive(drive: SharedDrive) -> Void {
        self.selectedDrive = drive
    }
}
