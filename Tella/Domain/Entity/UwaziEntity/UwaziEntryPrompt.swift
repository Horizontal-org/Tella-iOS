//
//  UwaziEntryPrompt.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

protocol UwaziEntryPrompt: ObservableObject {
    
    associatedtype Value: Codable
    var value: Value { get set }
    var id: String? { get set }
    var formIndex: String? { get set}
    var type: UwaziEntityPropertyType { get set }
    var question: String { get set }
    var answer: String? { get set }
    var required: Bool? { get set }
    var helpText: String? { get set }
    var selectValues: [SelectValues]? { get set }
    var name: String? { get set }
    var showClear: Bool { get set }
    var shouldShowMandatoryError: Bool { get set }
    var isEmpty : Bool { get }
    
    func showMandatoryError()
    func displayClearButton()
    func empty()
}



extension UwaziEntryPrompt {
    
    var isEmpty: Bool {
        return true
    }
    
    func displayClearButton() {
        self.showClear = !isEmpty
    }
    
    func empty() {
    }
    
    func showMandatoryError() {
        self.shouldShowMandatoryError = self.isEmpty && self.required ?? false
    }
}

class CommonUwaziEntryPrompt: Hashable {
    
    var id: String?
    var formIndex: String?
    var type: UwaziEntityPropertyType = .unknown
    var question: String
    var content: String?
    var answer: String?
    var required: Bool?
    var helpText: String?
    var selectValues: [SelectValues]?
    var name: String?
    @Published  var showClear: Bool
    @Published  var shouldShowMandatoryError: Bool
    
    init(id: String? = nil,
         formIndex: String? = nil,
         type: String,
         question: String,
         content: String? = nil,
         answer: String? = nil,
         required: Bool? = nil,
         helpText: String? = nil,
         selectValues: [SelectValues]? = nil,
         name: String? = nil,
         showClear: Bool = false,
         shouldShowMandatoryError: Bool = false) {
        
        self.id = id
        self.formIndex = formIndex
        self.type = UwaziEntityPropertyType(rawValue: type) ?? .unknown
        self.question = question
        self.content = content
        self.answer = answer
        self.required = required
        self.helpText = helpText
        self.selectValues = selectValues
        self.name = name
        self.showClear = showClear
        self.shouldShowMandatoryError = shouldShowMandatoryError
    }
    
    static func == (lhs: CommonUwaziEntryPrompt, rhs: CommonUwaziEntryPrompt) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}

class UwaziDividerEntryPrompt:  CommonUwaziEntryPrompt,UwaziEntryPrompt {
    
    typealias Value = String
    
    @Published  var value: Value = ""
    @Published var values: [Value] = []
}

class UwaziTextEntryPrompt: CommonUwaziEntryPrompt,UwaziEntryPrompt {
    
    typealias Value = String
    
    var isEmpty: Bool {
        return self.value.isEmpty
    }
    
    @Published  var value: String = "" {
        didSet {
            displayClearButton()
        }
    }
    
    func empty() {
        self.value = ""
    }
}

class UwaziSelectEntryPrompt: CommonUwaziEntryPrompt, UwaziEntryPrompt {
    
    typealias Value = [String]
    
    var isEmpty: Bool {
        return self.value.isEmpty
    }
    
    @Published  var value: [String] = [] {
        didSet {
            displayClearButton()
        }
    }
    
    func empty() {
        self.value = []
    }
}

class UwaziFilesEntryPrompt: CommonUwaziEntryPrompt, UwaziEntryPrompt {
    
    typealias Value = Set<VaultFileDB>
    
    var isEmpty: Bool {
        return self.value.isEmpty
    }
    
    @Published  var value: Value =  [] {
        didSet {
            displayClearButton()
        }
    }
    
    func empty() {
        self.value = []
    }
}

class UwaziRelationshipEntryPrompt: CommonUwaziEntryPrompt, UwaziEntryPrompt {
    
    typealias Value = [String]
    
    var isEmpty: Bool {
        return self.value.isEmpty
    }
    
    @Published  var value: [String] = [] {
        didSet {
            displayClearButton()
        }
    }
    
    func empty() {
        self.value = []
    }
}
