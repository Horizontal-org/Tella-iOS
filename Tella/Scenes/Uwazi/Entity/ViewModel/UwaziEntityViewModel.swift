//
//  DraftUwaziEntity.swift
//  Tella
//
//  Created by Gustavo on 04/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

class UwaziEntityViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    
    @Published var template: CollectedTemplate
    @Published var entryPrompts: [UwaziEntryPrompt] = []
    @Published var accessToken: String
    @Published var serverURL: String

    init(mainAppModel: MainAppModel,
         template: CollectedTemplate,
         parser: UwaziEntityParserProtocol,
         server: Server
    ) {
        self.mainAppModel = mainAppModel
        self.template = template
        self.accessToken = server.accessToken ?? ""
        self.serverURL = server.url ?? ""
        entryPrompts = parser.getEntryPrompts()
    }
    func handleMandatoryProperties() async {
        //        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        //        requiredPrompts.forEach { prompt in
        //            prompt.showMandatoryError = prompt.value.stringValue.isEmpty
        //        }
        try await submitEntity()
    }
    
    private func submitEntity() async -> Void {
        let serverURL = self.serverURL
        let cookieList = ["connect.sid=" + self.accessToken]
        
        let response = try await UwaziServerRepository().submitEntity(serverURL: serverURL, cookieList: cookieList, entity: "title from ios")
        
        dump(response)
    }
}
