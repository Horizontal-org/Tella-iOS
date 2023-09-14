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

    init(mainAppModel: MainAppModel, template: CollectedTemplate, parser: UwaziEntityParserProtocol) {
        self.mainAppModel = mainAppModel
        self.template = template
        entryPrompts = parser.getEntryPrompts()
    }
    func handleMandatoryProperties() {
        let requiredPrompts = entryPrompts.filter({$0.required ?? false})
        requiredPrompts.forEach { prompt in
            prompt.showMandatoryError = prompt.value.stringValue.isEmpty
        }
    }
}
