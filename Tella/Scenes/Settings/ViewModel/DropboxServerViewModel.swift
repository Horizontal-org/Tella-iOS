//
//  DropboxServerViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/9/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxServerViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    private let dropboxRepository: DropboxRepositoryProtocol
    
    init(repository: DropboxRepositoryProtocol, mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.dropboxRepository = repository
    }
    
    func addServer() {
        // add server connection
    }
}
