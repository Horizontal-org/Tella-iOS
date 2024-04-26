//
//  UwaziEntryPrompt.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

class UwaziEntryPrompt: Hashable, ObservableObject {
    var id: String?
    let formIndex: String?
    let type: String
    var question: String
    var content: String?
    var answer: String?
    let required: Bool?
    let readonly = false
    let helpText: String?
    var selectValues: [SelectValue]?
    @Published var showMandatoryError: Bool
    @Published var value: UwaziValue
    let name: String?
    @Published var showClear: Bool?


    init(id: String,
         formIndex: String?,
         type: String,
         question: String,
         content: String? = nil,
         answer: String? = nil,
         required: Bool?,
         helpText: String?,
         selectValues: [SelectValue]? = nil,
         showMandatoryError: Bool = false,
         value: UwaziValue = UwaziValue.defaultValue(),
         name: String?,
         showClear: Bool = false
    ) {
        self.id = id
        self.formIndex = formIndex
        self.type = type
        self.question = question
        self.content = content
        self.answer = answer
        self.required = required
        self.helpText = helpText
        self.selectValues = selectValues
        self.showMandatoryError = showMandatoryError
        self.value = value
        self.name = name
        self.showClear = showClear
    }
    static func == (lhs: UwaziEntryPrompt, rhs: UwaziEntryPrompt) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

