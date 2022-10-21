//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ReportsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var currentReportVM : ReportVM = ReportVM()
    
    // Server list
    @Published var servers : [Server] = []
    
    init(mainAppModel : MainAppModel) {
        self.mainAppModel = mainAppModel
        getServers()
    }
    
    func getServers() {
        servers = mainAppModel.vaultManager.tellaData.getServers()
    }
}

class ReportVM {
    
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files : [VaultFile] = []
    
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    
    @Published var shouldShowError : Bool = false
    
    @Published var reportIsValid : Bool = false
    @Published var reportIsDraft : Bool = false
    
    
    var cancellable : Cancellable? = nil
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        cancellable = $isValidTitle.combineLatest($isValidDescription).sink(receiveValue: { isValidTitle, isValidDescription in
            self.reportIsValid = isValidTitle && isValidDescription
        })
        
        $isValidTitle.combineLatest($isValidDescription, $files).sink(receiveValue: { isValidTitle, isValidDescription, files in
            self.reportIsDraft = isValidTitle || isValidDescription || !files.isEmpty
        }).store(in: &subscribers)
    }
    
}
