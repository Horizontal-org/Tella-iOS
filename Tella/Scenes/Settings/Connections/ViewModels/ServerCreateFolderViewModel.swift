//
//  ServerCreateFolderViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
class ServerCreateFolderViewModel: ObservableObject {
    
    var headerViewSubtitleText: String = ""
    var imageIconName: String = ""
    
    // Create Folder
    @Published var createFolderState: ViewModelState<Bool> = .loaded(false)
    @Published var createFolderAction: (() -> ())?
    
    @Published var folderName : String = ""
    @Published var shouldShowError : Bool = false
    @Published var errorMessage: String = ""
    
    init(headerViewSubtitleText: String, imageIconName: String) {
        self.headerViewSubtitleText = headerViewSubtitleText
        self.imageIconName = imageIconName
    }
    
}
