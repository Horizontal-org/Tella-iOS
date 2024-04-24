//
//  UwaziEntryPrompt.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI



protocol UwaziEntryPrompt: /*Hashable,*/ ObservableObject {
    
    associatedtype Value: Codable
    var value: UwaziValue<Value> { get set }
    var values: [UwaziValue<Value>] { get set }
    
    
    var id: String? { get set }
    var formIndex: String? { get set}
    var type: UwaziEntityPropertyType { get set }
    var question: String { get set }
    var answer: String? { get set }
    var required: Bool? { get set }
    var helpText: String? { get set }
    var selectValues: [SelectValue]? { get set }
    var name: String? { get set }
    
    var showClear: Bool { get set }
    var shouldShowMandatoryError: Bool { get set }
    
    var isEmpty : Bool { get }
    //    static func == (lhs: UwaziEntryPrompt, rhs: UwaziEntryPrompt) -> Bool {
    //        lhs.id == rhs.id
    //    }
    //    public func hash(into hasher: inout Hasher) {
    //        return hasher.combine(id)
    //    }
    
    func showMandatoryError()
    func displayClearButton()
    func empty()
}

extension UwaziEntryPrompt {
    
    
    var isEmpty: Bool {
        return false
    }
    
    func displayClearButton() {
        self.showClear = !self.isEmpty
    }
    
    func empty() {
    }
    
    func showMandatoryError() {
        self.shouldShowMandatoryError = self.isEmpty && self.required ?? false
    }
}

class CommonUwaziEntryPrompt  {
    
    var id: String?
    
    var formIndex: String?
    
    var type: UwaziEntityPropertyType = .unknown
    
    var question: String
    
    var answer: String?
    
    var required: Bool?
    
    var helpText: String?
    
    var selectValues: [SelectValue]?
    
    var name: String?
    
    @Published  var showClear: Bool
    @Published  var shouldShowMandatoryError: Bool
    
    
    init(id: String? = nil,
         formIndex: String? = nil,
         type: String, 
         question: String,
         answer: String? = nil,
         required: Bool? = nil,
         helpText: String? = nil,
         selectValues: [SelectValue]? = nil,
         name: String? = nil,
         showClear: Bool = false,
         shouldShowMandatoryError: Bool = false) {
        
        self.id = id
        self.formIndex = formIndex
        self.type = UwaziEntityPropertyType(rawValue: type) ?? .unknown
        self.question = question
        self.answer = answer
        self.required = required
        self.helpText = helpText
        self.selectValues = selectValues
        self.name = name
        self.showClear = showClear
        self.shouldShowMandatoryError = shouldShowMandatoryError
    }
}

class UwaziDividerEntryPrompt:  CommonUwaziEntryPrompt,UwaziEntryPrompt {
    
    typealias Value = String
    
    @Published  var value: UwaziValue<Value> = UwaziValue(value: "")
    @Published var values: [UwaziValue<Value>] = []
    
}

class UwaziTextEntryPrompt: CommonUwaziEntryPrompt,UwaziEntryPrompt {
    
    typealias Value = String
    
    @Published  var value: UwaziValue<String> = UwaziValue(value: "")
    
    @Published var values: [UwaziValue<Value>] = [UwaziValue(value: "")] {
        didSet {
            displayClearButton()
        }
    }

    func empty() {
        self.value.value = ""
    }
    
}

class UwaziSelectEntryPrompt: CommonUwaziEntryPrompt, UwaziEntryPrompt {
    
    typealias Value = String
    
    var isEmpty: Bool {
        return self.values.isEmpty
    }
    
    @Published  var value: UwaziValue<String> = UwaziValue(value: "")
    
    @Published var values: [UwaziValue<Value>] = [] {
        didSet {
            displayClearButton()
        }
    }
    
    func empty() {
        self.values = []
    }
    
}

class UwaziFilesEntryPrompt: CommonUwaziEntryPrompt, UwaziEntryPrompt {

    typealias Value = Set<VaultFileDB>
    
    var isEmpty: Bool {
        return self.value.value.isEmpty
    }
    
    @Published  var value: UwaziValue<Value> = UwaziValue(value: []) {
        didSet {
            displayClearButton()
        }
    }
    @Published  var values: [UwaziValue<Value>] = []
    
    func empty() {
        self.value.value = []
    }
    
}
