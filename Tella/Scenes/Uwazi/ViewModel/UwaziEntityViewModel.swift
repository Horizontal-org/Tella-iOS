//
//  UwaziEntityViewModel.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

class UwaziEntityViewModel: ObservableObject {
    
    @Published var template: CollectedTemplate
    @Published var entryPrompts: [UwaziEntryPrompt] = []

    init(template: CollectedTemplate, parser: UwaziEntityParserProtocol) {
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
