//
//  LockViewData.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

protocol LockViewProtocol {
    var title : String { get }
    var description : String { get }
    var image : String { get }
    var action : (() -> Void)? { get set }
}

struct LockPasswordData  : LockViewProtocol {
    var title = Localizable.Lock.passwordTitle
    var description = Localizable.Lock.passwordDescription
    var image = "lock.password.B"
    var action: (() -> Void)?  
}

struct LockConfirmPasswordData  : LockViewProtocol  {
    var title = Localizable.Lock.confirmPasswordTitle
    var description = Localizable.Lock.confirmPasswordDescription
    var image = "lock.password.B"
    var action: (() -> Void)?
}
