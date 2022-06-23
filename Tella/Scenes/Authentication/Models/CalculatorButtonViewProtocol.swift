//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI


protocol CalculatorButtonViewProtocol {
    var backgroundColor : Color { get }
    var fontColor : Color { get }
    var font : Font { get }
}

struct MintButton: CalculatorButtonViewProtocol {
    var backgroundColor = Styles.Colors.mint
    var fontColor = Color.black
    var font = Font.custom(Styles.Fonts.lightFontName, size: 30)
}

struct PetrolButton: CalculatorButtonViewProtocol {
    var backgroundColor = Styles.Colors.petrol
    var fontColor = Color.white
    var font = Font.custom(Styles.Fonts.semiBoldFontName, size: 30)
}

struct DarkGrayButton: CalculatorButtonViewProtocol {
    var backgroundColor = Styles.Colors.darkGray
    var fontColor = Color.white
    var font = Font.custom(Styles.Fonts.semiBoldFontName, size: 30)
}

struct LightGrayButton: CalculatorButtonViewProtocol {
    var backgroundColor = Styles.Colors.lightGray
    var fontColor = Styles.Colors.ironGray
    var font = Font.custom(Styles.Fonts.lightFontName, size: 30)
}

