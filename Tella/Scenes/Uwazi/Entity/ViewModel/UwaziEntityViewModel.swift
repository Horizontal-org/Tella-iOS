//
//  DraftUwaziEntity.swift
//  Tella
//
//  Created by Gustavo on 04/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UwaziEntityViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    
    @Published var template: CollectedTemplate
    @Published var entryPrompts: [UwaziEntryPrompt] = []
    @Published var accessToken: String
    @Published var serverURL: String
    var subscribers = Set<AnyCancellable>()

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
    func handleMandatoryProperties() {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        requiredPrompts.forEach { prompt in
            prompt.showMandatoryError = prompt.value.stringValue.isEmpty
        }
        let hasMandatoryError = entryPrompts.contains(where: {$0.showMandatoryError == true})
        if !hasMandatoryError {
            let tiles = entryPrompts.filter({$0.name.lowercased() == "title"})
            if let title = tiles.first {
                let titleText = title.value.stringValue
                print(titleText)
            }
            submitEntity()
        }
    }
    
    private func submitEntity() -> Void {
        let serverURL = self.serverURL
        let cookieList = ["connect.sid=" + self.accessToken]
        
        let response = UwaziServerRepository().submitEntity(serverURL: serverURL, cookieList: cookieList, entity: "title from ios 2")
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
