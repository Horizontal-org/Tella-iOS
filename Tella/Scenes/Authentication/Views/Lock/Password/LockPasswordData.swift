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
    var title = LocalizableLock.passwordTitle.localized
    var description = LocalizableLock.passwordDescription.localized
    var image = "lock.password.B"
    var action: (() -> Void)?  
}

struct LockConfirmPasswordData  : LockViewProtocol  {
    var title = LocalizableLock.confirmPasswordTitle.localized
    var description = LocalizableLock.confirmPasswordDescription.localized
    var image = "lock.password.B"
    var action: (() -> Void)?
}
