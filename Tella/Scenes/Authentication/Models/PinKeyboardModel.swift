//
//  PinKeyboardModel.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct PinKeyboardModel: Hashable {
    
    var text: String = ""
    var imageName: String = ""
    var actionType: CalculatorButtonType
    var buttonType: PinButtonType
    var buttonViewData : CalculatorButtonViewProtocol
    
    init(text: String,imageName: String = "", type: CalculatorButtonType, buttonType: PinButtonType, buttonViewData:CalculatorButtonViewProtocol) {
        self.text = text
        self.imageName = imageName
        self.actionType = type
        self.buttonType = buttonType
        self.buttonViewData = buttonViewData
    }
    
    static func == (lhs: PinKeyboardModel, rhs: PinKeyboardModel) -> Bool {
        lhs.text == rhs.text
    }
    
    func hash(into hasher: inout Hasher) {
        
    }
    
}


