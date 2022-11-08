//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ReportsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    var selectedReport : Report?
    
    @Published var draftReports : [Report] = []
    @Published var outboxedReports : [Report] = []
    @Published var submittedReports : [Report] = []
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel : MainAppModel) {
        self.mainAppModel = mainAppModel
        
        self.mainAppModel.vaultManager.tellaData.draftReports.sink { result in
        } receiveValue: { draftReports in
            self.draftReports = draftReports
        }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData.outboxedReports.sink { result in
        } receiveValue: { draftReports in
            self.outboxedReports = draftReports
        }.store(in: &subscribers)
        
        self.mainAppModel.vaultManager.tellaData.submittedReports.sink { result in
        } receiveValue: { draftReports in
            self.submittedReports = draftReports
        }.store(in: &subscribers)
    }
    
    func deleteReport() {
        do {
            try _ = mainAppModel.vaultManager.tellaData.deleteReport(reportId: selectedReport?.id)
        } catch {
            
        }
    }
    
}
