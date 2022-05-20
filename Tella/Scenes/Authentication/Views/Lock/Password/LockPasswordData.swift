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
    var title = Localizable.Lock.lockPasswordSetSubhead
    var description = Localizable.Lock.lockPasswordSetExpl
    var image = "lock.password.B"
    var action: (() -> Void)?  
}

struct LockConfirmPasswordData  : LockViewProtocol  {
    var title = Localizable.Lock.lockPasswordConfirmSubhead
    var description = Localizable.Lock.lockPasswordConfirmExpl
    var image = "lock.password.B"
    var action: (() -> Void)?
}
