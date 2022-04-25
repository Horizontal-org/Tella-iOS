//
//  LockPinData.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

struct LockPinData  : LockViewProtocol {
    var title = Localizable.Lock.pinTitle
    var description = Localizable.Lock.pinDescription
    var image = "lock.password.B"
    var action: (() -> Void)?
}

struct LockConfirmPinData  : LockViewProtocol  {
    var title = Localizable.Lock.confirmPinTitle
    var description = Localizable.Lock.confirmPinDescription
    var image = "lock.password.B"
    var action: (() -> Void)?
}

var LockKeyboardNumbers: [PinKeyboardModel] = [
    PinKeyboardModel(text: "1", type: .number),
    PinKeyboardModel(text: "2", type: .number),
    PinKeyboardModel(text: "3", type: .number),
    PinKeyboardModel(text: "4",  type: .number),
    PinKeyboardModel(text: "5", type: .number),
    PinKeyboardModel(text: "6",  type: .number),
    PinKeyboardModel(text: "7", type: .number),
    PinKeyboardModel(text: "8",  type: .number),
    PinKeyboardModel(text: "9",  type: .number),
    PinKeyboardModel(type: .empty),
    PinKeyboardModel(text: "0",  type: .number),
    PinKeyboardModel( imageName:"lock.backspace", type: .delete)]

var UnlockKeyboardNumbers: [PinKeyboardModel] = [
    PinKeyboardModel(text: "1", type: .number),
    PinKeyboardModel(text: "2", type: .number),
    PinKeyboardModel(text: "3", type: .number),
    PinKeyboardModel(text: "4",  type: .number),
    PinKeyboardModel(text: "5", type: .number),
    PinKeyboardModel(text: "6",  type: .number),
    PinKeyboardModel(text: "7", type: .number),
    PinKeyboardModel(text: "8",  type: .number),
    PinKeyboardModel(text: "9",  type: .number),
    PinKeyboardModel(imageName:"lock.backspace", type: .delete),
    PinKeyboardModel(text: "0",  type: .number),
    PinKeyboardModel(text: Localizable.Common.ok, type: .done)]

