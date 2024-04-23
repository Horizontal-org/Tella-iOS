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

class UwaziDividerEntryPrompt: UwaziEntryPrompt {
    
    
    
    
    typealias Value = String
    
    var id: String?
    
    var formIndex: String?
    
    var type: UwaziEntityPropertyType = .unknown
    
    var question: String
    
    var answer: String?
    
    var required: Bool?
    
    var helpText: String?
    
    var selectValues: [SelectValue]?
    
    var name: String?
    
    var isEmpty: Bool {
        return self.value.value.isEmpty
    }
    
    @Published  var value: UwaziValue<Value>
    @Published var values: [UwaziValue<Value>] = []
    
    @Published  var showClear: Bool
    @Published  var shouldShowMandatoryError: Bool
    
    init(id: String? = nil, formIndex: String? = nil, type: String, question: String, answer: String? = nil, required: Bool? = nil, helpText: String? = nil, selectValues: [SelectValue]? = nil, name: String? = nil, showClear: Bool = false, shouldShowMandatoryError: Bool = false) {
        self.id = id
        self.formIndex = formIndex
        self.type = UwaziEntityPropertyType(rawValue: type) ?? .unknown
        self.question = question
        self.answer = answer
        self.required = required
        self.helpText = helpText
        self.selectValues = selectValues
        self.name = name
        self.value = UwaziValue(value: "")
        self.showClear = showClear
        self.shouldShowMandatoryError = shouldShowMandatoryError
    }
    
    func displayClearButton() {
        self.showClear = !self.value.value.isEmpty
    }
    
    func empty() {
        
    }
    
    func showMandatoryError() {
        self.shouldShowMandatoryError = self.value.value.isEmpty
    }
    
}

class UwaziTextEntryPrompt: UwaziEntryPrompt {
    
    typealias Value = String
    
    var id: String?
    
    var formIndex: String?
    
    var type: UwaziEntityPropertyType = .unknown
    
    var question: String
    
    var answer: String?
    
    var required: Bool?
    
    var helpText: String?
    
    var selectValues: [SelectValue]?
    
    var name: String?
    
    var isEmpty: Bool {
        return self.value.value.isEmpty
    }
    
    @Published  var value: UwaziValue<Value> {
        didSet {
            displayClearButton()
        }
    }
    @Published var values: [UwaziValue<Value>] = []
    @Published  var showClear: Bool
    @Published  var shouldShowMandatoryError: Bool
    
    init(id: String? = nil, formIndex: String? = nil, type: String, question: String, answer: String? = nil, required: Bool? = nil, helpText: String? = nil, selectValues: [SelectValue]? = nil, name: String? = nil, showClear: Bool = false, shouldShowMandatoryError: Bool = false) {
        self.id = id
        self.formIndex = formIndex
        self.type = UwaziEntityPropertyType(rawValue: type) ?? .unknown
        self.question = question
        self.answer = answer
        self.required = required
        self.helpText = helpText
        self.selectValues = selectValues
        self.name = name
        self.value = UwaziValue(value: "")
        self.showClear = showClear
        self.shouldShowMandatoryError = shouldShowMandatoryError
    }
    
    func displayClearButton() {
        self.showClear = !self.value.value.isEmpty
    }
    
    func empty() {
        self.value.value = ""
    }
    
    func showMandatoryError() {
        self.shouldShowMandatoryError = self.isEmpty && self.required ?? false
    }
    
    
    
    func publishUpdates() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    
}

class UwaziSelectEntryPrompt: UwaziEntryPrompt {
    
    
    
    typealias Value = String
    
    var id: String?
    
    var formIndex: String?
    
    var type: UwaziEntityPropertyType = .unknown
    
    var question: String
    
    var answer: String?
    
    var required: Bool?
    
    var helpText: String?
    
    var selectValues: [SelectValue]?
    
    var name: String?
    
    var isEmpty: Bool {
        return self.values.isEmpty
    }
    
    @Published  var value: UwaziValue<String>
    
    @Published var values: [UwaziValue<Value>] = [] {
        didSet {
            displayClearButton()
        }
    }
    
