//
//  FileTransferVM.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine

enum TransferViewAction {
    case none
    case transferIsFinished
    case filesAreSaved
}

class FileTransferVM: ObservableObject {
    
    var mainAppModel: MainAppModel
    
    @Published var progressViewModel : ProgressViewModel?
    
    @Published var isLoading: Bool = false
    @Published var viewAction: TransferViewAction = .none

    
    var title: String
    
    var bottomSheetTitle: String
    
    var bottomSheetMessage: String

    init(mainAppModel: MainAppModel,
         title: String,
         bottomSheetTitle: String,
         bottomSheetMessage: String) {
        
        self.mainAppModel = mainAppModel
        self.title = title
        self.bottomSheetTitle = bottomSheetTitle
        self.bottomSheetMessage = bottomSheetMessage
        self.bottomSheetMessage = bottomSheetMessage
    }
    
    func stopTask() {
        
    }
}

extension FileTransferVM {
    static func stub() -> FileTransferVM {
        return FileTransferVM(mainAppModel: MainAppModel.stub(), title: "Title", bottomSheetTitle: "Title", bottomSheetMessage: "Message")
    }
}

