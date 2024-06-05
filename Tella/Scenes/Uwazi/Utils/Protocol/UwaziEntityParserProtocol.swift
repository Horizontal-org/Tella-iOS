//
//  UwaziEntityParserProtocol.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol UwaziEntityParserProtocol {
    var entryPrompts: [any UwaziEntryPrompt] { get set }
    var template: CollectedTemplate { get set }
    func handleEntryPrompts()
    func getEntryPrompts() -> [any UwaziEntryPrompt]
}
extension UwaziEntityParserProtocol {
    func getEntryPrompts() -> [any UwaziEntryPrompt] {
        return entryPrompts
    }
}
