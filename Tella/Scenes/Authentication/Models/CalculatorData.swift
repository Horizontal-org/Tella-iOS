//
//  CalculatorData.swift
//  Calculator
//
//  Created by Dhekra Rouatbi on 10/5/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct CalculatorData {
    static let calculatorItemWidth: CGFloat = (UIScreen.screenWidth - calculatorItemSpace * 5) / 4
    static let calculatorItemSpace: CGFloat = 13
    static let initialCharacter: String = "0"
    
    static  let firstColumns = [GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                                GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                                GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                                GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace)]
    
    static  let secondColumns = [GridItem(.fixed(calculatorItemWidth * 2 + calculatorItemSpace), spacing: calculatorItemSpace),
                                 GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                                 GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace)]
}
