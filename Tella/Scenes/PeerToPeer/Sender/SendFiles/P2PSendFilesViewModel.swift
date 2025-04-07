//
//  P2PSendFilesViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation

class P2PSendFilesViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel
    
    //MARK: -AddFilesViewModel
    @Published var addFilesViewModel: AddFilesViewModel
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.addFilesViewModel = AddFilesViewModel(mainAppModel: mainAppModel)
    }
    
    func prepareUpload() {

    }
    
}
