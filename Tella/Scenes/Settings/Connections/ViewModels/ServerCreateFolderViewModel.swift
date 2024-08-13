//
//  ServerCreateFolderViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine
class ServerCreateFolderViewModel: ObservableObject {
    
    var textFieldPlaceholderText: String = ""
    var headerViewTitleText: String = ""
    var headerViewSubtitleText: String = ""
    var imageIconName: String = ""
    
    // Create Folder
    @Published var createFolderState: ViewModelState<Bool> = .loaded(false)
    @Published var createFolderAction: (() -> ())?
    
    @Published var folderName : String = ""
    @Published var shouldShowError : Bool = false
    @Published var errorMessage: String = ""
    
    init(textFieldPlaceholderText: String, headerViewTitleText: String, headerViewSubtitleText: String, imageIconName: String) {
        self.textFieldPlaceholderText = textFieldPlaceholderText
        self.headerViewTitleText = headerViewTitleText
        self.headerViewSubtitleText = headerViewSubtitleText
        self.imageIconName = imageIconName
    }
    
}
