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
        self.serverCreateFolderVM = ServerCreateFolderViewModel(textFieldPlaceholderText: LocalizableSettings.GDriveCreatePersonalFolderPlaceholder.localized,
                                                                headerViewTitleText: LocalizableSettings.GDriveCreatePersonalFolderTitle.localized,
                                                                headerViewSubtitleText: LocalizableSettings.GDriveCreatePersonalFolderDesc.localized, imageIconName: "gdrive.icon")

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
                    self.sharedDriveState = .error(error.localizedDescription)
                }
            },
            receiveValue: { [weak self] drives in
                self?.sharedDriveState = .loaded(drives)
            })
            .store(in: &cancellables)
    }
    
    func createDriveFolder() {
        self.serverCreateFolderVM.createFolderState = .loading
        gDriveRepository.createDriveFolder(folderName: serverCreateFolderVM.folderName, parentId: nil, description: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.serverCreateFolderVM.createFolderState = .error(error.localizedDescription)
                }
            }, receiveValue: { folderId in
                self.addServer(rootFolder: folderId) //TODO: We should handle the failure case
                self.serverCreateFolderVM.createFolderState = .loaded(true)
            })
            .store(in: &cancellables)
    }
    
    func addServer(rootFolder: String) { //TODO:  Must check failure
        let server = GDriveServer(rootFolder: rootFolder)
        _ = mainAppModel.tellaData?.addGDriveServer(server: server)
    }
    
    func handleSelectedDrive(drive: SharedDrive) -> Void {
        self.selectedDrive = drive
    }
}
