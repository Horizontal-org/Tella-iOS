//
//  LockPinData.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

var LockKeyboardNumbers: [PinKeyboardModel] = [
    PinKeyboardModel(text: "AC", type: .delete, buttonType: .text, buttonViewData: MintButton()),
    PinKeyboardModel(text: "+/_",imageName: "lock.calc.plus-minus", type: .number, buttonType: .image, buttonViewData: MintButton()),
    PinKeyboardModel(text: "%", type: .number, buttonType: .text, buttonViewData: MintButton()),
    PinKeyboardModel(text: "÷", imageName: "lock.calc.division", type: .number, buttonType: .image,  buttonViewData: DarkGrayButton()),
    
    PinKeyboardModel(text: "7", type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "8",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "9", type: .number, buttonType: .text,  buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "x", imageName: "lock.calc.times",  type: .number, buttonType: .image, buttonViewData: DarkGrayButton()),
    
    PinKeyboardModel(text: "4",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "5",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "6",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "-", imageName: "lock.calc.minus",  type: .number, buttonType: .image, buttonViewData: DarkGrayButton()),
    
    PinKeyboardModel(text: "1",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "2",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "3",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "+", imageName: "lock.calc.plus",  type: .number, buttonType: .image, buttonViewData: DarkGrayButton()),
]

var UnlockKeyboardNumbers: [PinKeyboardModel] = [
    PinKeyboardModel(text: "0",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: ",",  type: .number, buttonType: .text, buttonViewData: LightGrayButton()),
    PinKeyboardModel(text: "=",  type: .done, buttonType: .text, buttonViewData: PetrolButton()),
]

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