    @Published  var showClear: Bool
    @Published  var shouldShowMandatoryError: Bool
    
    
    init(id: String? = nil, formIndex: String? = nil, type: String, question: String, answer: String? = nil, required: Bool? = nil,  helpText: String? = nil, selectValues: [SelectValue]? = nil, name: String? = nil, showClear: Bool = false, shouldShowMandatoryError: Bool = false) {
        self.id = id
        self.formIndex = formIndex
        self.type = UwaziEntityPropertyType(rawValue: type) ?? .unknown
        self.question = question
        self.answer = answer
        self.required = required
        self.helpText = helpText
        self.selectValues = selectValues
        self.name = name
        self.values = []
        self.value = UwaziValue(value: "")
        self.showClear = showClear
        self.shouldShowMandatoryError = shouldShowMandatoryError
    }
    
    func displayClearButton() {
        self.showClear = !self.values.isEmpty
    }
    func empty() {
        self.values = []
    }
    func showMandatoryError() {
        self.shouldShowMandatoryError = self.isEmpty && self.required ?? false
    }
    
}

class UwaziFilesEntryPrompt: UwaziEntryPrompt {
    
    
    typealias Value = Set<VaultFileDB>
    
    var id: String?
    
    var formIndex: String?
    
    var type: UwaziEntityPropertyType = .unknown
    
    var question: String
    
    var answer: String?
    
    var required: Bool?
    
    var helpText: String?
    
    var selectValues: [SelectValue]?
    
    var name: String?
    
    var isEmpty: Bool {
        return self.value.value.isEmpty
    }
    
    @Published  var value: UwaziValue<Value> {
        didSet {
            displayClearButton()
        }
    }
    @Published  var values: [UwaziValue<Value>] = []
    
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
        self.value = UwaziValue(value: [])
        self.showClear = showClear
        self.shouldShowMandatoryError = shouldShowMandatoryError
    }
    
    func displayClearButton() {
        self.showClear = !self.value.value.isEmpty
    }
    func empty() {
        self.value.value = []
    }
    func showMandatoryError() {
        self.shouldShowMandatoryError = self.isEmpty && self.required ?? false
    }
    
}



//class test: UwaziEntryPrompt {
//
//
//    typealias Value = Any
//    @Published var value: UwaziValue<Value>
//
//    init(value: UwaziValue<Value>) {
//        self.value = value
//    }
//}

//class UwaziEntryPrompt: Hashable, ObservableObject {
//
////    typealias Value = Any
//
//    var id: String?
//    let formIndex: String?
//    let type: String
//    var question: String
//    var answer: String?
//    let required: Bool?
//    let readonly = false
//    let helpText: String?
//    var selectValues: [SelectValue]?
//    let name: String?
//    var entityPropertyType: UwaziEntityPropertyType = .unknown
//
//    @Published var showClear: Bool = false
//    @Published var showMandatoryError: Bool
//
////    @Published var value: UwaziValue<Value>
//
//
//    init(id: String?,
//         formIndex: String?,
//         type: String,
//         question: String,
//         answer: String? = nil,
//         required: Bool?,
//         helpText: String?,
//         selectValues: [SelectValue]? = nil,
//         showMandatoryError: Bool = false,
//         name: String?
//              showClear: Bool = false
//    ) {
//        self.id = id
//        self.formIndex = formIndex
//        self.type = type
//        self.question = question
//        self.answer = answer
//        self.required = required
//        self.helpText = helpText
//        self.selectValues = selectValues
//        self.showMandatoryError = showMandatoryError
//        self.entityPropertyType = UwaziEntityPropertyType(rawValue: type) ?? .dataTypeText
////                self.value = UwaziValue(type: self.entityPropertyType )
//        self.name = name
//        //        self.showClear = !self.value.isEmpty
//    }
//    static func == (lhs: UwaziEntryPrompt, rhs: UwaziEntryPrompt) -> Bool {
//        lhs.id == rhs.id
//    }
//    public func hash(into hasher: inout Hasher) {
//        return hasher.combine(id)
//    }
//
////         func displayClearButton() {
////            self.showClear = self.value != nil
////        }
////    func empty() {
////        value = nil
////    }
////
////    func showMandatoryErrorf() {
////
////    }
//
//
//
//}
