//
//  UwaziValue.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziValue: ObservableObject {
    var stringValue: String
    var selectedValue: [SelectValue]
    init(stringValue: String, selectedValue: [SelectValue]) {
        self.stringValue = stringValue
        self.selectedValue = selectedValue
    }
    static func defaultValue() -> UwaziValue {
        return UwaziValue(stringValue: "", selectedValue: [])
    }
}
