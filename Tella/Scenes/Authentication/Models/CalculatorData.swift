//  Calculator
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct CalculatorData {
    static let calculatorItemWidth: CGFloat = (UIScreen.screenWidth - calculatorItemSpace * 5) / 4
    static let calculatorItemDoubleWidth: CGFloat = (calculatorItemWidth * 2 + calculatorItemSpace)

    static let calculatorItemSpace: CGFloat = 13
    static let initialCharacter: String = "0"
}
