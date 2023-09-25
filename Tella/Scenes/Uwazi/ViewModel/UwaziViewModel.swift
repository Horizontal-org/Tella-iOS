//
//  UwaziViewModel.swift
//  Tella
//
//  Created by Gustavo on 25/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class UwaziViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel

    @Published var templates : [CollectedTemplate] = []
    @Published var downloadedTemplates : [CollectedTemplate] = []
    @Published var draftEntities : [Report] = []
    @Published var outboxedEntities : [Report] = []
    @Published var submittedEntities : [Report] = []
    @Published var selectedCell = Pages.templates
    @Published var pageViewItems : [PageViewItem] = [
        PageViewItem(title: LocalizableUwazi.uwaziPageViewTemplate.localized, page: .templates, number: ""),
        PageViewItem(title: LocalizableReport.draftTitle.localized, page: .draft, number: "") ,
        PageViewItem(title: LocalizableReport.outboxTitle.localized, page: .outbox, number: ""),
        PageViewItem(title: LocalizableReport.submittedTitle.localized, page: .submitted, number: "")
    ]
    @Published var isLoading: Bool = false
    @Published var serverName : String
    var server: Server

    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    init(mainAppModel : MainAppModel, server: Server) {
        
        self.mainAppModel = mainAppModel
        self.server = server
        self.serverName = server.name ?? ""
    }
}
