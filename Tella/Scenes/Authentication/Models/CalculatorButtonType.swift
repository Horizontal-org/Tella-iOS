//  Tella
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

enum PinButtonType {
    case text
    case image
}

enum CalculatorType {
    case lockCalculator
    case unlockCalculator
}

enum CalculatorButtonType:String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case add = "+"
    case subtract = "–"
    case divide = "/"
    case mutliply = "x"
    case equal = "="
    case clear = "AC"
    case decimal = "."
    case percent = "%"
    case negative = "-/+"
    
    var buttonViewData: CalculatorButtonViewProtocol {
        switch self {
            
        case .divide, .mutliply, .subtract, .add :
            return DarkGrayButton()
        case .equal:
            return PetrolButton()
        case .clear, .negative, .percent:
            return MintButton()
        default:
            return LightGrayButton()
        }
    }
    
    var imageName: String {
        switch self {
            
        case .add:
            return "lock.calc.plus"
        case .subtract:
            return "lock.calc.minus"
        case .divide:
            return "lock.calc.division"
        case .mutliply:
            return "lock.calc.times"
        case .negative:
            return "lock.calc.plus-minus"
        default:
            return ""
        }
    }
    
    var buttonType: PinButtonType {
        
        switch self {
        case .negative, .divide, .mutliply, .subtract, .add   :
            return .image
        default:
            return .text
        }
    }
}


