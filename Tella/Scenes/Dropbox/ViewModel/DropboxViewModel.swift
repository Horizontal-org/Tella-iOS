//
//  DropboxViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class DropboxViewModel: ReportsMainViewModel {
    var dropboxRepository: DropboxRepositoryProtocol
    
    init(mainAppModel: MainAppModel, dropboxRepository: DropboxRepositoryProtocol) {
        self.dropboxRepository = dropboxRepository
        super.init(mainAppModel: mainAppModel, connectionType: .dropbox, title: "Dropbox")
        
        
    }
}
