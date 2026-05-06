//
//  ServerCreateFolderViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Combine
class ServerCreateFolderViewModel: ObservableObject {
    
    var headerViewSubtitleText: String = ""
    var imageIconName: ImageResource
    
    // Create Folder
    @Published var createFolderState: ViewModelState<Bool> = .loaded(false)
    @Published var createFolderAction: (() -> ())?
    
    @Published var folderName : String = ""
    @Published var shouldShowError : Bool = false
    @Published var errorMessage: String = ""
    
    init(headerViewSubtitleText: String, imageIconName: ImageResource) {
        self.headerViewSubtitleText = headerViewSubtitleText
        self.imageIconName = imageIconName
    }
    
}
