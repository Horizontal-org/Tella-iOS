//
//  GDriveServerViewModel.swift
//  Tella
//
//  Created by gus valbuena on 5/22/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

enum ViewModelState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case error(String)
    
    static func == (lhs: ViewModelState<T>, rhs: ViewModelState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

class GDriveServerViewModel: ObservableObject {
    var mainAppModel : MainAppModel
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var selectedDrive: SharedDrive? = nil
    @Published var sharedDriveState: ViewModelState<[SharedDrive]>? = nil
    @Published var createFolderState: ViewModelState<String>? = nil
    
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
        self.sharedDriveState = .loading
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
    
    
    func createDriveFolder(folderName: String, completion: @escaping () -> Void) {
        self.createFolderState = .loading
        gDriveRepository.createDriveFolder(folderName: folderName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.createFolderState = .error(error.localizedDescription)
                }
            }, receiveValue: { folderId in
                self.createFolderState = .loaded(folderId)
                self.addServer(rootFolder: folderId) {
                    completion()
                }
            })
            .store(in: &cancellables)
    }
    
    func addServer(rootFolder: String, completion: @escaping() -> Void ) {
        let server = GDriveServer(rootFolder: rootFolder)

        _ = mainAppModel.tellaData?.addGDriveServer(server: server)
        
        completion()
    }
    
    func handleSelectedDrive(drive: SharedDrive) -> Void {
        self.selectedDrive = drive
    }
}
