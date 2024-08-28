//
//  ReportMainViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class ReportsMainViewModel: ObservableObject {
    
    @Published var draftReportsViewModel : [CommonCardViewModel] = []
    @Published var outboxedReportsViewModel : [CommonCardViewModel] = []
    @Published var submittedReportsViewModel : [CommonCardViewModel] = []
    
    @Published var selectedPage: Page = .draft
    
    @Published var isLoading: Bool = false
    @Published var shouldShowToast : Bool = false
    @Published var toastMessage : String = ""
    
    var pageViewItems : [PageViewItem] {
        
        [PageViewItem(title: LocalizableUwazi.uwaziPageViewDraft.localized,
                      page: .draft,
                      number: draftReportsViewModel.count),
         PageViewItem(title: LocalizableUwazi.uwaziPageViewOutbox.localized,
                      page: .outbox,
                      number: outboxedReportsViewModel.count),
         PageViewItem(title: LocalizableUwazi.uwaziPageViewSubmitted.localized,
                      page: .submitted,
                      number: submittedReportsViewModel.count)]
    }
    
    var mainAppModel : MainAppModel
    
    var tellaData: TellaData? {
        return self.mainAppModel.tellaData
    }
    
    var subscribers = Set<AnyCancellable>()
    
    var connectionType : ServerConnectionType
    var title : String

    init(mainAppModel : MainAppModel, connectionType : ServerConnectionType, title:String) {
        
        self.mainAppModel = mainAppModel
        self.connectionType = connectionType
        self.title = title

        self.getReports()
        self.listenToUpdates()
    }
    
    func getReports() {
    }
    
    func listenToUpdates() {
    }
}


