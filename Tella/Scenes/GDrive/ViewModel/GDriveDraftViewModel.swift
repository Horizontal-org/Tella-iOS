//
//  GDriveDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class GDriveDraftViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    private let gDriveRepository: GDriveRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var server: GDriveServer?
    
    @Published var title: String = ""
    @Published var description: String = ""
    
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    @Published var shouldShowError : Bool = false
    
    init(mainAppModel: MainAppModel, repository: GDriveRepositoryProtocol) {
        self.mainAppModel = mainAppModel
        self.gDriveRepository = repository
        self.getServer()
    }
    
    func submitReport() {
        gDriveRepository.createDriveFolder(folderName: title, parentId: server?.rootFolder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        debugLog(error)
                    }
                },
                receiveValue: { result in
                    dump(result)
                }
            ).store(in: &cancellables)
    }
    
    private func getServer() {
        self.server = mainAppModel.tellaData?.gDriveServers.value.first
    }
}
