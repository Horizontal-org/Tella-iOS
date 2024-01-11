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
    @Published var selectedCell = Pages.template
    @Published var pageViewItems : [PageViewItem] = [
        PageViewItem(title: LocalizableUwazi.uwaziPageViewTemplate.localized, page: .template, number: 0)
    ]
    @Published var isLoading: Bool = false
    @Published var serverName : String
    var server: UwaziServer

    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    init(mainAppModel : MainAppModel, server: UwaziServer) {
        
        self.mainAppModel = mainAppModel
        self.server = server
        self.serverName = server.name ?? ""
    }
}
