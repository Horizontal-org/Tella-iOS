//
//  UwaziEntityViewModel.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UwaziEntityViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var template: CollectedTemplate? = nil
    @Published var entryPrompts: [UwaziEntryPrompt] = []
    @Published var accessToken: String
    @Published var serverURL: String
    var subscribers = Set<AnyCancellable>()

    init(mainAppModel : MainAppModel, templateId: Int, server: Server) {
        self.mainAppModel = mainAppModel
        self.template = self.getTemplateById(id: templateId)
        self.accessToken = server.accessToken ?? ""
        self.serverURL = server.url ?? ""
        entryPrompts = UwaziEntityParser(template: template!).getEntryPrompts()
    }
    
    var tellaData: TellaData? {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    func getTemplateById (id: Int) -> CollectedTemplate {
        return (self.tellaData?.getUwaziTemplateById(id: id))!
    }
    func handleMandatoryProperties() {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        requiredPrompts.forEach { prompt in
            prompt.showMandatoryError = prompt.value.stringValue.isEmpty
        }
        
        if(!requiredPrompts.isEmpty) {
            submitEntity()
        }
    }
    
    private func submitEntity() -> Void {
        var promptValues: [String: String] = [:]
        for entryPrompt in entryPrompts {
            let question = entryPrompt.question
            let valueString = entryPrompt.value.stringValue

            promptValues[question] = valueString
        }

        let serverURL = self.serverURL
        let cookieList = ["connect.sid=" + self.accessToken]

        let response = UwaziServerRepository().submitEntity(serverURL: serverURL, cookieList: cookieList, entity: promptValues)
        response.sink { completion in
            switch completion {

            case .finished:
                print("Finished")
            case .failure(let error):
                print(error)
            }
            } receiveValue: { value in
                print(value)
            }

            .store(in: &subscribers)
        }
}
